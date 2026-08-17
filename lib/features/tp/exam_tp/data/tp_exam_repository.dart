import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/services/asset_cache_service.dart';
import '../models/tp_exam_model.dart';

class TpExamRepository {
  TpExamRepository._() {
    _initStream();
  }
  static final TpExamRepository instance = TpExamRepository._();

  static const String _completedPrefix = 'tp_exam_completed_';
  static const String _scorePrefix = 'tp_exam_score_';
  static const String _tasksPrefix = 'tp_exam_checked_tasks_';
  static const String _tpExamEnabledPrefKey = 'config_tp_exam_enabled';

  static const List<String> _examAssetPaths = [
    'assets/tp/exam_tp/tp_exam_francis.json',
    'assets/tp/exam_tp/tp_exam_claire.json',
    'assets/tp/exam_tp/tp_exam_marc.json',
    'assets/tp/exam_tp/tp_exam_sylvain.json',
  ];

  final _enabledController = StreamController<bool>.broadcast();
  bool? _lastKnownState;
  StreamSubscription? _firestoreSub;

  void _initStream() {
    // 1. Initialisation depuis SharedPreferences
    SharedPreferences.getInstance().then((prefs) {
      final localVal = prefs.getBool(_tpExamEnabledPrefKey) ?? false;
      if (_lastKnownState == null) {
        _lastKnownState = localVal;
        _enabledController.add(localVal);
      }
    }).catchError((_) {});

    // 2. Écoute temps réel Firestore (collection formations autorisée en lecture pour tous les connectés)
    try {
      _firestoreSub = FirebaseFirestore.instance
          .collection('formations')
          .doc('exam_tp_config')
          .snapshots()
          .listen((doc) async {
        final enabled = (doc.exists && doc.data() != null)
            ? (doc.data()?['isEnabled'] as bool? ?? false)
            : false;
        _lastKnownState = enabled;
        _enabledController.add(enabled);
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool(_tpExamEnabledPrefKey, enabled);
        } catch (_) {}
      }, onError: (e) {
        debugPrint('[TpExamRepository.firestore] error listening: $e');
      });
    } catch (_) {}
  }

  /// Écoute en temps réel si les épreuves pratiques TP VM sont activées par le professeur/admin
  Stream<bool> watchTpExamEnabled() async* {
    if (_lastKnownState != null) {
      yield _lastKnownState!;
    } else {
      final initial = await isTpExamEnabled();
      _lastKnownState = initial;
      yield initial;
    }
    yield* _enabledController.stream;
  }

  /// Vérifie ponctuellement si le module TP VM est activé
  Future<bool> isTpExamEnabled() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('formations')
          .doc('exam_tp_config')
          .get();
      if (doc.exists && doc.data() != null) {
        final enabled = doc.data()?['isEnabled'] as bool? ?? false;
        _lastKnownState = enabled;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_tpExamEnabledPrefKey, enabled);
        return enabled;
      }
    } catch (e) {
      debugPrint('[TpExamRepository.isTpExamEnabled] Error fetching from firestore: $e');
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final local = prefs.getBool(_tpExamEnabledPrefKey) ?? false;
      _lastKnownState = local;
      return local;
    } catch (_) {
      return false;
    }
  }

  /// Active ou masque le module TP VM (réservé aux professeurs / administrateurs)
  Future<void> setTpExamEnabled(bool enabled) async {
    _lastKnownState = enabled;
    _enabledController.add(enabled);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_tpExamEnabledPrefKey, enabled);
    } catch (_) {}

    try {
      await FirebaseFirestore.instance
          .collection('formations')
          .doc('exam_tp_config')
          .set({
        'isEnabled': enabled,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('[TpExamRepository.setTpExamEnabled] Error saving to firestore: $e');
    }
  }

  /// Charge tous les scénarios TP d'examens pratiques
  Future<List<TpExamScenario>> loadAllScenarios() async {
    final List<TpExamScenario> list = [];
    SharedPreferences? prefs;
    try {
      prefs = await SharedPreferences.getInstance();
    } catch (_) {}

    for (final path in _examAssetPaths) {
      try {
        final raw = await AssetCacheService.loadString(path);
        final dynamic decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          var scenario = TpExamScenario.fromJson(decoded);
          if (prefs != null) {
            final isCompleted = prefs.getBool('$_completedPrefix${scenario.id}') ?? false;
            final score = prefs.getDouble('$_scorePrefix${scenario.id}');
            final checkedTasksList = prefs.getStringList('$_tasksPrefix${scenario.id}') ?? [];
            scenario = scenario.copyWith(
              isCompleted: isCompleted,
              userScore: score,
              checkedTaskIds: checkedTasksList.toSet(),
            );
          }
          list.add(scenario);
        }
      } catch (e) {
        debugPrint('[TpExamRepository.loadAllScenarios] Error loading $path: $e');
      }
    }

    return list;
  }

  /// Charge un scénario spécifique par son ID
  Future<TpExamScenario?> loadScenarioById(String id) async {
    final all = await loadAllScenarios();
    try {
      return all.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Enregistre l'état coché d'une tâche
  Future<void> toggleTaskChecked(String examId, String taskId, bool isChecked) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentList = prefs.getStringList('$_tasksPrefix$examId') ?? [];
      final currentSet = currentList.toSet();
      if (isChecked) {
        currentSet.add(taskId);
      } else {
        currentSet.remove(taskId);
      }
      await prefs.setStringList('$_tasksPrefix$examId', currentSet.toList());
    } catch (e) {
      debugPrint('[TpExamRepository.toggleTaskChecked] Error: $e');
    }
  }

  /// Valide et termine l'épreuve pratique pour débloquer la correction
  Future<void> completeExam(String examId, {double? userScore}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('$_completedPrefix$examId', true);
      if (userScore != null) {
        await prefs.setDouble('$_scorePrefix$examId', userScore);
      }
    } catch (e) {
      debugPrint('[TpExamRepository.completeExam] Error: $e');
    }
  }

  /// Enregistre la note finale sur 20 issue de l'auto-évaluation
  Future<void> saveEvaluationScore(String examId, double finalScoreOn20) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('$_scorePrefix$examId', finalScoreOn20);
      await prefs.setBool('$_completedPrefix$examId', true);
    } catch (e) {
      debugPrint('[TpExamRepository.saveEvaluationScore] Error: $e');
    }
  }

  /// Réinitialise une session TP pour recommencer à zéro
  Future<void> resetExamProgress(String examId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_completedPrefix$examId');
      await prefs.remove('$_scorePrefix$examId');
      await prefs.remove('$_tasksPrefix$examId');
    } catch (e) {
      debugPrint('[TpExamRepository.resetExamProgress] Error: $e');
    }
  }
}
