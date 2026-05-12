import 'dart:convert';

class CustomQuizData {
  const CustomQuizData({
    required this.title,
    required this.description,
    required this.author,
    required this.questions,
  });

  final String title;
  final String description;
  final String author;
  final List<CustomQuestion> questions;

  static const int minQuestions = 2;
  static const int maxQuestions = 50;

  static CustomQuizData fromJsonString(String raw) {
    final Map<String, dynamic> data;
    try {
      data = jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      throw const FormatException('Le fichier n\'est pas un JSON valide.');
    }
    return fromJson(data);
  }

  static CustomQuizData fromJson(Map<String, dynamic> json) {
    final quizMeta = json['quiz'] as Map<String, dynamic>? ?? {};
    final rawQuestions = json['questions'];

    if (rawQuestions == null || rawQuestions is! List || rawQuestions.isEmpty) {
      throw const FormatException('Le fichier ne contient pas de questions.');
    }

    final questions = rawQuestions
        .asMap()
        .entries
        .map((e) {
          try {
            return CustomQuestion.fromJson(e.value as Map<String, dynamic>);
          } on FormatException catch (ex) {
            throw FormatException('Question ${e.key + 1} : ${ex.message}');
          }
        })
        .toList();

    if (questions.length < minQuestions) {
      throw FormatException(
          'Le quiz doit contenir au moins $minQuestions questions (${questions.length} trouvée(s)).');
    }
    if (questions.length > maxQuestions) {
      throw FormatException(
          'Le quiz ne peut pas dépasser $maxQuestions questions (${questions.length} trouvée(s)).');
    }

    final title = (quizMeta['title'] as String?)?.trim() ?? '';
    if (title.isEmpty) {
      throw const FormatException('Le champ "quiz.title" est obligatoire.');
    }

    return CustomQuizData(
      title: title,
      description: (quizMeta['description'] as String?)?.trim() ?? '',
      author: (quizMeta['author'] as String?)?.trim() ?? 'Anonyme',
      questions: questions,
    );
  }
}

class CustomQuestion {
  const CustomQuestion({
    required this.question,
    required this.answer,
    required this.difficulty,
    this.hint = '',
    this.type = 'classic',
    this.contextLine,
    this.indices = const [],
    this.items = const [],
  });

  final String question;
  final String answer;
  final String difficulty;
  final String hint;
  final String type;
  final String? contextLine;
  final List<String> indices;
  /// Pour type == 'sequence' : éléments dans l'ordre correct.
  final List<String> items;

  static const _validDifficulties = {'facile', 'moyen', 'difficile'};
  static const _validTypes = {'classic', 'ticket', 'diagnostic_indices', 'sequence'};

  static CustomQuestion fromJson(Map<String, dynamic> json) {
    final question = (json['question'] as String?)?.trim() ?? '';
    final answer = (json['answer'] as String?)?.trim() ?? '';

    if (question.isEmpty) throw const FormatException('Le champ "question" est vide.');
    if (answer.isEmpty) throw const FormatException('Le champ "answer" est vide.');

    final difficulty = (json['difficulty'] as String?)?.trim().toLowerCase() ?? 'moyen';
    if (!_validDifficulties.contains(difficulty)) {
      throw FormatException(
          'Difficulté "$difficulty" invalide. Valeurs acceptées : facile, moyen, difficile.');
    }

    final type = (json['type'] as String?)?.trim().toLowerCase() ?? 'classic';
    if (!_validTypes.contains(type)) {
      throw FormatException(
          'Type "$type" invalide. Valeurs acceptées : classic, ticket, diagnostic_indices, sequence.');
    }

    final rawIndices = json['indices'];
    final indices = rawIndices is List
        ? rawIndices.map((e) => e.toString()).where((s) => s.isNotEmpty).toList()
        : <String>[];

    if (type == 'diagnostic_indices' && indices.isEmpty) {
      throw const FormatException(
          'Le type "diagnostic_indices" requiert au moins un indice dans le champ "indices".');
    }

    final rawItems = json['items'];
    final items = rawItems is List
        ? rawItems.map((e) => e.toString()).where((s) => s.isNotEmpty).toList()
        : <String>[];

    if (type == 'sequence' && items.length < 2) {
      throw const FormatException(
          'Le type "sequence" requiert au moins 2 éléments dans le champ "items".');
    }

    return CustomQuestion(
      question: question,
      answer: answer,
      difficulty: difficulty,
      hint: (json['hint'] as String?)?.trim() ?? '',
      type: type,
      contextLine: (json['context'] as String?)?.trim(),
      indices: indices,
      items: items,
    );
  }
}
