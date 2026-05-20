import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

import 'ai_provider.dart';

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

  /// Stream les tokens de réponse au fur et à mesure.
  /// [temperature] : 0.0 (déterministe) → 1.0 (créatif). Défaut 0.7.
  /// [jsonMode]    : force une sortie JSON valide (OpenAI, Groq, Gemini).
  Stream<String> streamChat({
    required String apiKey,
    required AiProvider provider,
    required List<AiMessage> messages,
    String? systemPrompt,
    int maxTokens = 4096,
    double temperature = 0.7,
    bool jsonMode = false,
  }) {
    return switch (provider) {
      AiProvider.anthropic => _streamAnthropic(
          apiKey, messages, systemPrompt, maxTokens, temperature),
      AiProvider.gemini => _streamGemini(
          apiKey, messages, systemPrompt, temperature, jsonMode),
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
        try {
          final json = jsonDecode(data) as Map<String, dynamic>;
          final delta = (json['choices'] as List?)
              ?.firstOrNull?['delta']?['content'] as String?;
          if (delta != null && delta.isNotEmpty) yield delta;
        } catch (_) {}
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
        try {
          final json = jsonDecode(data) as Map<String, dynamic>;
          if (json['type'] == 'content_block_delta') {
            final text = json['delta']?['text'] as String?;
            if (text != null && text.isNotEmpty) yield text;
          }
        } catch (_) {}
      }
    }
  }

  // ── Google Gemini ─────────────────────────────────────────────────────────

  Stream<String> _streamGemini(
    String key,
    List<AiMessage> messages,
    String? systemPrompt,
    double temperature,
    bool jsonMode,
  ) async* {
    final contents = messages
        .where((m) => m.role != 'system')
        .map((m) => {
              'role': m.role == 'assistant' ? 'model' : 'user',
              'parts': [
                {'text': m.content}
              ],
            })
        .toList();

    Response<ResponseBody> response;
    try {
      response = await _dio.post<ResponseBody>(
        'https://generativelanguage.googleapis.com/v1beta/models/'
        '${AiProvider.gemini.defaultModel}:streamGenerateContent'
        '?alt=sse&key=$key',
        options: Options(
          headers: {'Content-Type': 'application/json'},
          responseType: ResponseType.stream,
          sendTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 90),
        ),
        data: jsonEncode({
          'contents': contents,
          if (systemPrompt != null)
            'systemInstruction': {
              'parts': [{'text': systemPrompt}]
            },
          'generationConfig': {
            'temperature': temperature,
            if (jsonMode) 'responseMimeType': 'application/json',
          },
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
        try {
          final json = jsonDecode(data) as Map<String, dynamic>;
          final text = (json['candidates'] as List?)
              ?.firstOrNull?['content']?['parts']
              ?.firstOrNull?['text'] as String?;
          if (text != null && text.isNotEmpty) yield text;
        } catch (_) {}
      }
    }
  }

  // ── Test de connexion ─────────────────────────────────────────────────────

  Future<bool> testKey(String key, AiProvider provider) async {
    try {
      await for (final _ in streamChat(
        apiKey: key,
        provider: provider,
        messages: const [AiMessage(role: 'user', content: 'Reply with OK only.')],
        maxTokens: 10,
      )) {
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  String _dioError(DioException e) {
    final status = e.response?.statusCode;
    if (status == 401) return 'Clé API invalide ou expirée.';
    if (status == 429) return 'Quota API dépassé — réessaie plus tard.';
    if (status == 403) return 'Accès refusé par le provider.';
    return 'Erreur réseau (${e.message})';
  }
}
