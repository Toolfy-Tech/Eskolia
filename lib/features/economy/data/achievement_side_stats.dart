import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Compteurs locaux (hors Firestore) pour des hauts faits (révision, arène, flash…).
class AchievementSideStats {
  AchievementSideStats._();

  static const _key = 'eskolia_achievement_side_stats_v1';

  static Future<Map<String, dynamic>> _readMap() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_key);
    if (raw == null || raw.isEmpty) return {};
    try {
      return Map<String, dynamic>.from(jsonDecode(raw) as Map);
    } catch (_) {
      return {};
    }
  }

  static Future<void> _writeMap(Map<String, dynamic> map) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_key, jsonEncode(map));
  }

  static Future<int> bump(String uid, String field, int delta) async {
    if (uid.isEmpty || delta == 0) return await read(uid, field);
    final map = await _readMap();
    final uRaw = map[uid];
    final Map<String, dynamic> uMap;
    if (uRaw is Map) {
      uMap = Map<String, dynamic>.from(
        uRaw.map((k, v) => MapEntry(k.toString(), v)),
      );
    } else {
      uMap = {};
    }
    final cur = (uMap[field] as num?)?.toInt() ?? 0;
    final next = cur + delta;
    uMap[field] = next;
    map[uid] = uMap;
    await _writeMap(map);
    return next;
  }

  static Future<int> read(String uid, String field) async {
    if (uid.isEmpty) return 0;
    final map = await _readMap();
    final uRaw = map[uid];
    if (uRaw is! Map) return 0;
    return (uRaw[field] as num?)?.toInt() ?? 0;
  }
}
