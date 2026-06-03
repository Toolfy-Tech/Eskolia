import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'achievement_catalog.dart';
import 'achievement_progress.dart';

/// Déblocages locaux par utilisateur (badges Firestore restent sur le doc profil).
class AchievementsRepository {
  AchievementsRepository();

  static const _prefsKey = 'eskolia_achievements_unlocked_v1';

  Future<Set<String>> _readSet(String uid) async {
    if (uid.isEmpty) return {};
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_prefsKey);
    if (raw == null || raw.isEmpty) return {};
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final list = map[uid];
      if (list is! List) return {};
      return list.map((e) => e.toString()).toSet();
    } catch (e) {
      debugPrint('[AchievementsRepository._readSet] $e');
      return {};
    }
  }

  Future<void> _writeSet(String uid, Set<String> ids) async {
    if (uid.isEmpty) return;
    final p = await SharedPreferences.getInstance();
    Map<String, dynamic> map = {};
    final prev = p.getString(_prefsKey);
    if (prev != null && prev.isNotEmpty) {
      try {
        map = Map<String, dynamic>.from(jsonDecode(prev) as Map);
      } catch (e) {
        debugPrint('[AchievementsRepository._writeSet] $e');
      }
    }
    map[uid] = ids.toList();
    await p.setString(_prefsKey, jsonEncode(map));
  }

  /// Retourne `true` si nouvellement débloqué.
  Future<bool> unlock(String uid, String achievementId) async {
    if (uid.isEmpty) return false;
    final cur = await _readSet(uid);
    if (cur.contains(achievementId)) return false;
    cur.add(achievementId);
    await _writeSet(uid, cur);
    return true;
  }

  Future<bool> isUnlocked(String uid, String achievementId) async {
    final s = await _readSet(uid);
    return s.contains(achievementId);
  }

  Future<List<(AchievementDef, bool)>> listWithState(String uid) async {
    final s = await _readSet(uid);
    return kAchievementCatalog
        .map((d) => (d, s.contains(d.id)))
        .toList(growable: false);
  }

  /// Hauts faits + libellé de progression optionnel (`7 / 10`, etc.).
  Future<List<(AchievementDef, bool, String?)>> listWithStateAndProgress(
    String uid,
  ) async {
    final rows = await listWithState(uid);
    final snap = await AchievementProgressSnapshot.load(uid);
    return rows
        .map(
          (r) => (
            r.$1,
            r.$2,
            snap.labelFor(r.$1.id, r.$2),
          ),
        )
        .toList(growable: false);
  }
}
