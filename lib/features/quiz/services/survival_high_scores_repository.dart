import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../parcours/data/tip_quiz_catalog.dart';

/// Top 3 des scores Survival solo (bonnes réponses), banque Optimus.
class SurvivalHighScoresRepository {
  static const _prefix = 'eskolia_survival_top3_v1_';

  static String _storageKey(QuizCatalogTrack track) {
    return '${_prefix}optimus';
  }

  Future<List<int>> readTopThree(QuizCatalogTrack track) async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_storageKey(track));
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      final out = <int>[];
      for (final e in decoded) {
        if (e is num) out.add(e.toInt());
      }
      return out.take(3).toList();
    } catch (_) {
      return const [];
    }
  }

  Future<List<int>> recordScore(QuizCatalogTrack track, int score) async {
    if (score < 0) return readTopThree(track);
    final current = await readTopThree(track);
    final merged = [...current, score]..sort((a, b) => b.compareTo(a));
    final top = merged.take(3).toList();
    final p = await SharedPreferences.getInstance();
    await p.setString(_storageKey(track), jsonEncode(top));
    return top;
  }
}
