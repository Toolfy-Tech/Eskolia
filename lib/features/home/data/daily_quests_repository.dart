import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Quêtes quotidiennes locales — blueprint v3 § Progression (MVP sans backend).
class DailyQuestsRepository {
  DailyQuestsRepository();

  static const _prefix = 'eskolia_daily_quests_v1';

  String _dateKey() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }

  Future<Map<String, dynamic>> _readRaw() async {
    final p = await SharedPreferences.getInstance();
    final day = _dateKey();
    final storedDay = p.getString('${_prefix}_day');
    if (storedDay != day) {
      await p.setString('${_prefix}_day', day);
      final fresh = {
        'quiz': false,
        'flash': false,
        'parcours': false,
      };
      await p.setString(_prefix, jsonEncode(fresh));
      return fresh;
    }
    final s = p.getString(_prefix);
    if (s == null || s.isEmpty) {
      final fresh = {'quiz': false, 'flash': false, 'parcours': false};
      await p.setString(_prefix, jsonEncode(fresh));
      return fresh;
    }
    try {
      return Map<String, dynamic>.from(jsonDecode(s) as Map);
    } catch (_) {
      return {'quiz': false, 'flash': false, 'parcours': false};
    }
  }

  Future<void> _write(Map<String, dynamic> m) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_prefix, jsonEncode(m));
  }

  /// À appeler au chargement de la Home (reset minuit logique par date locale).
  Future<void> ensureToday() async {
    await _readRaw();
  }

  Future<DailyQuestsSnapshot> snapshot() async {
    final m = await _readRaw();
    return DailyQuestsSnapshot(
      quizDone: m['quiz'] == true,
      flashDone: m['flash'] == true,
      parcoursDone: m['parcours'] == true,
    );
  }

  Future<void> markQuizDone() async {
    final m = await _readRaw();
    m['quiz'] = true;
    await _write(m);
  }

  Future<void> markFlashcardSessionDone() async {
    final m = await _readRaw();
    m['flash'] = true;
    await _write(m);
  }

  Future<void> markParcoursProgressDone() async {
    final m = await _readRaw();
    m['parcours'] = true;
    await _write(m);
  }
}

class DailyQuestsSnapshot {
  const DailyQuestsSnapshot({
    required this.quizDone,
    required this.flashDone,
    required this.parcoursDone,
  });

  final bool quizDone;
  final bool flashDone;
  final bool parcoursDone;

  int get completedCount =>
      (quizDone ? 1 : 0) + (flashDone ? 1 : 0) + (parcoursDone ? 1 : 0);
}
