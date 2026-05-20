import 'dart:convert';

import 'package:dio/dio.dart';

import 'ai_chat_service.dart';

class OllamaStatus {
  const OllamaStatus({required this.ok, this.models = const [], this.error});

  final bool ok;
  final List<String> models;
  final String? error;
}

/// Service d'acces a Ollama via son API REST locale.
/// Base URL : http://localhost:11434
class OllamaService {
  OllamaService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  /// Genere une reponse complete (non-streaming) depuis Ollama.
  /// Timeout 120 s — un LLM local sans GPU peut etre lent.
  Future<String> generateWithOllama({
    required String prompt,
    required String model,
    String baseUrl = 'http://localhost:11434',
    double temperature = 0.7,
  }) async {
    try {
      final response = await _dio.post(
        '$baseUrl/api/generate',
        options: Options(
          headers: {'Content-Type': 'application/json'},
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 120),
        ),
        data: jsonEncode({
          'model': model,
          'prompt': prompt,
          'stream': false,
          'options': {'temperature': temperature},
        }),
      );
      final data = response.data is Map
          ? response.data as Map<String, dynamic>
          : jsonDecode(response.data.toString()) as Map<String, dynamic>;
      return data['response'] as String;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 404) {
        throw Exception('Modele "$model" introuvable — lance : ollama pull $model');
      }
      throw Exception('Ollama erreur ${status ?? e.message}');
    }
  }

  /// Convertit une liste de messages IA en prompt texte unique pour Ollama.
  /// Ollama /api/generate attend un prompt simple, pas le format chat.
  String _buildPrompt(List<AiMessage> messages, String? systemPrompt) {
    final buf = StringBuffer();
    if (systemPrompt != null && systemPrompt.isNotEmpty) {
      buf.writeln('### Instructions systeme :');
      buf.writeln(systemPrompt);
      buf.writeln();
    }
    for (final m in messages) {
      final prefix = m.role == 'assistant' ? 'Assistant' : 'Utilisateur';
      buf.writeln('$prefix : ${m.content}');
    }
    return buf.toString().trim();
  }

  /// Stream wrapping generateWithOllama — retourne la reponse en un seul token.
  /// Compatible avec l'interface Stream<String> de AiChatService.
  Stream<String> streamGenerate({
    required List<AiMessage> messages,
    String? systemPrompt,
    required String model,
    String baseUrl = 'http://localhost:11434',
    double temperature = 0.7,
  }) async* {
    final prompt = _buildPrompt(messages, systemPrompt);
    final result = await generateWithOllama(
      prompt: prompt,
      model: model,
      baseUrl: baseUrl,
      temperature: temperature,
    );
    yield result;
  }

  /// Verifie qu'Ollama est lance et retourne la liste des modeles installes.
  /// GET /api/tags
  Future<OllamaStatus> checkOllamaConnection(String baseUrl) async {
    try {
      final response = await _dio.get(
        '$baseUrl/api/tags',
        options: Options(
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );
      final data = response.data is Map
          ? response.data as Map<String, dynamic>
          : jsonDecode(response.data.toString()) as Map<String, dynamic>;
      final models = (data['models'] as List?)
              ?.map((m) => (m as Map<String, dynamic>)['name'] as String)
              .toList() ??
          [];
      return OllamaStatus(ok: true, models: models);
    } catch (e) {
      return OllamaStatus(ok: false, error: e.toString());
    }
  }
}
