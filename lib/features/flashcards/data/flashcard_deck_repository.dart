import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/asset_cache_service.dart';

import '../../parcours/data/tip_quiz_catalog.dart';
import '../../quiz/services/quiz_repository.dart';
import '../../quiz/services/revision_pool_repository.dart';

enum FlashcardGrade {
  /// Je savais pas — blueprint v3
  forgot,

  /// Presque
  almost,

  /// Je savais
  knew,
}

/// Carte du paquet persistant (SRS léger type Anki, 5 niveaux 0–4).
@immutable
class DeckFlashcard {
  const DeckFlashcard({
    required this.id,
    required this.front,
    required this.back,
    this.sourceKey,
    required this.mastery,
    required this.nextDue,
  });

  final String id;
  final String front;
  final String back;
  final String? sourceKey;
  final int mastery;
  final DateTime nextDue;

  DeckFlashcard copyWith({
    String? id,
    String? front,
    String? back,
    String? sourceKey,
    bool clearSourceKey = false,
    int? mastery,
    DateTime? nextDue,
  }) {
    return DeckFlashcard(
      id: id ?? this.id,
      front: front ?? this.front,
      back: back ?? this.back,
      sourceKey: clearSourceKey ? null : (sourceKey ?? this.sourceKey),
      mastery: mastery ?? this.mastery,
      nextDue: nextDue ?? this.nextDue,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'f': front,
        'b': back,
        if (sourceKey != null && sourceKey!.isNotEmpty) 'k': sourceKey,
        'm': mastery,
        'd': nextDue.toIso8601String(),
      };

  static DeckFlashcard? fromJson(Map<String, dynamic> m) {
    final id = m['id'] as String?;
    final f = m['f'] as String?;
    final b = m['b'] as String?;
    if (id == null || f == null || b == null) return null;
    final d = DateTime.tryParse(m['d'] as String? ?? '') ?? DateTime.now();
    return DeckFlashcard(
      id: id,
      front: f,
      back: b,
      sourceKey: m['k'] as String?,
      mastery: (m['m'] as num?)?.toInt() ?? 0,
      nextDue: d,
    );
  }

  static DeckFlashcard applyGrade(DeckFlashcard c, FlashcardGrade g) {
    final now = DateTime.now();
    switch (g) {
      case FlashcardGrade.knew:
        if (c.mastery >= 4) {
          return c.copyWith(nextDue: now.add(const Duration(days: 14)));
        }
        final newM = c.mastery + 1;
        const stepDays = [1, 2, 4, 7];
        final days = stepDays[newM - 1];
        return c.copyWith(
          mastery: newM,
          nextDue: now.add(Duration(days: days)),
        );
      case FlashcardGrade.almost:
        return c.copyWith(nextDue: now.add(const Duration(days: 1)));
      case FlashcardGrade.forgot:
        return c.copyWith(
          mastery: max(0, c.mastery - 1),
          nextDue: now.add(const Duration(days: 1)),
        );
    }
  }

  static String sourceKeyForQuestion(QuizQuestion q, int indexInFile) {
    final k = RevisionPoolRepository.keyForQuestion(q, indexInFile);
    if (k.isEmpty) return 'q|${q.question.hashCode}';
    return 'deck|$k';
  }
}

/// Paquet local — `blueprint v3` flashcards + pool révision.
class FlashcardDeckRepository {
  FlashcardDeckRepository();

  static const _key = 'eskolia_flashcard_deck_v1';

  static String _newId() {
    return 'fc_${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(1 << 30)}';
  }

  Future<List<DeckFlashcard>> readAll() async {
    final p = await SharedPreferences.getInstance();
    final s = p.getString(_key);
    if (s == null || s.isEmpty) return [];
    try {
      final list = jsonDecode(s) as List<dynamic>;
      final out = <DeckFlashcard>[];
      for (final e in list) {
        if (e is Map) {
          final c = DeckFlashcard.fromJson(Map<String, dynamic>.from(e));
          if (c != null) out.add(c);
        }
      }
      return out;
    } catch (_) {
      return [];
    }
  }

  Future<void> _write(List<DeckFlashcard> list) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(
      _key,
      jsonEncode(list.map((e) => e.toJson()).toList()),
    );
  }

  Future<int> countDue() async {
    final now = DateTime.now();
    var n = 0;
    for (final c in await readAll()) {
      if (!c.nextDue.isAfter(now)) n++;
    }
    return n;
  }

  Future<List<DeckFlashcard>> dueCards() async {
    final now = DateTime.now();
    return (await readAll()).where((c) => !c.nextDue.isAfter(now)).toList();
  }

  Future<void> upsert(DeckFlashcard card) async {
    final cur = await readAll();
    final i = cur.indexWhere((x) => x.id == card.id);
    if (i >= 0) {
      cur[i] = card;
    } else {
      cur.add(card);
    }
    await _write(cur);
  }

  Future<void> replaceAll(List<DeckFlashcard> list) => _write(list);

  /// Ajoute depuis une question QCM (évite doublon [sourceKey]).
  Future<bool> addFromQuizQuestion(QuizQuestion q) async {
    final a = q.sourceAssetPath;
    if (a == null || a.isEmpty) return false;
    var idxInFile = 0;
    if (q.id.isEmpty) {
      try {
        final raw = await AssetCacheService.loadString(a);
        final qs = QuizRepository.tipJsonToQuizQuestions(raw, sourceAssetPath: a);
        final found = qs.indexWhere((x) => x.question == q.question);
        idxInFile = found >= 0 ? found : 0;
      } catch (_) {}
    }
    final sk = DeckFlashcard.sourceKeyForQuestion(q, idxInFile);
    final cur = await readAll();
    if (cur.any((x) => x.sourceKey == sk)) return false;
    final back = StringBuffer(q.answer);
    if (q.explanation != null && q.explanation!.trim().isNotEmpty) {
      back.write('\n\n${q.explanation!.trim()}');
    }
    final card = DeckFlashcard(
      id: _newId(),
      front: q.question.trim(),
      back: back.toString(),
      sourceKey: sk,
      mastery: 0,
      nextDue: DateTime.now(),
    );
    await _write([...cur, card]);
    return true;
  }

  /// 10 cartes éphémères depuis le catalogue questions (mode rapide).
  Future<List<DeckFlashcard>> buildEphemeralQuickSet({
    int count = 10,
    QuizCatalogTrack catalogTrack = QuizCatalogTrack.optimusOnly,
  }) async {
    final session = await QuizRepository().buildQuickRandomSession(
      questionCount: count * 3,
      catalogTrack: catalogTrack,
    );
    return _questionsToEphemeralCards(
      session.questions,
      idPrefix: 'ephem',
      count: count,
    );
  }

  /// **Flashcards solo** : mêmes filtres que [QuizRepository.buildSoloComposeSession].
  Future<List<DeckFlashcard>> buildEphemeralSoloComposeSet({
    required List<String> quizAssetPaths,
    required Set<String> difficultyFilters,
    int maxCards = 15,
  }) async {
    final session = await QuizRepository().buildSoloComposeSession(
      quizAssetPaths: quizAssetPaths,
      difficultyFilters: difficultyFilters,
      maxQuestions: maxCards,
    );
    return _questionsToEphemeralCards(
      session.questions,
      idPrefix: 'solo_fc',
      count: session.questions.length,
    );
  }

  /// Cartes éphémères 1:1 depuis des [QuizQuestion] (ex. pool 📌 déjà résolu).
  List<DeckFlashcard> buildEphemeralFromQuizQuestions(
    List<QuizQuestion> questions, {
    bool shuffle = true,
  }) {
    if (questions.isEmpty) {
      throw StateError('Aucune question pour les flashcards.');
    }
    return _questionsToEphemeralCards(
      questions,
      idPrefix: 'rev_fc',
      count: questions.length,
      shuffleQuestions: shuffle,
    );
  }

  List<DeckFlashcard> _questionsToEphemeralCards(
    List<QuizQuestion> questions, {
    required String idPrefix,
    int count = 10,
    bool shuffleQuestions = true,
  }) {
    final out = <DeckFlashcard>[];
    final work = List<QuizQuestion>.from(questions);
    if (shuffleQuestions) work.shuffle(Random());
    for (final q in work) {
      if (out.length >= count) break;
      final back = StringBuffer(q.answer);
      if (q.explanation != null && q.explanation!.trim().isNotEmpty) {
        back.write('\n\n${q.explanation!.trim()}');
      }
      out.add(
        DeckFlashcard(
          id: '${idPrefix}_${out.length}_${q.question.hashCode}',
          front: q.question.trim(),
          back: back.toString(),
          sourceKey: null,
          mastery: 0,
          nextDue: DateTime.now(),
        ),
      );
    }
    if (out.isEmpty) {
      throw StateError('Aucune question pour les flashcards.');
    }
    return out;
  }

  /// Cartes éphémères depuis un JSON QCM du parcours (écran cours).
  Future<List<DeckFlashcard>> buildEphemeralFromAsset(
    String assetPath, {
    int count = 10,
  }) async {
    final raw = await AssetCacheService.loadString(assetPath);
    final qs = QuizRepository.tipJsonToQuizQuestions(raw, sourceAssetPath: assetPath);
    if (qs.isEmpty) {
      throw StateError('Aucune question dans ce module.');
    }
    final rng = Random();
    final shuffled = List<QuizQuestion>.from(qs)..shuffle(rng);
    final out = <DeckFlashcard>[];
    for (final q in shuffled) {
      if (out.length >= count) break;
      final back = StringBuffer(q.answer);
      if (q.explanation != null && q.explanation!.trim().isNotEmpty) {
        back.write('\n\n${q.explanation!.trim()}');
      }
      out.add(
        DeckFlashcard(
          id: 'ephem_mod_${out.length}_${q.question.hashCode}',
          front: q.question.trim(),
          back: back.toString(),
          sourceKey: null,
          mastery: 0,
          nextDue: DateTime.now(),
        ),
      );
    }
    if (out.isEmpty) {
      throw StateError('Impossible de construire des flashcards.');
    }
    return out;
  }
}
