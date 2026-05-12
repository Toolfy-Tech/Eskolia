import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Progression locale du parcours missions (index de la prochaine mission à afficher).
class PracticalMissionsProgressRepository {
  PracticalMissionsProgressRepository();

  /// v2 : parcours AD missions réordonné (progression type GameShell) — évite
  /// de réutiliser un index v1 qui ne correspond plus à la même mission.
  static const _key = 'eskolia_practical_missions_progress_v2';

  Future<Map<String, int>> _readMap() async {
    final p = await SharedPreferences.getInstance();
    final s = p.getString(_key);
    if (s == null || s.isEmpty) return {};
    try {
      final map = jsonDecode(s) as Map<String, dynamic>;
      final out = <String, int>{};
      map.forEach((k, v) {
        if (v is num) out[k] = v.toInt();
      });
      return out;
    } catch (_) {
      return {};
    }
  }

  Future<void> _writeMap(Map<String, int> m) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_key, jsonEncode(m));
  }

  /// Index de la mission en cours (0-based). 0 = première mission.
  Future<int> readNextMissionIndex(String trackId) async {
    final m = await _readMap();
    return m[trackId] ?? 0;
  }

  Future<void> setNextMissionIndex(String trackId, int index) async {
    final m = await _readMap();
    m[trackId] = index < 0 ? 0 : index;
    await _writeMap(m);
  }

  Future<void> clearTrack(String trackId) async {
    final m = await _readMap();
    m.remove(trackId);
    await _writeMap(m);
  }
}
