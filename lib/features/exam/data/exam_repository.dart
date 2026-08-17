import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/asset_cache_service.dart';
import '../../quiz/models/quiz_models.dart';
import 'exam_model.dart';

class ExamRepository {
  ExamRepository._();
  static final ExamRepository instance = ExamRepository._();

  static const String _scorePrefix = 'exam_score_';
  static const String _completedPrefix = 'exam_completed_';

  /// Charge toutes les épreuves d'examens blancs depuis data/exam/
  Future<List<ExamQuizItem>> loadAllExams() async {
    final List<ExamQuizItem> list = [];
    try {
      List<String> examAssets = [];
      try {
        final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
        examAssets = manifest.listAssets().where((path) =>
            path.startsWith('data/exam/') && path.endsWith('.json')).toList();
      } catch (_) {}

      if (examAssets.isEmpty) {
        examAssets = [
          'data/exam/exam01.json',
          'data/exam/exam02.json',
          'data/exam/exam03.json',
          'data/exam/exam04.json',
          'data/exam/exam05.json',
          'data/exam/exam06.json',
          'data/exam/exam07.json',
          'data/exam/exam08.json',
        ];
      }

      examAssets.sort();

      SharedPreferences? prefs;
      try {
        prefs = await SharedPreferences.getInstance();
      } catch (_) {}

      for (int i = 0; i < examAssets.length; i++) {
        final assetPath = examAssets[i];
        try {
          final raw = await AssetCacheService.loadString(assetPath);
          final parsed = _parseExamJson(raw, assetPath, fallbackIndex: i + 1);
          if (parsed != null && parsed.questions.isNotEmpty) {
            final bestScore = prefs?.getDouble('$_scorePrefix${parsed.id}');
            final isCompleted = prefs?.getBool('$_completedPrefix${parsed.id}') ?? (bestScore != null);
            list.add(parsed.copyWith(
              bestScore: bestScore,
              isCompleted: isCompleted,
            ));
          }
        } catch (e) {
          debugPrint('[ExamRepository.loadAllExams] Error loading $assetPath: $e');
        }
      }
    } catch (e) {
      debugPrint('[ExamRepository.loadAllExams] Manifest error: $e');
    }

    return list;
  }

  /// Construit la session de quiz non chronométrée pour l'examen blanc
  QuizSession buildExamSession(ExamQuizItem exam) {
    return QuizSession(
      sessionId: 'exam_${exam.id}',
      title: exam.title,
      questions: exam.questions,
      currentIndex: 0,
      userScores: List<double?>.filled(exam.questions.length, null),
      startTime: DateTime.now(),
      runMode: QuizRunMode.standard,
      timed: false, // Non chronométré selon la demande
    );
  }

  /// Enregistre le score obtenu à un examen blanc
  Future<void> saveExamScore(String examId, double scorePercent) async {
    final prefs = await SharedPreferences.getInstance();
    final currentBest = prefs.getDouble('$_scorePrefix$examId') ?? 0.0;
    if (scorePercent > currentBest) {
      await prefs.setDouble('$_scorePrefix$examId', scorePercent);
    }
    await prefs.setBool('$_completedPrefix$examId', true);
  }

  /// Réinitialise les scores des examens si besoin
  Future<void> resetExamProgress(String examId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_scorePrefix$examId');
    await prefs.remove('$_completedPrefix$examId');
  }

  ExamQuizItem? _parseExamJson(String raw, String assetPath, {required int fallbackIndex}) {
    try {
      final dynamic decoded = jsonDecode(raw);
      String title = 'Épreuve Blanche $fallbackIndex';
      String description = 'Épreuve d\'entraînement en conditions réelles';
      String author = 'Eskolia';
      String category = 'Examen Blanc';
      String id = assetPath.split('/').last.replaceAll('.json', '');

      final List<QuizQuestion> questions = [];

      if (decoded is Map<String, dynamic>) {
        // Format avec objet 'quiz'
        if (decoded['quiz'] is Map) {
          final qm = decoded['quiz'] as Map<String, dynamic>;
          title = qm['title']?.toString() ?? title;
          description = qm['description']?.toString() ?? description;
          author = qm['author']?.toString() ?? author;
          category = qm['category']?.toString() ?? category;
        } else {
          title = decoded['title']?.toString() ?? title;
          description = decoded['description']?.toString() ?? description;
        }

        final rawQuestions = decoded['questions'];
        if (rawQuestions is List) {
          for (int i = 0; i < rawQuestions.length; i++) {
            final q = rawQuestions[i];
            if (q is Map<String, dynamic>) {
              final parsedQ = _mapToQuizQuestion(q, id, i + 1, title, author);
              if (parsedQ != null) questions.add(parsedQ);
            }
          }
        }
      } else if (decoded is List) {
        // Format tableau direct
        for (int i = 0; i < decoded.length; i++) {
          final q = decoded[i];
          if (q is Map<String, dynamic>) {
            final parsedQ = _mapToQuizQuestion(q, id, i + 1, title, author);
            if (parsedQ != null) questions.add(parsedQ);
          }
        }
      }

      return ExamQuizItem(
        id: id,
        title: title,
        description: description,
        author: author,
        category: category,
        assetPath: assetPath,
        questions: questions,
      );
    } catch (e) {
      debugPrint('[ExamRepository._parseExamJson] $e');
      return null;
    }
  }

  QuizQuestion? _mapToQuizQuestion(
    Map<String, dynamic> q,
    String examId,
    int index,
    String examTitle,
    String authorName,
  ) {
    final questionText = q['question']?.toString().trim() ?? '';
    final answerText = q['answer']?.toString().trim() ?? '';
    if (questionText.isEmpty || answerText.isEmpty) return null;

    final type = q['type']?.toString().trim().toLowerCase() ?? 'classic';
    final difficulty = q['difficulty']?.toString().trim().toLowerCase() ?? 'moyen';
    final explanation = q['explanation']?.toString().trim() ??
        q['comment']?.toString().trim() ??
        q['hint']?.toString().trim();
    final contextLine = q['context']?.toString().trim() ??
        q['contextLine']?.toString().trim() ??
        'Examen Blanc · $examTitle';

    // Indices
    final rawIndices = q['indices'] ?? q['hints'];
    List<String>? indices;
    if (rawIndices is List && rawIndices.isNotEmpty) {
      indices = rawIndices.map((e) => e.toString().trim()).where((s) => s.isNotEmpty).toList();
    }

    // Séquence items
    final rawItems = q['items'] ?? q['sequence'];
    List<String>? items;
    if (rawItems is List && rawItems.isNotEmpty) {
      items = rawItems.map((e) => e.toString().trim()).where((s) => s.isNotEmpty).toList();
    }

    // Paires association
    final rawPairs = q['pairs'] ?? q['matchPairs'] ?? q['matches'];
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
      if (parsedPairs.isNotEmpty) pairs = parsedPairs;
    }

    // Checklist ticket
    final rawChecklist = q['checklist'] ?? q['actions'];
    List<String>? checklist;
    if (rawChecklist is List && rawChecklist.isNotEmpty) {
      checklist = rawChecklist.map((e) => e.toString().trim()).where((s) => s.isNotEmpty).toList();
    }

    return QuizQuestion(
      id: q['id']?.toString() ?? 'exam_${examId}_$index',
      type: type,
      question: questionText,
      answer: answerText,
      explanation: explanation,
      difficultyBucket: difficulty,
      contextLine: contextLine,
      categoryGroup: QuestionCategoryGroup.themes,
      authorName: authorName,
      indices: indices,
      answerSequence: items,
      matchPairs: pairs,
      checklist: checklist,
    );
  }
}
