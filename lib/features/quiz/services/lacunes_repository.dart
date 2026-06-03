import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'quiz_repository.dart';
import 'revision_pool_repository.dart';

/// Service gérant la file d'attente locale des questions ratées (lacunes).
class LacunesRepository {
  LacunesRepository();

  static const _key = 'eskolia_lacunes_queue_v1';

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
      return out;
    } catch (e) {
      debugPrint('[LacunesRepository.readEntries] $e');
      return [];
    }
  }

  Future<void> addWrong(QuizQuestion q) async {
    final a = q.sourceAssetPath;
    if (a == null || a.isEmpty) return;
    
    // Logique d'ajout simplifiée pour la Phase 4
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

  Future<void> removeIfCorrect(QuizQuestion q) async {
    final a = q.sourceAssetPath;
    if (a == null || a.isEmpty) return;
    final k = q.id.isNotEmpty ? '$a|||${q.id}' : '$a||idx|0';
    
    final cur = await readEntries();
    cur.removeWhere((e) => e.storageKey == k);
    await _save(cur);
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
      // Résolution via QuizRepository (sera améliorée en Phase 5)
      try {
        final session = await repo.loadSession(e.assetPath);
        final q = session.questions.firstWhere((q) => q.id == e.questionId, orElse: () => session.questions.first);
        out.add(q);
      } catch (e) {
        debugPrint('[LacunesRepository.resolveQuestions] $e');
      }
    }
    return out;
  }
}
