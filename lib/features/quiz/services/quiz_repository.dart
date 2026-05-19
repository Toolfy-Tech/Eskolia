import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/services/asset_cache_service.dart';
import '../../../data/repositories/user_repository.dart';
import '../../labo/data/labo_approved_question_repository.dart';
import '../../labo/data/labo_question_draft.dart';
import '../../parcours/data/parcours_repository.dart';
import '../../parcours/data/tip_quiz_catalog.dart';
import '../models/quiz_models.dart';
import 'revision_pool_repository.dart';

export '../models/quiz_models.dart';

class QuizRepository {
  QuizRepository({UserRepository? userRepository})
      : _userRepository = userRepository ?? UserRepository();

  final UserRepository _userRepository;

  static const String grandFinaleSessionId = 'grand_finale_tip';
  static const String optimusGrandFinaleSessionId = 'grand_finale_optimus';
  static const int grandFinaleOptimusMinQuestions = 40;

  static QuizResultExitDestination resultExitDestination(QuizSession s) {
    if (s.runMode == QuizRunMode.survival) return QuizResultExitDestination.soloMenu;
    if (s.sessionId.startsWith('daily_')) return QuizResultExitDestination.soloMenu;
    return QuizResultExitDestination.parcours;
  }

  Future<QuizSession> loadSession(String sessionId) async {
    try {
      if (sessionId == 'daily' || sessionId.startsWith('daily_')) {
        return await _buildDailyRandomSession();
      }
      final mod = ParcoursRepository.moduleById(sessionId);
      if (mod?.quizAssetPath != null && mod!.quizAssetPath!.isNotEmpty) {
        return await _loadTipAssetSession(
          assetKey: mod.quizAssetPath!,
          sessionId: sessionId,
          title: mod.title,
        );
      }
      return await _buildDailyRandomSession();
    } catch (e) {
      return await _loadTipAssetSession(
        assetKey: 'data/quiz/optimus/section-01-hardware/part-01-fondations.json',
        sessionId: 'fallback',
        title: 'Session de Secours',
      );
    }
  }

  // --- MÉTHODES PUBLIQUES ---

  Future<QuizSession> buildQuickRandomSession({
    int questionCount = 10,
    QuizCatalogTrack catalogTrack = QuizCatalogTrack.optimusOnly,
    bool timed = true,
    dynamic track,
  }) => _buildDailyRandomSession();

  /// Compose une session à partir d'une liste de chemins (assets ou sentinel Labo).
  Future<QuizSession> buildSoloComposeSession({
    required List<String> quizAssetPaths,
    Set<String> difficultyFilters = const {},
    int maxQuestions = 15,
    bool timed = true,
  }) => _buildFromPaths(
        paths: quizAssetPaths,
        maxQuestions: maxQuestions,
        difficultyFilters: difficultyFilters,
        sessionIdPrefix: 'solo',
      );

  /// Même logique, appelé depuis le setup Multi.
  Future<QuizSession> buildMixedSession({
    required List<String> assetPaths,
    String title = 'Quiz personnalisé',
    int maxQuestions = 15,
    bool prioritizeRevisionPool = false,
  }) => _buildFromPaths(
        paths: assetPaths,
        maxQuestions: maxQuestions,
        sessionIdPrefix: 'multi',
      );

  Future<QuizSession> buildSurvivalSession({QuizCatalogTrack? catalogTrack, dynamic track}) =>
      _buildDailyRandomSession();

  Future<QuizSession> buildGapReviewSession({
    int questionCount = 10,
    QuizCatalogTrack? catalogTrack,
    dynamic track,
  }) => _buildDailyRandomSession();

  Future<QuizSession> buildSoloBundleQuizSession({
    required String assetKey,
    required String title,
  }) => _loadTipAssetSession(
        assetKey: assetKey,
        sessionId: 'solo_${assetKey.hashCode}',
        title: title,
      );

  Future<QuizSession> buildSrsDeckQuizSession({
    required List<dynamic> cards,
    int maxQuestions = 20,
  }) => _buildDailyRandomSession();

  Future<QuizSession> buildRevisionPoolSession({
    int maxQuestions = 15,
    String title = 'Révision 📌',
    List<RevisionPoolEntry>? entries,
  }) async {
    if (entries != null && entries.isNotEmpty) {
      final qs = await RevisionPoolRepository().resolveQuestions(entries, max: maxQuestions);
      return _sessionFromQuestions(
        'revision_${DateTime.now().millisecondsSinceEpoch}',
        title,
        qs,
      );
    }
    return _buildDailyRandomSession();
  }

  Future<QuizSession> buildGrandFinaleOptimusSession() => _buildDailyRandomSession();

  Future<QuizSession> buildGrandFinaleSession() => _buildDailyRandomSession();

  Future<void> saveResult(String userId, String sessionId, double score, int total) async {
    final xp = (score * 10).toInt();
    if (xp > 0) await _userRepository.addXp(userId, xp);
    await _userRepository.incrementQuizCompletionStats(userId, passed: (score / total) >= 0.5);
  }

  // --- LOGIQUE INTERNE ---

  /// Construit une session à partir d'une liste de chemins.
  /// Gère les assets JSON standard, le sentinel Labo (Firestore) et les quiz du prof (teacher://).
  Future<QuizSession> _buildFromPaths({
    required List<String> paths,
    int maxQuestions = 15,
    Set<String> difficultyFilters = const {},
    String sessionIdPrefix = 'quiz',
  }) async {
    if (paths.isEmpty) return _buildDailyRandomSession();

    // Quiz du prof — chemin sentinel 'teacher://{quizId}'
    final teacherPath = paths.where((p) => p.startsWith(TipQuizCatalog.teacherSentinelPrefix)).firstOrNull;
    if (teacherPath != null) {
      return _buildTeacherQuizSession(
        quizId: teacherPath.substring(TipQuizCatalog.teacherSentinelPrefix.length),
        maxQuestions: maxQuestions,
        sessionIdPrefix: sessionIdPrefix,
      );
    }

    final questions = <QuizQuestion>[];
    final assetPaths = paths.where((p) => p != TipQuizCatalog.laboSentinelPath).toList();
    final includeLabo = paths.contains(TipQuizCatalog.laboSentinelPath);

    // 1. Charger les assets JSON
    for (final path in assetPaths) {
      try {
        final raw = await AssetCacheService.loadString(path);
        final qs = tipJsonToQuizQuestions(raw, sourceAssetPath: path);
        questions.addAll(qs);
      } catch (_) {}
    }

    // 2. Injecter les questions Labo (Firestore) si demandé
    if (includeLabo) {
      try {
        final cap = LaboApprovedQuestionRepository.capForSession(maxQuestions);
        final sectionIds = LaboApprovedQuestionRepository.sectionIdsFromAssetPaths(assetPaths);
        final drafts = await LaboApprovedQuestionRepository().fetchApprovedDrafts(
          limit: cap * 3,
          restrictToSectionIds: sectionIds.isEmpty ? null : sectionIds,
        );
        for (final d in drafts.take(cap)) {
          questions.add(_laboToQuizQuestion(d));
        }
      } catch (_) {}
    }

    if (questions.isEmpty) return _buildDailyRandomSession();

    // 3. Filtrer par difficulté si demandé
    var filtered = difficultyFilters.isEmpty
        ? questions
        : questions.where((q) => difficultyFilters.contains(q.difficultyBucket)).toList();
    if (filtered.isEmpty) filtered = questions;

    filtered.shuffle();
    final limited = filtered.take(maxQuestions).toList();

    return _sessionFromQuestions(
      '${sessionIdPrefix}_${DateTime.now().millisecondsSinceEpoch}',
      TipQuizCatalog.subjectLabelForPaths(paths),
      limited,
    );
  }

  Future<QuizSession> _buildTeacherQuizSession({
    required String quizId,
    int maxQuestions = 15,
    String sessionIdPrefix = 'quiz',
  }) async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('teacher_quizzes')
          .doc(quizId)
          .get();
      if (!snap.exists) return _buildDailyRandomSession();
      final d = snap.data()!;
      final title = d['title'] as String? ?? 'Quiz du prof';
      final rawQ = d['questions'] as List<dynamic>? ?? [];
      final authorName = d['authorName'] as String? ?? 'Prof';
      final questions = <QuizQuestion>[];
      for (int i = 0; i < rawQ.length; i++) {
        final q = rawQ[i] as Map<String, dynamic>;
        final type = q['type'] as String? ?? 'classic';
        final items = q['items'] is List
            ? List<String>.from(q['items'] as List)
            : <String>[];
        final indices = q['indices'] is List
            ? List<String>.from(q['indices'] as List)
            : <String>[];
        final ctxLine = (q['contextLine'] as String?)?.isNotEmpty == true
            ? q['contextLine'] as String
            : 'Quiz du prof · $title';
        questions.add(QuizQuestion(
          id: 'teacher_${quizId}_$i',
          type: type,
          question: q['question'] as String? ?? '',
          answer: q['answer'] as String? ?? '',
          difficultyBucket: q['difficulty'] as String? ?? 'moyen',
          contextLine: ctxLine,
          explanation: (q['hint'] as String?)?.isNotEmpty == true ? q['hint'] as String : null,
          categoryGroup: QuestionCategoryGroup.themes,
          authorName: authorName,
          indices: indices.isEmpty ? null : indices,
          answerSequence: items.isEmpty ? null : items,
          options: items.isEmpty ? null : items,
        ));
      }
      if (questions.isEmpty) return _buildDailyRandomSession();
      questions.shuffle();
      return _sessionFromQuestions(
        '${sessionIdPrefix}_${DateTime.now().millisecondsSinceEpoch}',
        title,
        questions.take(maxQuestions).toList(),
      );
    } catch (_) {
      return _buildDailyRandomSession();
    }
  }

  QuizQuestion _laboToQuizQuestion(LaboQuestionDraft d) {
    return QuizQuestion(
      id: 'labo_${d.id}',
      type: 'classic',
      question: d.statement,
      answer: d.options.isNotEmpty ? d.options[d.correctIndex.clamp(0, d.options.length - 1)] : '',
      options: d.options,
      explanation: d.explanation,
      sourceAssetPath: TipQuizCatalog.laboSentinelPath,
      difficultyBucket: _parseDifficulty(d.difficulty),
      contextLine: d.sectionHint.isNotEmpty ? 'Section : ${d.sectionHint}' : null,
    );
  }

  Future<QuizSession> _buildDailyRandomSession() async {
    final chapters = [
      'data/quiz/optimus/section-01-hardware/part-01-fondations.json',
      'data/quiz/optimus/section-02-systemes/part-01-concepts-os.json',
      'data/quiz/optimus/section-06-ia/part-02-cas-usage.json',
    ];
    final selectedAsset = chapters[Random().nextInt(chapters.length)];
    return await _loadTipAssetSession(
      assetKey: selectedAsset,
      sessionId: 'daily_${DateTime.now().millisecondsSinceEpoch}',
      title: TipQuizCatalog.fallbackContextLineForAssetPath(selectedAsset) ?? 'Quiz rapide',
    );
  }

  /// Construit une QuizSession depuis un JSON Eskolia genere par l'IA (format Notebook).
  /// Format attendu : {"quiz": {"title": "..."}, "questions": [{...}]}
  Future<QuizSession> buildFromNotebookQuizJson(String rawJson, String title) async {
    try {
      final data = jsonDecode(rawJson) as Map<String, dynamic>;
      final quizMeta = data['quiz'] as Map<String, dynamic>? ?? {};
      final quizTitle = (quizMeta['title'] as String?)?.trim().isEmpty ?? true
          ? title
          : (quizMeta['title'] as String).trim();
      final rawQuestions = data['questions'] as List<dynamic>? ?? [];
      final questions = <QuizQuestion>[];
      for (int i = 0; i < rawQuestions.length; i++) {
        final q = rawQuestions[i] as Map<String, dynamic>;
        final items = q['items'] is List ? List<String>.from(q['items'] as List) : <String>[];
        final indices = q['indices'] is List ? List<String>.from(q['indices'] as List) : <String>[];
        questions.add(QuizQuestion(
          id: 'notebook_${DateTime.now().millisecondsSinceEpoch}_$i',
          type: (q['type'] as String?)?.trim() ?? 'classic',
          question: (q['question'] as String?)?.trim() ?? '',
          answer: (q['answer'] as String?)?.trim() ?? '',
          difficultyBucket: _parseDifficulty(q['difficulty']),
          contextLine: 'Notebook · $quizTitle',
          explanation: ((q['hint'] as String?) ?? '').isNotEmpty ? q['hint'] as String : null,
          indices: indices.isEmpty ? null : indices,
          answerSequence: items.isEmpty ? null : items,
          options: items.isEmpty ? null : items,
          categoryGroup: QuestionCategoryGroup.themes,
        ));
      }
      if (questions.isEmpty) return _buildDailyRandomSession();
      return _sessionFromQuestions(
        'notebook_${DateTime.now().millisecondsSinceEpoch}',
        quizTitle,
        questions,
      );
    } catch (_) {
      return _buildDailyRandomSession();
    }
  }

  Future<QuizSession> _loadTipAssetSession({
    required String assetKey,
    required String sessionId,
    required String title,
  }) async {
    final raw = await AssetCacheService.loadString(assetKey);
    final questions = tipJsonToQuizQuestions(raw, sourceAssetPath: assetKey);
    return _sessionFromQuestions(sessionId, title, questions);
  }

  QuizSession _sessionFromQuestions(String sessionId, String title, List<QuizQuestion> questions) {
    final permuted = List<QuizQuestion>.from(questions)..shuffle();
    return QuizSession(
      sessionId: sessionId,
      title: title,
      questions: permuted,
      currentIndex: 0,
      userScores: List<double?>.filled(permuted.length, null),
      startTime: DateTime.now(),
      runMode: QuizRunMode.standard,
      timed: false,
    );
  }

  static String _parseDifficulty(dynamic raw) {
    final v = raw?.toString().toLowerCase() ?? '';
    // Format Optimus (tier)
    if (v == 'c') return 'facile';
    if (v == 'b') return 'moyen';
    if (v == 'a') return 'difficile';
    // Format normalisé
    if (v == 'facile' || v == 'moyen' || v == 'difficile') return v;
    // Format TIP-Quiz (difficulte)
    if (v.startsWith('debut')) return 'facile';
    if (v.startsWith('interm')) return 'moyen';
    if (v.startsWith('avan') || v.startsWith('expe')) return 'difficile';
    // Format Labo (difficulty)
    if (v == 'easy') return 'facile';
    if (v == 'medium') return 'moyen';
    if (v == 'hard') return 'difficile';
    return 'moyen';
  }

  static List<QuizQuestion> tipJsonToQuizQuestions(String jsonStr, {String? sourceAssetPath}) {
    try {
      final decoded = jsonDecode(jsonStr);
      if (decoded is! List) return [];
      return decoded.map((e) {
        final m = Map<String, dynamic>.from(e);
        return QuizQuestion(
          id: m['id']?.toString() ?? Random().nextInt(10000).toString(),
          type: m['type']?.toString() ?? 'classic',
          question: (m['question'] as String?)?.trim() ?? '',
          answer: m['answer'] is List
              ? (m['answer'] as List).join(', ')
              : (m['answer'] ?? m['reponse'])?.toString() ?? '',
          answerSequence: m['answer'] is List
              ? List<String>.from(m['answer'] as List)
              : null,
          explanation: (m['explanation'] ?? m['comment']) as String?,
          sourceAssetPath: sourceAssetPath,
          options: m['options'] is List ? List<String>.from(m['options']) : null,
          checklist: m['checklist'] is List ? List<String>.from(m['checklist']) : null,
          indices: m['indices'] is List ? List<String>.from(m['indices']) : null,
          contextLine: m['contextLine'] as String? ??
              (m['theme'] != null
                  ? '${m['theme']}${m['sous_theme'] != null ? ' · ${m['sous_theme']}' : ''}'
                  : null),
          // Supporte les formats : difficultyBucket (Optimus), tier (Optimus), difficulte (TIP-Quiz)
          difficultyBucket: _parseDifficulty(
            m['difficultyBucket'] ?? m['tier'] ?? m['difficulte'],
          ),
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }
}
