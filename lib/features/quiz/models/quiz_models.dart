import '../../../features/parcours/data/tip_quiz_catalog.dart';

/// Définit le groupe d'appartenance d'une question
enum QuestionCategoryGroup {
  officialParcours, // Contenu source Optimus
  themes,           // Thèmes transversaux
  labo              // Créations communautaires
}

/// Mode d'exécution du quiz.
enum QuizRunMode {
  standard,
  survival,
}

/// Cible du bouton « retour » sur l'écran de résultats.
enum QuizResultExitDestination {
  parcours,
  soloMenu,
}

class QuizQuestion {
  const QuizQuestion({
    required this.id,
    this.type = 'classic',
    required this.question,
    required this.answer,
    this.answerSequence,
    this.matchPairs,
    this.explanation,
    this.sourceAssetPath,
    this.difficultyBucket = 'unknown',
    this.contextLine,
    this.theme,
    this.sousTheme,
    this.categoryGroup = QuestionCategoryGroup.officialParcours,
    this.authorName = 'Eskolia Team',
    this.indices,
    this.checklist,
    this.options,
  });

  final String id;
  final String type;
  final String question;
  final String answer;
  /// Pour type == 'sequence' : ordre correct des étapes.
  final List<String>? answerSequence;
  /// Pour type == 'association' : paires correctes [[gauche, droite], ...].
  final List<List<String>>? matchPairs;
  final String? explanation;
  final String? sourceAssetPath;
  final String difficultyBucket;
  final String? contextLine;
  final String? theme;
  final String? sousTheme;
  final QuestionCategoryGroup categoryGroup;
  final String authorName;

  final List<String>? indices;
  final List<String>? checklist;
  final List<String>? options;

  // Compatibilité QCM si nécessaire
  List<String> get legacyOptions => options ?? [answer];
  int get correctIndex => 0;

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'question': question,
    'answer': answer,
    'answerSequence': answerSequence,
    'matchPairs': matchPairs,
    'explanation': explanation,
    'sourceAssetPath': sourceAssetPath,
    'difficultyBucket': difficultyBucket,
    'contextLine': contextLine,
    'theme': theme,
    'sousTheme': sousTheme,
    'categoryGroup': categoryGroup.name,
    'authorName': authorName,
    'indices': indices,
    'checklist': checklist,
    'options': options,
  };
}

class QuizSession {
  const QuizSession({
    required this.sessionId,
    required this.title,
    required this.questions,
    required this.currentIndex,
    required this.userScores,
    required this.startTime,
    this.runMode = QuizRunMode.standard,
    this.timed = true,
    this.postQuestionRecapEnabled = true,
    this.survivalCatalogTrack,
    this.isMistakesSession = false,
    this.isDailyRandom = false,
    this.isPoolOnly = false,
  });

  final String sessionId;
  final String title;
  final List<QuizQuestion> questions;
  final int currentIndex;
  /// Stocke le score pour chaque question : 1.0 (parfait), 0.75, 0.5, 0.0 (faux), null (non répondu)
  final List<double?> userScores;
  final DateTime startTime;
  final QuizRunMode runMode;
  final bool timed;
  final bool postQuestionRecapEnabled;
  final QuizCatalogTrack? survivalCatalogTrack;
  final bool isMistakesSession;
  final bool isDailyRandom;
  final bool isPoolOnly;

  int get totalQuestions => questions.length;

  QuizSession copyWith({
    String? sessionId,
    String? title,
    List<QuizQuestion>? questions,
    int? currentIndex,
    List<double?>? userScores,
    DateTime? startTime,
    QuizRunMode? runMode,
    bool? timed,
    bool? postQuestionRecapEnabled,
    QuizCatalogTrack? survivalCatalogTrack,
    bool? isMistakesSession,
    bool? isDailyRandom,
    bool? isPoolOnly,
  }) {
    return QuizSession(
      sessionId: sessionId ?? this.sessionId,
      title: title ?? this.title,
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      userScores: userScores != null
          ? List<double?>.from(userScores)
          : List<double?>.from(this.userScores),
      startTime: startTime ?? this.startTime,
      runMode: runMode ?? this.runMode,
      timed: timed ?? this.timed,
      postQuestionRecapEnabled:
          postQuestionRecapEnabled ?? this.postQuestionRecapEnabled,
      survivalCatalogTrack:
          survivalCatalogTrack ?? this.survivalCatalogTrack,
      isMistakesSession: isMistakesSession ?? this.isMistakesSession,
      isDailyRandom: isDailyRandom ?? this.isDailyRandom,
      isPoolOnly: isPoolOnly ?? this.isPoolOnly,
    );
  }
}
