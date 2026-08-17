import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ai_provider.dart';
import 'ollama_service.dart';

class AiMessage {
  const AiMessage({required this.role, required this.content});

  /// 'user' | 'assistant' | 'system'
  final String role;
  final String content;

  Map<String, dynamic> toJson() => {'role': role, 'content': content};
}

/// Service d'appels IA — streaming SSE vers le provider détecté.
/// Supporte OpenAI-compatible (OpenAI, Groq, Perplexity, xAI, Mistral),
/// Anthropic et Google Gemini avec leurs formats natifs.
class AiChatService {
  AiChatService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  /// Stream les tokens de reponse au fur et a mesure.
  /// [temperature]  : 0.0 (deterministe) -> 1.0 (creatif). Defaut 0.7.
  /// [jsonMode]     : force une sortie JSON valide (OpenAI, Groq, Gemini).
  /// [ollamaBaseUrl]: URL de base Ollama (defaut http://localhost:11434).
  /// [ollamaModel]  : modele Ollama (defaut gemma3).
  Stream<String> streamChat({
    required String apiKey,
    required AiProvider provider,
    required List<AiMessage> messages,
    String? systemPrompt,
    int maxTokens = 4096,
    double temperature = 0.7,
    bool jsonMode = false,
    String ollamaBaseUrl = 'http://localhost:11434',
    String ollamaModel = 'gemma3',
    String? geminiModel,
  }) {
    return switch (provider) {
      AiProvider.ollama => OllamaService(dio: _dio).streamGenerate(
          messages: messages,
          systemPrompt: systemPrompt,
          model: ollamaModel,
          baseUrl: ollamaBaseUrl,
          temperature: temperature,
        ),
      AiProvider.anthropic => _streamAnthropic(
          apiKey, messages, systemPrompt, maxTokens, temperature),
      AiProvider.gemini => _streamGemini(
          apiKey, messages, systemPrompt, temperature, jsonMode, geminiModel),
      _ => _streamOpenAICompat(
          apiKey, provider, messages, systemPrompt, maxTokens, temperature, jsonMode),
    };
  }

  // ── OpenAI-compatible (OpenAI, Groq, Perplexity, xAI, Mistral) ──────────

  Stream<String> _streamOpenAICompat(
    String key,
    AiProvider provider,
    List<AiMessage> messages,
    String? systemPrompt,
    int maxTokens,
    double temperature,
    bool jsonMode,
  ) async* {
    final msgs = [
      if (systemPrompt != null) {'role': 'system', 'content': systemPrompt},
      ...messages.map((m) => m.toJson()),
    ];

    Response<ResponseBody> response;
    try {
      response = await _dio.post<ResponseBody>(
        '${provider.baseUrl}/v1/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer $key',
            'Content-Type': 'application/json',
          },
          responseType: ResponseType.stream,
          sendTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 90),
        ),
        data: jsonEncode({
          'model': provider.defaultModel,
          'messages': msgs,
          'stream': true,
          'max_tokens': maxTokens,
          'temperature': temperature,
          if (jsonMode) 'response_format': {'type': 'json_object'},
        }),
      );
    } on DioException catch (e) {
      throw _dioError(e);
    }

    yield* _parseOpenAIStream(response.data!.stream);
  }

  Stream<String> _parseOpenAIStream(Stream<List<int>> raw) async* {
    String buffer = '';
    await for (final chunk in raw) {
      buffer += utf8.decode(chunk, allowMalformed: true);
      final lines = buffer.split('\n');
      buffer = lines.removeLast();
      for (final line in lines) {
        final trimmed = line.trim();
        if (!trimmed.startsWith('data: ')) continue;
        final data = trimmed.substring(6).trim();
        if (data == '[DONE]') return;
        final delta = _extractOpenAIDelta(data);
        if (delta != null && delta.isNotEmpty) yield delta;
      }
    }
  }

  // ── Anthropic ─────────────────────────────────────────────────────────────

  Stream<String> _streamAnthropic(
    String key,
    List<AiMessage> messages,
    String? systemPrompt,
    int maxTokens,
    double temperature,
  ) async* {
    Response<ResponseBody> response;
    try {
      response = await _dio.post<ResponseBody>(
        'https://api.anthropic.com/v1/messages',
        options: Options(
          headers: {
            'x-api-key': key,
            'anthropic-version': '2023-06-01',
            'Content-Type': 'application/json',
          },
          responseType: ResponseType.stream,
          sendTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 90),
        ),
        data: jsonEncode({
          'model': AiProvider.anthropic.defaultModel,
          'max_tokens': maxTokens,
          'temperature': temperature,
          if (systemPrompt != null) 'system': systemPrompt,
          'messages': messages.map((m) => m.toJson()).toList(),
          'stream': true,
        }),
      );
    } on DioException catch (e) {
      throw _dioError(e);
    }

    String buffer = '';
    await for (final chunk in response.data!.stream) {
      buffer += utf8.decode(chunk, allowMalformed: true);
      final lines = buffer.split('\n');
      buffer = lines.removeLast();
      for (final line in lines) {
        final trimmed = line.trim();
        if (!trimmed.startsWith('data: ')) continue;
        final data = trimmed.substring(6).trim();
        final text = _extractAnthropicDelta(data);
        if (text != null && text.isNotEmpty) yield text;
      }
    }
  }

  Future<Response<dynamic>> _postGemini(String key, String model, String promptText) {
    return _dio.post<dynamic>(
      'https://generativelanguage.googleapis.com/v1beta/models/'
      '$model:generateContent',
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'x-goog-api-key': key,
        },
        sendTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 90),
      ),
      data: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': promptText}
            ]
          }
        ],
      }),
    );
  }

  Stream<String> _streamGemini(
    String key,
    List<AiMessage> messages,
    String? systemPrompt,
    double temperature,
    bool jsonMode,
    String? explicitModel,
  ) async* {
    final buf = StringBuffer();
    if (systemPrompt != null && systemPrompt.isNotEmpty) {
      buf.writeln(systemPrompt);
      buf.writeln();
    }
    for (final m in messages) {
      buf.writeln(m.content);
    }
    final promptText = buf.toString().trim();

    final prefs = await SharedPreferences.getInstance();
    final geminiModel = explicitModel ?? prefs.getString('gemini_model') ?? 'gemini-2.0-flash';

    Response<dynamic> response;
    try {
      response = await _postGemini(key, geminiModel, promptText);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (geminiModel == 'gemini-2.0-flash' && (status == 503 || status == 429)) {
        try {
          response = await _postGemini(key, 'gemini-1.5-flash', promptText);
        } on DioException catch (fallbackErr) {
          throw _dioError(fallbackErr);
        }
      } else {
        throw _dioError(e);
      }
    }

    final data = response.data is Map
        ? response.data as Map<String, dynamic>
        : jsonDecode(response.data.toString()) as Map<String, dynamic>;
    final text = _extractGeminiText(data);
    if (text != null && text.isNotEmpty) yield text;
  }

  /// Extrait le delta de contenu d'une ligne SSE OpenAI-compatible.
  /// Decode + navigation type-safe : evite les crashs dart2js sur ?. dynamic.
  static String? _extractOpenAIDelta(String data) {
    try {
      final json = jsonDecode(data);
      if (json is! Map) return null;
      final choices = json['choices'];
      if (choices is! List || choices.isEmpty) return null;
      final first = choices[0];
      if (first is! Map) return null;
      final delta = first['delta'];
      if (delta is! Map) return null;
      return delta['content'] as String?;
    } catch (_) {
      return null;
    }
  }

  /// Extrait le texte d'un event SSE Anthropic content_block_delta.
  static String? _extractAnthropicDelta(String data) {
    try {
      final json = jsonDecode(data);
      if (json is! Map) return null;
      if (json['type'] != 'content_block_delta') return null;
      final delta = json['delta'];
      if (delta is! Map) return null;
      return delta['text'] as String?;
    } catch (_) {
      return null;
    }
  }

  /// Extrait le texte d'une reponse Gemini generateContent de facon securisee.
  /// Evite les crashs sur Flutter Web (dart2js) dus aux operateurs ?. sur dynamic.
  static String? _extractGeminiText(Map<String, dynamic> data) {
    try {
      final candidates = data['candidates'];
      if (candidates is! List || candidates.isEmpty) return null;
      final first = candidates[0];
      if (first is! Map) return null;
      final content = first['content'];
      if (content is! Map) return null;
      final parts = content['parts'];
      if (parts is! List || parts.isEmpty) return null;
      final part = parts[0];
      if (part is! Map) return null;
      return part['text'] as String?;
    } catch (_) {
      return null;
    }
  }

  // ── Test de connexion ─────────────────────────────────────────────────────

  /// Retourne null si la cle est valide, ou le message d'erreur reel sinon.
  Future<String?> testKey(String key, AiProvider provider, {String? geminiModel}) async {
    try {
      var received = false;
      await for (final chunk in streamChat(
        apiKey: key,
        provider: provider,
        messages: const [AiMessage(role: 'user', content: 'Reply with OK only.')],
        maxTokens: 10,
        geminiModel: geminiModel,
      )) {
        if (chunk.isNotEmpty) received = true;
        break; // premier token suffit
      }
      // Gemini retourne un seul chunk — stream vide = parsing a echoue
      if (!received && provider == AiProvider.gemini) {
        return 'Reponse Gemini vide ou format inattendu.';
      }
      return null; // succes
    } catch (e) {
      return e.toString();
    }
  }

  String _dioError(DioException e) {
    final status = e.response?.statusCode;

    // Extraire le message d'erreur reel depuis le body de la reponse (Gemini, OpenAI, etc.)
    String? apiMessage;
    final body = e.response?.data;
    if (body is Map) {
      apiMessage = (body['error'] as Map?)?['message'] as String?;
    } else if (body is String && body.isNotEmpty) {
      apiMessage = body.length > 200 ? body.substring(0, 200) : body;
    }

    final detail = apiMessage != null ? ' — $apiMessage' : '';
    if (status == 400) return 'Requete invalide (400)$detail';
    if (status == 401) return 'Cle API invalide ou expiree (401)$detail';
    if (status == 403) return 'Acces refuse (403)$detail';
    if (status == 429) return 'Quota depasse — reessaie plus tard (429)$detail';
    return 'Erreur reseau ${status ?? ""}$detail (${e.message})';
  }
}
