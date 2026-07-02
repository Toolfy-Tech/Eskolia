import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'quiz_repository.dart';
import 'revision_pool_repository.dart';

final lacunesRepositoryProvider = Provider<LacunesRepository>((ref) {
  return LacunesRepository();
});

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

  Future<void> remove(RevisionPoolEntry entry) async {
    final cur = await readEntries();
    cur.removeWhere((e) => e.storageKey == entry.storageKey);
    await _save(cur);
  }

  Future<void> removeByKey(String storageKey) async {
    final cur = await readEntries();
    cur.removeWhere((e) => e.storageKey == storageKey);
    await _save(cur);
  }

  Future<void> addWrongByKey(String storageKey) async {
    final cur = await readEntries();
    if (cur.any((e) => e.storageKey == storageKey)) {
      final entry = cur.firstWhere((e) => e.storageKey == storageKey);
      final next = <RevisionPoolEntry>[
        entry,
        ...cur.where((e) => e.storageKey != storageKey),
      ];
      await _save(next);
      return;
    }
    
    String assetPath;
    String? questionId;
    int questionIndex = 0;
    if (storageKey.contains('|||')) {
      final parts = storageKey.split('|||');
      assetPath = parts[0];
      questionId = parts[1];
    } else if (storageKey.contains('||idx|')) {
      final parts = storageKey.split('||idx|');
      assetPath = parts[0];
      questionIndex = int.tryParse(parts[1]) ?? 0;
    } else {
      return;
    }
    
    final next = <RevisionPoolEntry>[
      RevisionPoolEntry(
        assetPath: assetPath,
        questionIndex: questionIndex,
        questionId: questionId,
      ),
      ...cur,
    ];
    await _save(next);
  }

  Future<void> _save(List<RevisionPoolEntry> list) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_key, jsonEncode(list.map((e) => e.toJson()).toList()));
  }

  Future<List<QuizQuestion>> resolveQuestions(List<RevisionPoolEntry> entries, {int max = 40}) async {
    final out = <QuizQuestion>[];
    final repo = QuizRepository();
    final Map<String, QuizSession> sessionCache = {};

    for (final e in entries) {
      if (out.length >= max) break;
      try {
        QuizSession? session = sessionCache[e.assetPath];
        if (session == null) {
          session = await repo.buildSoloBundleQuizSession(
            assetKey: e.assetPath,
            title: 'Mes fautes',
          );
          sessionCache[e.assetPath] = session;
        }
        final q = session.questions.firstWhere(
          (q) => q.id == e.questionId,
          orElse: () => throw Exception('Question ${e.questionId} absente de ${e.assetPath}'),
        );
        out.add(q);
      } catch (err) {
        debugPrint('[LacunesRepository.resolveQuestions] Erreur de résolution de la question : $err');
      }
    }
    return out;
  }
}
