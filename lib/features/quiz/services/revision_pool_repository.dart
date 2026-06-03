import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../labo/data/labo_community_constants.dart';
import 'quiz_repository.dart';

/// Entrée du pool de révision 📌 (asset JSON + repère de question).
class RevisionPoolEntry {
  const RevisionPoolEntry({
    required this.assetPath,
    required this.questionIndex,
    this.questionId,
    this.lastReviewedAt,
  });

  final String assetPath;
  final int questionIndex;
  final String? questionId;
  final DateTime? lastReviewedAt;

  bool get isDue {
    if (lastReviewedAt == null) return true;
    return DateTime.now().difference(lastReviewedAt!) >= const Duration(hours: 24);
  }

  RevisionPoolEntry copyWith({DateTime? lastReviewedAt}) => RevisionPoolEntry(
        assetPath: assetPath,
        questionIndex: questionIndex,
        questionId: questionId,
        lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      );

  Map<String, dynamic> toJson() => {
        'a': assetPath,
        'i': questionIndex,
        if (questionId != null && questionId!.isNotEmpty) 'id': questionId,
        if (lastReviewedAt != null) 'r': lastReviewedAt!.millisecondsSinceEpoch,
      };

  static RevisionPoolEntry? fromJson(Map<String, dynamic> m) {
    final a = m['a'] as String?;
    if (a == null || a.isEmpty) return null;
    final i = (m['i'] as num?)?.toInt() ?? 0;
    final id = m['id'] as String?;
    final r = (m['r'] as num?)?.toInt();
    return RevisionPoolEntry(
      assetPath: a,
      questionIndex: i,
      questionId: id,
      lastReviewedAt: r != null ? DateTime.fromMillisecondsSinceEpoch(r) : null,
    );
  }

  String get storageKey {
    if (questionId != null && questionId!.isNotEmpty) {
      return '$assetPath|||$questionId';
    }
    return '$assetPath||idx|$questionIndex';
  }
}

/// Service gérant le pool local de révision (SharedPreferences).
class RevisionPoolRepository {
  RevisionPoolRepository();

  static const _key = 'eskolia_revision_pool_v1';

  static String keyForQuestion(QuizQuestion q, int questionIndex) {
    final a = q.sourceAssetPath;
    if (a == null || a.isEmpty) return '';
    if (a == kLaboApprovedQuestionSource) {
      final fid = laboFirestoreIdFromQuizQuestionId(q.id);
      if (fid != null && fid.isNotEmpty) return '$a|||$fid';
      return '';
    }
    if (q.id.isNotEmpty) return '$a|||${q.id}';
    return '$a||idx|$questionIndex';
  }

  /// Returns entries sorted: never-reviewed first, then oldest review date first.
  Future<List<RevisionPoolEntry>> readEntries() async {
    final p = await SharedPreferences.getInstance();
    final s = p.getString(_key);
    if (s == null || s.isEmpty) return [];
    try {
      final list = jsonDecode(s) as List<dynamic>;
      final out = <RevisionPoolEntry>[];
      for (final e in list) {
        if (e is Map) {
          final en = RevisionPoolEntry.fromJson(Map<String, dynamic>.from(e));
          if (en != null) out.add(en);
        }
      }
      out.sort((a, b) {
        if (a.lastReviewedAt == null && b.lastReviewedAt == null) return 0;
        if (a.lastReviewedAt == null) return -1;
        if (b.lastReviewedAt == null) return 1;
        return a.lastReviewedAt!.compareTo(b.lastReviewedAt!);
      });
      return out;
    } catch (e) {
      debugPrint('[RevisionPoolRepository.readEntries] $e');
      return [];
    }
  }

  Future<Set<String>> readKeySet() async {
    final keys = <String>{};
    for (final e in await readEntries()) {
      keys.add(e.storageKey);
    }
    return keys;
  }

  Future<void> add(QuizQuestion q) async {
    final a = q.sourceAssetPath;
    if (a == null || a.isEmpty) return;

    final k = q.id.isNotEmpty ? '$a|||${q.id}' : '$a||idx|0';
    final cur = await readEntries();
    final next = <RevisionPoolEntry>[
      RevisionPoolEntry(
        assetPath: a,
        questionIndex: 0,
        questionId: q.id.isNotEmpty ? q.id : null,
      ),
      ...cur.where((e) => e.storageKey != k),
    ];
    await _save(next);
  }

  Future<void> remove(RevisionPoolEntry e) async {
    final cur = await readEntries();
    cur.removeWhere((x) => x.storageKey == e.storageKey);
    await _save(cur);
  }

  Future<void> markReviewed(List<String> storageKeys) async {
    if (storageKeys.isEmpty) return;
    final keySet = storageKeys.toSet();
    final now = DateTime.now();
    final cur = await readEntries();
    final updated = cur.map((e) => keySet.contains(e.storageKey) ? e.copyWith(lastReviewedAt: now) : e).toList();
    await _save(updated);
  }

  Future<void> _save(List<RevisionPoolEntry> list) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_key, jsonEncode(list.map((e) => e.toJson()).toList()));
  }

  Future<List<QuizQuestion>> resolveQuestions(List<RevisionPoolEntry> entries, {int max = 40}) async {
    final out = <QuizQuestion>[];
    final repo = QuizRepository();
    for (final e in entries) {
      if (out.length >= max) break;
      try {
        final session = await repo.loadSession(e.assetPath);
        final q = session.questions.firstWhere((q) => q.id == e.questionId, orElse: () => session.questions.first);
        out.add(q);
      } catch (e) {
        debugPrint('[RevisionPoolRepository.resolveQuestions] $e');
      }
    }
    return out;
  }
}
