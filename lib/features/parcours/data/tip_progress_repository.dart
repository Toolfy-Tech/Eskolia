import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Progression locale du parcours TIP (modules validés).
class TipProgressRepository {
  TipProgressRepository();

  /// QCM des chapitres et modules hors évaluation finale de section.
  static const passScoreRatio = 0.6;

  /// Évaluations finales de section (1 ou 2 parties) et examen blanc TIP — même barème.
  static const sectionFinalExamPassRatio = 0.8;
  static const _key = 'eskolia_tip_completed_module_ids';

  static final StreamController<void> _updates =
      StreamController<void>.broadcast();

  /// Écouté par [ParcoursRepository.watchFormations] pour rafraîchir verrous / complétion.
  static Stream<void> get updates => _updates.stream;

  Future<Set<String>> readCompletedIds() async {
    final p = await SharedPreferences.getInstance();
    final s = p.getString(_key);
    if (s == null || s.isEmpty) return {};
    try {
      final list = jsonDecode(s) as List<dynamic>;
      return list.map((e) => e.toString()).toSet();
    } catch (_) {
      return {};
    }
  }

  /// Marque un chapitre / évaluation comme validé (après QCM réussi ou cours sans QCM lu).
  Future<void> markModulePassed(String moduleId) async {
    if (moduleId.isEmpty || moduleId == 'daily') return;
    if (!moduleId.startsWith('tip_') && !moduleId.startsWith('optimus_')) {
      return;
    }
    final cur = await readCompletedIds();
    if (cur.contains(moduleId)) return;
    cur.add(moduleId);
    final sorted = cur.toList()..sort();
    final p = await SharedPreferences.getInstance();
    await p.setString(_key, jsonEncode(sorted));
    if (!_updates.isClosed) _updates.add(null);
  }
}

/// Alias pour les modules Optimus — même logique de suivi que TipProgressRepository.
typedef OptimusProgressRepository = TipProgressRepository;
