import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/router/quiz_play_session.dart';
import '../../quiz/models/quiz_models.dart';
import 'ai_chat_service.dart';
import 'ai_provider.dart';

class AiGeneratedQuestion {
  const AiGeneratedQuestion({
    required this.id,
    required this.type,
    required this.question,
    required this.answer,
    required this.explanation,
    this.difficulty = 'moyen',
    this.indices,
    this.items,
    this.pairs,
    this.checklist,
  });

  final String id;
  final String type;
  final String question;
  final String answer;
  final String explanation;
  final String difficulty;
  final List<String>? indices;
  final List<String>? items;
  final List<List<String>>? pairs;
  final List<String>? checklist;

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'question': question,
        'answer': answer,
        'explanation': explanation,
        'difficulty': difficulty,
        if (indices != null) 'indices': indices,
        if (items != null) 'items': items,
        if (pairs != null) 'pairs': pairs,
        if (checklist != null) 'checklist': checklist,
      };

  factory AiGeneratedQuestion.fromJson(Map<String, dynamic> json, int fallbackIndex) {
    final id = json['id']?.toString() ?? 'ai_q_${DateTime.now().millisecondsSinceEpoch}_$fallbackIndex';
    final question = (json['question'] as String?)?.trim() ?? '';
    var answer = (json['answer'] as String?)?.trim() ?? '';
    final explanation = (json['explanation'] as String?)?.trim() ?? (json['hint'] as String?)?.trim() ?? '';
    final difficulty = (json['difficulty'] as String?)?.trim() ?? 'moyen';
    var rawType = (json['type'] as String?)?.trim().toLowerCase() ?? 'classic';

    // 1. Séquence (items)
    final rawItems = json['items'] ?? json['sequence'];
    List<String>? items;
    if (rawItems is List && rawItems.isNotEmpty) {
      items = rawItems.map((e) => e.toString().trim()).where((s) => s.isNotEmpty).toList();
      if (answer.isEmpty && items.isNotEmpty) {
        answer = items.asMap().entries.map((e) => '${e.key + 1}. ${e.value}').join('\n');
      }
    }

    // 2. Association (pairs)
    final rawPairs = json['pairs'] ?? json['matches'];
    List<List<String>>? pairs;
    if (rawPairs is List && rawPairs.isNotEmpty) {
      final parsedPairs = <List<String>>[];
      for (final p in rawPairs) {
        if (p is List && p.length >= 2) {
          parsedPairs.add([p[0].toString().trim(), p[1].toString().trim()]);
        } else if (p is Map) {
          final l = p['left']?.toString().trim() ?? '';
          final r = p['right']?.toString().trim() ?? '';
          if (l.isNotEmpty && r.isNotEmpty) parsedPairs.add([l, r]);
        }
      }
      if (parsedPairs.isNotEmpty) {
        pairs = parsedPairs;
        if (answer.isEmpty) {
          answer = pairs.map((p) => '${p[0]} -> ${p[1]}').join(', ');
        }
      }
    }

    // 3. Diagnostic à indices (indices)
    final rawIndices = json['indices'] ?? json['hints'];
    List<String>? indices;
    if (rawIndices is List && rawIndices.isNotEmpty) {
      indices = rawIndices.map((e) => e.toString().trim()).where((s) => s.isNotEmpty).toList();
    }

    // 4. Ticket (checklist)
    final rawChecklist = json['checklist'] ?? json['actions'];
    List<String>? checklist;
    if (rawChecklist is List && rawChecklist.isNotEmpty) {
      checklist = rawChecklist.map((e) => e.toString().trim()).where((s) => s.isNotEmpty).toList();
    }

    // Détermination automatique du type si non explicite
    if (rawType == 'sequence' && (items == null || items.length < 2)) {
      rawType = 'classic';
    } else if (rawType == 'association' && (pairs == null || pairs.length < 2)) {
      rawType = 'classic';
    } else if (rawType == 'diagnostic_indices' && (indices == null || indices.isEmpty)) {
      rawType = 'classic';
    } else if (rawType == 'ticket' && (checklist == null || checklist.isEmpty)) {
      rawType = 'classic';
    } else if (rawType == 'classic') {
      if (items != null && items.length >= 2) rawType = 'sequence';
      else if (pairs != null && pairs.length >= 2) rawType = 'association';
      else if (indices != null && indices.isNotEmpty) rawType = 'diagnostic_indices';
      else if (checklist != null && checklist.isNotEmpty) rawType = 'ticket';
    }

    return AiGeneratedQuestion(
      id: id,
      type: rawType,
      question: question,
      answer: answer,
      explanation: explanation,
      difficulty: difficulty,
      indices: indices,
      items: items,
      pairs: pairs,
      checklist: checklist,
    );
  }
}

class AiQuizGeneratorService {
  AiQuizGeneratorService({AiChatService? chatService})
      : _chatService = chatService ?? AiChatService();

  final AiChatService _chatService;

  Future<({String url, String model})> _ollamaConfig() async {
    final prefs = await SharedPreferences.getInstance();
    return (
      url: prefs.getString('ollama_url') ?? 'http://localhost:11434',
      model: prefs.getString('ollama_model') ?? 'gemma3',
    );
  }

  Stream<String> streamGenerateQuiz({
    required String apiKey,
    required AiProvider provider,
    required String topic,
    int count = 10,
    String difficulty = 'moyen',
    String? noteContent,
    String? geminiModel,
  }) async* {
    const systemPrompt =
        'Tu es un formateur et concepteur de quiz IT expert certifié Eskolia. '
        'Tu génères des quiz interactifs stimulants et équilibrés pour des techniciens et administrateurs informatiques. '
        'Tu dois intégrer une diversité équilibrée des différents types de questions interactives Eskolia. '
        'Réponds UNIQUEMENT avec un JSON valide et bien formé, sans aucun texte autour, sans délimiteur markdown code fence.';

    final diffText = difficulty == 'mixte'
        ? 'Mix équilibré de difficultés (facile, moyen, difficile)'
        : 'Niveau $difficulty';

    final contentSection = noteContent != null && noteContent.isNotEmpty
        ? '\n\nBase-toi impérativement sur ces notes de cours :\n$noteContent'
        : '';

    // Détermination de la répartition équitable selon le nombre de questions
    final int classicCount = (count * 0.4).round().clamp(1, count);
    final int sequenceCount = (count >= 3) ? (count * 0.2).round().clamp(1, 3) : 0;
    final int assocCount = (count >= 4) ? (count * 0.2).round().clamp(1, 3) : 0;
    final int diagCount = (count >= 5) ? 1 : 0;
    final int ticketCount = (count >= 6) ? 1 : 0;

    final userPrompt =
        'Génère un quiz de $count questions sur le thème : "$topic" ($diffText).$contentSection\n\n'
        'RÉPARTITION ÉQUITABLE DES TYPES RECOMMANDÉE :\n'
        '- Environ $classicCount questions ouvertes "classic" (Active Recall standard)\n'
        '${sequenceCount > 0 ? "- Environ $sequenceCount questions de remise en ordre \"sequence\"\n" : ""}'
        '${assocCount > 0 ? "- Environ $assocCount questions d\'association de paires \"association\"\n" : ""}'
        '${diagCount > 0 ? "- 1 cas de panne avec indices \"diagnostic_indices\"\n" : ""}'
        '${ticketCount > 0 ? "- 1 ticket d\'incident helpdesk avec checklist \"ticket\"\n" : ""}\n'
        'FORMAT JSON STRICT ATTENDU :\n'
        '{\n'
        '  "quizTitle": "Titre précis du quiz",\n'
        '  "questions": [\n'
        '    {\n'
        '      "id": "q1",\n'
        '      "type": "classic",\n'
        '      "question": "Question ouverte d\'Active Recall",\n'
        '      "answer": "Réponse attendue complète et claire",\n'
        '      "explanation": "Explication technique détaillée",\n'
        '      "difficulty": "facile | moyen | difficile"\n'
        '    },\n'
        '    {\n'
        '      "id": "q2",\n'
        '      "type": "sequence",\n'
        '      "question": "Remets dans l\'ordre les étapes de...",\n'
        '      "answer": "1. Première étape\\n2. Deuxième étape...",\n'
        '      "items": ["Étape 1 dans l\'ordre", "Étape 2 dans l\'ordre", "Étape 3 dans l\'ordre", "Étape 4 dans l\'ordre"],\n'
        '      "explanation": "Explication sur la chronologie logique",\n'
        '      "difficulty": "moyen"\n'
        '    },\n'
        '    {\n'
        '      "id": "q3",\n'
        '      "type": "association",\n'
        '      "question": "Associe chaque élément de gauche à sa correspondance de droite :",\n'
        '      "answer": "A -> B, C -> D...",\n'
        '      "pairs": [\n'
        '        ["Élément Gauche 1", "Élément Droite 1"],\n'
        '        ["Élément Gauche 2", "Élément Droite 2"],\n'
        '        ["Élément Gauche 3", "Élément Droite 3"]\n'
        '      ],\n'
        '      "explanation": "Explication technique de l\'association",\n'
        '      "difficulty": "moyen"\n'
        '    },\n'
        '    {\n'
        '      "id": "q4",\n'
        '      "type": "diagnostic_indices",\n'
        '      "question": "Symptôme de la panne observée...",\n'
        '      "answer": "Diagnostic précis de la cause",\n'
        '      "indices": ["Indice 1 (léger)", "Indice 2 (plus précis)", "Indice 3 (décisif)"],\n'
        '      "explanation": "Explication du diagnostic",\n'
        '      "difficulty": "difficile"\n'
        '    },\n'
        '    {\n'
        '      "id": "q5",\n'
        '      "type": "ticket",\n'
        '      "question": "Ticket incident : description du problème utilisateur...",\n'
        '      "answer": "Action de résolution",\n'
        '      "checklist": ["Vérification 1", "Vérification 2", "Action 3", "Test 4"],\n'
        '      "explanation": "Explication de la démarche méthodique",\n'
        '      "difficulty": "moyen"\n'
        '    }\n'
        '  ]\n'
        '}\n\n'
        'RÈGLES ABSOLUES :\n'
        '- Chaque question doit avoir un type parmi : "classic", "sequence", "association", "diagnostic_indices", "ticket".\n'
        '- Pour "sequence" : fournir le champ "items" avec au moins 3 étapes dans l\'ordre chronologique correct.\n'
        '- Pour "association" : fournir le champ "pairs" avec au moins 3 sous-tableaux [gauche, droite].\n'
        '- Pour "diagnostic_indices" : fournir le champ "indices" avec 2 à 3 indices progressifs.\n'
        '- Pour "ticket" : fournir le champ "checklist" avec 3 à 4 vérifications techniques.\n'
        '- Fournis toujours une "explanation" à haute valeur pédagogique.';

    final ollama = provider == AiProvider.ollama ? await _ollamaConfig() : (url: '', model: '');

    yield* _chatService.streamChat(
      apiKey: apiKey,
      provider: provider,
      messages: [AiMessage(role: 'user', content: userPrompt)],
      systemPrompt: systemPrompt,
      maxTokens: 8192,
      temperature: 0.3,
      jsonMode: true,
      ollamaBaseUrl: ollama.url,
      ollamaModel: ollama.model,
      geminiModel: geminiModel,
    );
  }

  Future<QuizSession> generateQuizSession({
    required String apiKey,
    required AiProvider provider,
    required String topic,
    int count = 10,
    String difficulty = 'moyen',
    String? noteContent,
    String? geminiModel,
  }) async {
    final buffer = StringBuffer();
    await for (final token in streamGenerateQuiz(
      apiKey: apiKey,
      provider: provider,
      topic: topic,
      count: count,
      difficulty: difficulty,
      noteContent: noteContent,
      geminiModel: geminiModel,
    )) {
      buffer.write(token);
    }

    final rawJson = extractJson(buffer.toString());
    return parseQuizJson(rawJson, defaultTitle: topic);
  }

  static String extractJson(String text) {
    final trimmed = text.trim();
    final jsonFence = RegExp(r'```json\s*\n?([\s\S]*?)\n?```');
    final match = jsonFence.firstMatch(trimmed);
    if (match != null) return match.group(1)!.trim();

    final genericFence = RegExp(r'```[^\n]*\n?([\s\S]*?)\n?```');
    final genericMatch = genericFence.firstMatch(trimmed);
    if (genericMatch != null) return genericMatch.group(1)!.trim();

    final firstBracket = trimmed.indexOf('[');
    final lastBracket = trimmed.lastIndexOf(']');
    final firstBrace = trimmed.indexOf('{');
    final lastBrace = trimmed.lastIndexOf('}');

    if (firstBracket != -1 && lastBracket > firstBracket && (firstBrace == -1 || firstBracket < firstBrace)) {
      return trimmed.substring(firstBracket, lastBracket + 1).trim();
    }
    if (firstBrace != -1 && lastBrace > firstBrace) {
      return trimmed.substring(firstBrace, lastBrace + 1).trim();
    }
    return trimmed;
  }

  QuizSession parseQuizJson(String rawJson, {required String defaultTitle}) {
    final Map<String, dynamic> data;
    try {
      data = jsonDecode(rawJson) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('[AiQuizGeneratorService.parseQuizJson] Erreur JSON: $e');
      throw const FormatException('Le JSON généré par l\'IA est mal formé. Veuillez réessayer.');
    }

    final rawQuestions = data['questions'];
    if (rawQuestions is! List || rawQuestions.isEmpty) {
      throw const FormatException('Aucune question trouvée dans la réponse de l\'IA.');
    }

    final title = (data['quizTitle'] as String?)?.trim() ??
        (data['quiz'] is Map ? (data['quiz']['title'] as String?)?.trim() : null) ??
        defaultTitle;

    final parsedQuestions = <QuizQuestion>[];

    for (int i = 0; i < rawQuestions.length; i++) {
      final qItem = rawQuestions[i];
      if (qItem is! Map<String, dynamic>) continue;

      final parsedAiQ = AiGeneratedQuestion.fromJson(qItem, i + 1);
      if (parsedAiQ.question.isEmpty || parsedAiQ.answer.isEmpty) continue;

      parsedQuestions.add(QuizQuestion(
        id: parsedAiQ.id,
        type: parsedAiQ.type,
        question: parsedAiQ.question,
        answer: parsedAiQ.answer,
        explanation: parsedAiQ.explanation.isNotEmpty ? parsedAiQ.explanation : null,
        difficultyBucket: parsedAiQ.difficulty.toLowerCase(),
        contextLine: 'Quiz IA · $title',
        categoryGroup: QuestionCategoryGroup.themes,
        indices: parsedAiQ.indices,
        answerSequence: parsedAiQ.items,
        matchPairs: parsedAiQ.pairs,
        checklist: parsedAiQ.checklist,
      ));
    }

    if (parsedQuestions.isEmpty) {
      throw const FormatException('Toutes les questions générées sont invalides.');
    }

    return QuizSession(
      sessionId: 'ai_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      questions: parsedQuestions,
      currentIndex: 0,
      userScores: List<double?>.filled(parsedQuestions.length, null),
      startTime: DateTime.now(),
      runMode: QuizRunMode.standard,
      timed: false,
    );
  }
}
