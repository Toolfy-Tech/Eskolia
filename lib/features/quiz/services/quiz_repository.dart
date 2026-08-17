import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/asset_cache_service.dart';
import '../../../data/repositories/user_repository.dart';
import '../../labo/data/labo_approved_question_repository.dart';
import '../../labo/data/labo_question_draft.dart';
import '../../lexique/data/lexique_data.dart';
import '../../parcours/data/parcours_repository.dart';
import '../../parcours/data/optimus_content_models.dart' as ocm;
import '../../parcours/data/tip_quiz_catalog.dart';
import '../../parcours/data/tip_catalog_loader.dart';
import '../models/quiz_models.dart';
import 'revision_pool_repository.dart';
import 'lacunes_repository.dart';

export '../models/quiz_models.dart';

final quizRepositoryProvider = Provider<QuizRepository>((ref) {
  final userRepo = ref.watch(userRepositoryProvider);
  return QuizRepository(userRepository: userRepo);
});

class QuizRepository {
  QuizRepository({UserRepository? userRepository})
      : _userRepository = userRepository ?? UserRepository();

  final UserRepository _userRepository;

  static const String grandFinaleSessionId = 'grand_finale_tip';
  static const String optimusGrandFinaleSessionId = 'grand_finale_optimus';
  static const int grandFinaleOptimusMinQuestions = 40;
  static const String lexiqueSentinelPrefix = 'lexique://';

  static QuizResultExitDestination resultExitDestination(QuizSession s) {
    if (s.runMode == QuizRunMode.survival) return QuizResultExitDestination.soloMenu;
    if (s.sessionId.startsWith('daily_') ||
        s.sessionId.startsWith('solo_') ||
        s.sessionId.startsWith('ai_') ||
        s.sessionId.startsWith('exam_') ||
        s.sessionId.startsWith('notebook_') ||
        s.sessionId.startsWith('mistakes_') ||
        s.sessionId.startsWith('custom_') ||
        s.sessionId.startsWith('flashcards_')) {
      return QuizResultExitDestination.soloMenu;
    }
    return QuizResultExitDestination.parcours;
  }

  Future<QuizSession> loadSession(String sessionId) async {
    try {
      if (sessionId == 'daily' || sessionId.startsWith('daily_')) {
        return await _buildDailyRandomSession();
      }
      if (ParcoursRepository.moduleCatalog.isEmpty) {
        final base = await TipCatalogLoader.loadOptimusFormation();
        ParcoursRepository.registerModules(base);
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
      debugPrint('[QuizRepository.loadSession] sessionId=$sessionId erreur=$e');
      return await _loadTipAssetSession(
        assetKey: 'data/quiz/optimus/module-02-hardware-architecture/M02-CH01-Q-boitiers.quiz.json',
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
  }) async {
    final allChapters = await TipQuizCatalog.loadChaptersWithQuiz();
    final filtered = TipQuizCatalog.filterByTrack(allChapters, catalogTrack);
    final targetChapters = filtered.isNotEmpty ? filtered : allChapters;
    final paths = targetChapters.map((c) => c.quizAssetPath).toList();
    final session = await _buildFromPaths(
      paths: paths,
      maxQuestions: questionCount,
      sessionIdPrefix: 'quick',
    );
    return session.copyWith(timed: timed);
  }

  /// Compose une session à partir d'une liste de chemins (assets ou sentinel Labo/Lexique).
  Future<QuizSession> buildSoloComposeSession({
    required List<String> quizAssetPaths,
    Set<String> difficultyFilters = const {},
    Set<String> typeFilters = const {},
    int maxQuestions = 15,
    bool timed = true,
  }) => _buildFromPaths(
        paths: quizAssetPaths,
        maxQuestions: maxQuestions,
        difficultyFilters: difficultyFilters,
        typeFilters: typeFilters,
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

  Future<QuizSession> buildSurvivalSession({QuizCatalogTrack? catalogTrack, dynamic track}) async {
    final allChapters = await TipQuizCatalog.loadChaptersWithQuiz();
    final filtered = catalogTrack != null
        ? TipQuizCatalog.filterByTrack(allChapters, catalogTrack)
        : allChapters;
    final targetChapters = filtered.isNotEmpty ? filtered : allChapters;
    final paths = targetChapters.map((c) => c.quizAssetPath).toList();
    final session = await _buildFromPaths(
      paths: paths,
      maxQuestions: 50,
      sessionIdPrefix: 'survival',
    );
    return session.copyWith(runMode: QuizRunMode.survival, timed: false);
  }

  Future<QuizSession> buildGapReviewSession({
    int questionCount = 10,
    QuizCatalogTrack? catalogTrack,
    dynamic track,
  }) async {
    final lacunesRepo = LacunesRepository();
    final entries = await lacunesRepo.readEntries();
    if (entries.isNotEmpty) {
      final qs = await lacunesRepo.resolveQuestions(entries, max: questionCount);
      if (qs.isNotEmpty) {
        return _sessionFromQuestions(
          'gap_review_${DateTime.now().millisecondsSinceEpoch}',
          'Mes fautes',
          qs,
        );
      }
    }
    return _buildDailyRandomSession();
  }

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

  Future<QuizSession> buildLacunesSession({
    int maxQuestions = 15,
    String title = 'Mes fautes ❌',
    List<RevisionPoolEntry>? entries,
  }) async {
    if (entries != null && entries.isNotEmpty) {
      final qs = await LacunesRepository().resolveQuestions(entries, max: maxQuestions);
      return _sessionFromQuestions(
        'lacunes_rev_${DateTime.now().millisecondsSinceEpoch}',
        title,
        qs,
      );
    }
    return _buildDailyRandomSession();
  }

  Future<QuizSession> buildGrandFinaleOptimusSession() async {
    final allChapters = await TipQuizCatalog.loadChaptersWithQuiz();
    final paths = allChapters.map((c) => c.quizAssetPath).toList();
    return _buildFromPaths(
      paths: paths,
      maxQuestions: 40,
      sessionIdPrefix: optimusGrandFinaleSessionId,
    );
  }

  Future<QuizSession> buildGrandFinaleSession() async {
    final allChapters = await TipQuizCatalog.loadChaptersWithQuiz();
    final paths = allChapters.map((c) => c.quizAssetPath).toList();
    return _buildFromPaths(
      paths: paths,
      maxQuestions: 40,
      sessionIdPrefix: grandFinaleSessionId,
    );
  }

  Future<void> saveResult(String userId, String sessionId, double score, int total) async {
    final xp = (score * 10).toInt();
    if (xp > 0) await _userRepository.addXp(userId, xp);
    await _userRepository.incrementQuizCompletionStats(userId, passed: (score / total) >= 0.5);
  }

  // --- LOGIQUE INTERNE ---

  /// Construit une session à partir d'une liste de chemins.
  /// Gère les assets JSON standard, Labo (Firestore), teacher://, lexique://.
  Future<QuizSession> _buildFromPaths({
    required List<String> paths,
    int maxQuestions = 15,
    Set<String> difficultyFilters = const {},
    Set<String> typeFilters = const {},
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
    final lexiquePaths = paths.where((p) => p.startsWith(lexiqueSentinelPrefix)).toList();
    final assetPaths = paths.where((p) =>
        p != TipQuizCatalog.laboSentinelPath &&
        !p.startsWith(lexiqueSentinelPrefix)).toList();
    final includeLabo = paths.contains(TipQuizCatalog.laboSentinelPath);

    // 1. Charger les assets JSON
    for (final path in assetPaths) {
      try {
        final raw = await AssetCacheService.loadString(path);
        final qs = tipJsonToQuizQuestions(raw, sourceAssetPath: path);
        questions.addAll(qs);
      } catch (e) {
        debugPrint('[QuizRepository._buildFromPaths] $e');
      }
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
      } catch (e) {
        debugPrint('[QuizRepository._buildFromPaths.labo] $e');
      }
    }

    // 3. Injecter les questions Lexique si demandé
    if (lexiquePaths.isNotEmpty) {
      final List<LexiqueEntry> dynamicEntries = [];
      try {
        final allModuleLexique = await ocm.OptimusLexiqueRepository.loadAll();
        for (final m in allModuleLexique) {
          final String cat;
          switch (m.moduleId) {
            case 'M01':
            case 'M05':
            case 'M08':
              cat = 'metier';
              break;
            case 'M02':
              cat = 'materiel';
              break;
            case 'M03':
              cat = 'materiel';
              break;
            case 'M04':
              cat = 'reseau';
              break;
            case 'M06':
              cat = 'windows';
              break;
            case 'M07':
              cat = 'securite';
              break;
            default:
              cat = 'metier';
          }
          for (final term in m.terms) {
            dynamicEntries.add(LexiqueEntry(
              term: term.term,
              definition: term.definition,
              category: cat,
            ));
          }
        }
      } catch (e) {
        debugPrint('[QuizRepository.buildSoloComposeSession.lexique] $e');
      }

      for (final lp in lexiquePaths) {
        final key = lp.replaceFirst(lexiqueSentinelPrefix, '');
        questions.addAll(_lexiqueToQuizQuestions(key, dynamicEntries));
      }
    }

    if (questions.isEmpty) return _buildDailyRandomSession();

    // 4. Filtrer par difficulté
    var filtered = difficultyFilters.isEmpty
        ? questions
        : questions.where((q) => difficultyFilters.contains(q.difficultyBucket)).toList();
    if (filtered.isEmpty) filtered = questions;

    // 5. Filtrer par type de question
    if (typeFilters.isNotEmpty) {
      final byType = filtered.where((q) => typeFilters.contains(q.type)).toList();
      if (byType.isNotEmpty) filtered = byType;
    }

    // Échantillonnage équitable par type de question
    final groupedByType = <String, List<QuizQuestion>>{};
    for (final q in filtered) {
      groupedByType.putIfAbsent(q.type, () => []).add(q);
    }
    for (final list in groupedByType.values) {
      list.shuffle();
    }

    final limited = <QuizQuestion>[];
    final types = groupedByType.keys.toList()..shuffle();
    int typeIndex = 0;
    while (limited.length < maxQuestions && groupedByType.values.any((l) => l.isNotEmpty)) {
      final currentType = types[typeIndex % types.length];
      final list = groupedByType[currentType];
      if (list != null && list.isNotEmpty) {
        limited.add(list.removeLast());
      }
      typeIndex++;
    }
    limited.shuffle();

    final nonLexiquePaths = paths.where((p) => !p.startsWith(lexiqueSentinelPrefix)).toList();
    final title = nonLexiquePaths.isNotEmpty
        ? TipQuizCatalog.subjectLabelForPaths(nonLexiquePaths)
        : 'Lexique TIP';

    return _sessionFromQuestions(
      '${sessionIdPrefix}_${DateTime.now().millisecondsSinceEpoch}',
      title,
      limited,
    );
  }

  static List<QuizQuestion> _lexiqueToQuizQuestions(String categoryKey, List<LexiqueEntry> dynamicEntries) {
    final combined = [...allLexique, ...dynamicEntries];
    final seen = <String>{};
    final unique = <LexiqueEntry>[];
    for (final e in combined) {
      final normalized = e.term.trim().toLowerCase();
      if (!seen.contains(normalized)) {
        seen.add(normalized);
        unique.add(e);
      }
    }

    final entries = categoryKey == 'all'
        ? unique
        : unique.where((e) => e.category == categoryKey).toList();
    return entries.map((e) {
      final catName = lexiqueCategories
          .where((c) => c.key == e.category)
          .map((c) => c.name)
          .firstOrNull ?? 'Lexique';
      return QuizQuestion(
        id: 'lex_${e.term.toLowerCase().replaceAll(' ', '_')}',
        type: 'classic',
        question: 'Définis ce terme : ${e.term}',
        answer: e.definition,
        difficultyBucket: 'facile',
        contextLine: 'Lexique · $catName',
        categoryGroup: QuestionCategoryGroup.themes,
      );
    }).toList();
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
      final d = snap.data();
      if (!snap.exists || d == null) return _buildDailyRandomSession();
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
          matchPairs: _parsePairs(q['pairs']),
        ));
      }
      if (questions.isEmpty) return _buildDailyRandomSession();
      questions.shuffle();
      return _sessionFromQuestions(
        '${sessionIdPrefix}_${DateTime.now().millisecondsSinceEpoch}',
        title,
        questions.take(maxQuestions).toList(),
      );
    } catch (e) {
      debugPrint('[QuizRepository._buildTeacherQuizSession] $e');
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
    final allChapters = await TipQuizCatalog.loadChaptersWithQuiz();
    if (allChapters.isEmpty) {
      return await _loadTipAssetSession(
        assetKey: 'data/quiz/optimus/module-02-hardware-architecture/M02-CH01-Q-boitiers.quiz.json',
        sessionId: 'daily_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Quiz rapide',
      );
    }
    final assetChapters = allChapters
        .where((c) =>
            !c.quizAssetPath.startsWith('labo://') &&
            !c.quizAssetPath.startsWith('teacher://'))
        .toList();
    final target = assetChapters.isNotEmpty
        ? assetChapters[Random().nextInt(assetChapters.length)]
        : allChapters.first;
    return await _loadTipAssetSession(
      assetKey: target.quizAssetPath,
      sessionId: 'daily_${DateTime.now().millisecondsSinceEpoch}',
      title: TipQuizCatalog.contextLineForChapter(target),
    );
  }

  /// Construit une QuizSession depuis un JSON Eskolia genere par l'IA (format Notebook).
  /// Format attendu : {"quiz": {"title": "..."}, "questions": [{...}]}
  /// Parse un JSON genere par l'IA (format Eskolia) en QuizSession.
  /// Lance une [FormatException] si le JSON est invalide ou le schema incorrect.
  Future<QuizSession> buildFromNotebookQuizJson(String rawJson, String title) async {
    final Map<String, dynamic> data;
    try {
      data = jsonDecode(rawJson) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('[QuizRepository.buildFromNotebookQuizJson] $e');
      throw FormatException('Le JSON genere est mal forme. Regenere le quiz.');
    }

    final rawQuestions = data['questions'];
    if (rawQuestions is! List || rawQuestions.isEmpty) {
      throw const FormatException('Aucune question trouvee dans le quiz genere. Regenere le quiz.');
    }

    final quizMeta  = data['quiz'] as Map<String, dynamic>? ?? {};
    final rawTitle  = (quizMeta['title'] as String?)?.trim() ?? '';
    final quizTitle = rawTitle.isEmpty ? title : rawTitle;

    final questions = <QuizQuestion>[];
    for (int i = 0; i < rawQuestions.length; i++) {
      final q = rawQuestions[i];
      if (q is! Map<String, dynamic>) continue;

      final question = (q['question'] as String?)?.trim() ?? '';
      var   answer   = (q['answer'] as String?)?.trim() ?? '';

      var options = q['options'] is List
          ? (q['options'] as List).map((e) => e.toString().trim()).where((s) => s.isNotEmpty).toList()
          : <String>[];

      if (answer.isEmpty && options.isNotEmpty) {
        int cIdx = 0;
        if (q['correctAnswerIndex'] is num) {
          cIdx = (q['correctAnswerIndex'] as num).toInt();
        } else if (q['correct_answer_index'] is num) {
          cIdx = (q['correct_answer_index'] as num).toInt();
        }
        if (cIdx >= 0 && cIdx < options.length) {
          answer = options[cIdx];
        } else {
          answer = options.first;
        }
      }

      if (question.isEmpty || answer.isEmpty) continue;

      var   items   = q['items']   is List ? List<String>.from(q['items']   as List) : <String>[];
      final indices = q['indices'] is List ? List<String>.from(q['indices'] as List) : <String>[];
      var   rawType = (q['type'] as String?)?.trim() ?? (options.length >= 2 ? 'qcm' : 'classic');

      // If AI declared 'sequence' but forgot items, try to extract from numbered answer.
      if (rawType == 'sequence' && items.isEmpty) {
        final extracted = _extractNumberedList(answer);
        if (extracted.length >= 2) {
          items = extracted;
        } else {
          rawType = 'classic';
        }
      }

      // If AI declared 'diagnostic_indices' but forgot indices, downgrade.
      if (rawType == 'diagnostic_indices' && indices.isEmpty) {
        rawType = 'classic';
      }

      // If AI declared 'association' but forgot pairs, downgrade.
      final rawPairs = _parsePairs(q['pairs']);
      if (rawType == 'association' && (rawPairs == null || rawPairs.isEmpty)) {
        rawType = 'classic';
      }

      final explanationText = ((q['explanation'] as String?) ?? (q['hint'] as String?) ?? '').trim();

      questions.add(QuizQuestion(
        id: (q['id'] as String?) ?? 'notebook_${DateTime.now().millisecondsSinceEpoch}_$i',
        type: rawType,
        question: question,
        answer: answer,
        difficultyBucket: _parseDifficulty(q['difficulty']),
        contextLine: 'Notebook · $quizTitle',
        explanation: explanationText.isNotEmpty ? explanationText : null,
        indices: indices.isEmpty ? null : indices,
        answerSequence: items.isEmpty ? null : items,
        options: options.isNotEmpty ? options : (items.isNotEmpty ? items : null),
        matchPairs: rawPairs,
        categoryGroup: QuestionCategoryGroup.themes,
      ));
    }

    if (questions.isEmpty) {
      throw const FormatException('Toutes les questions sont invalides. Regenere le quiz.');
    }

    return _sessionFromQuestions(
      'notebook_${DateTime.now().millisecondsSinceEpoch}',
      quizTitle,
      questions,
    );
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

  static List<List<String>>? _parsePairs(dynamic raw) {
    if (raw is! List) return null;
    final result = <List<String>>[];
    for (final item in raw) {
      if (item is Map) {
        final left = item['left']?.toString() ?? '';
        final right = item['right']?.toString() ?? '';
        if (left.isNotEmpty && right.isNotEmpty) result.add([left, right]);
      } else if (item is List && item.length >= 2) {
        result.add([item[0].toString(), item[1].toString()]);
      }
    }
    return result.isEmpty ? null : result;
  }

  /// Extracts ordered items from a numbered list in `text` (e.g. "1. Foo\n2. Bar").
  static List<String> _extractNumberedList(String text) {
    final pattern = RegExp(r'^\d+[.)]\s*(.+)$', multiLine: true);
    return pattern.allMatches(text).map((m) => m.group(1)!.trim()).where((s) => s.isNotEmpty).toList();
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
      final List<dynamic> list;
      String? quizTitle;

      if (decoded is List) {
        list = decoded;
      } else if (decoded is Map<String, dynamic>) {
        if (decoded['questions'] is List) {
          list = decoded['questions'] as List<dynamic>;
          quizTitle = decoded['quiz']?['title'] as String?;
        } else {
          return [];
        }
      } else {
        return [];
      }

      return list.map((e) {
        final m = Map<String, dynamic>.from(e);
        final rawAnswer = m['answer'] ?? m['reponse'];
        final answerStr = rawAnswer is List
            ? rawAnswer.join(', ')
            : (rawAnswer?.toString() ?? '');

        List<String>? seq;
        if (m['answerSequence'] is List) {
          seq = List<String>.from(m['answerSequence']);
        } else if (m['items'] is List) {
          seq = List<String>.from(m['items']);
        } else if (m['sequence'] is List) {
          seq = List<String>.from(m['sequence']);
        } else if (rawAnswer is List) {
          seq = List<String>.from(rawAnswer);
        }

        final pairs = _parsePairs(m['pairs'] ?? m['matchPairs'] ?? m['matches']);
        final checklist = m['checklist'] is List
            ? List<String>.from(m['checklist'])
            : (m['actions'] is List ? List<String>.from(m['actions']) : null);
        final indices = m['indices'] is List
            ? List<String>.from(m['indices'])
            : (m['hints'] is List ? List<String>.from(m['hints']) : null);

        final rawDiff = m['difficultyBucket'] ?? m['tier'] ?? m['difficulte'] ?? m['difficulty'];

        return QuizQuestion(
          id: m['id']?.toString() ?? Random().nextInt(10000).toString(),
          type: m['type']?.toString() ?? 'classic',
          question: (m['question'] as String?)?.trim() ?? '',
          answer: answerStr,
          answerSequence: seq,
          matchPairs: pairs,
          explanation: (m['explanation'] ?? m['comment'] ?? m['hint']) as String?,
          sourceAssetPath: sourceAssetPath,
          options: m['options'] is List
              ? List<String>.from(m['options'])
              : (seq != null ? List<String>.from(seq) : null),
          checklist: checklist,
          indices: indices,
          contextLine: m['contextLine'] as String? ??
              (m['context'] as String? ??
                  (m['theme'] != null
                      ? '${m['theme']}${m['sous_theme'] != null ? ' · ${m['sous_theme']}' : ''}'
                      : (quizTitle != null ? 'Examen Blanc · $quizTitle' : null))),
          difficultyBucket: _parseDifficulty(rawDiff),
        );
      }).where((q) => q.question.isNotEmpty && q.answer.isNotEmpty).toList();
    } catch (e) {
      debugPrint('[QuizRepository.tipJsonToQuizQuestions] $e');
      return [];
    }
  }
}
