import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'tip_catalog_loader.dart';
import 'tip_progress_repository.dart';

class FormationModel {
  const FormationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.iconEmoji,
    required this.totalModules,
    required this.completedModules,
    required this.sections,
  });

  final String id;
  final String title;
  final String description;
  final String iconEmoji;
  final int totalModules;
  final int completedModules;
  final List<SectionModel> sections;

  double get progress =>
      totalModules <= 0 ? 0 : completedModules / totalModules;
}

class SectionModel {
  const SectionModel({
    required this.id,
    required this.title,
    required this.modules,
  });

  final String id;
  final String title;
  final List<ModuleModel> modules;
}

class ModuleModel {
  const ModuleModel({
    required this.id,
    required this.title,
    required this.type,
    required this.isCompleted,
    required this.isLocked,
    this.quizAssetPath,
    this.lessonAssetPath,
  });

  final String id;
  final String title;
  final String type;
  final bool isCompleted;
  final bool isLocked;
  /// Chemin asset `data/questions/...json` pour le QCM du chapitre / évaluation.
  final String? quizAssetPath;
  /// Chemin asset `data/curriculum/...md` pour le cours texte.
  final String? lessonAssetPath;
}

class ParcoursRepository {
  ParcoursRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  /// Dernier catalogue TIP chargé (pour `/quiz/:id`, `/cours/:id`).
  static final Map<String, ModuleModel> moduleCatalog = {};

  /// Module → parcours + section (badges de fin de section).
  static final Map<String, ({String formationId, String sectionId})>
      moduleLocation = {};

  /// Section courante (progression appliquée) — clé `formationId::sectionId`.
  static final Map<String, SectionModel> sectionByCompoundKey = {};

  static void registerModules(List<FormationModel> forms) {
    moduleCatalog.clear();
    moduleLocation.clear();
    sectionByCompoundKey.clear();
    for (final f in forms) {
      for (final s in f.sections) {
        sectionByCompoundKey['${f.id}::${s.id}'] = s;
        for (final m in s.modules) {
          moduleCatalog[m.id] = m;
          moduleLocation[m.id] = (formationId: f.id, sectionId: s.id);
        }
      }
    }
  }

  static ModuleModel? moduleById(String id) => moduleCatalog[id];

  static Future<List<FormationModel>> _mergeWithProgress(
    List<FormationModel> raw,
  ) async {
    if (raw.isEmpty) return raw;
    final done = await TipProgressRepository().readCompletedIds();
    return raw.map((f) => _applyProgressToFormation(f, done)).toList();
  }

  /// Enchaînement : finir la section précédente (dont l’évaluation finale) → débloquer la suivante.
  /// Dans une section : valider le module précédent → débloquer le suivant.
  static FormationModel _applyProgressToFormation(
    FormationModel f,
    Set<String> done,
  ) {
    if (f.sections.isEmpty) return f;
    final newSections = <SectionModel>[];

    for (var si = 0; si < f.sections.length; si++) {
      final sec = f.sections[si];
      final prevSection = si > 0 ? f.sections[si - 1] : null;
      final prevSectionComplete = prevSection == null ||
          prevSection.modules.every((m) => done.contains(m.id));

      final newMods = <ModuleModel>[];
      for (var mi = 0; mi < sec.modules.length; mi++) {
        final m = sec.modules[mi];
        final prevMod = mi > 0 ? sec.modules[mi - 1] : null;
        final sequentialOk = prevMod == null || done.contains(prevMod.id);
        final unlocked = prevSectionComplete && sequentialOk;
        newMods.add(
          ModuleModel(
            id: m.id,
            title: m.title,
            type: m.type,
            isCompleted: done.contains(m.id),
            isLocked: !unlocked,
            quizAssetPath: m.quizAssetPath,
            lessonAssetPath: m.lessonAssetPath,
          ),
        );
      }
      newSections.add(
        SectionModel(id: sec.id, title: sec.title, modules: newMods),
      );
    }

    var cm = 0;
    for (final s in newSections) {
      for (final m in s.modules) {
        if (done.contains(m.id)) cm++;
      }
    }

    return FormationModel(
      id: f.id,
      title: f.title,
      description: f.description,
      iconEmoji: f.iconEmoji,
      totalModules: f.totalModules,
      completedModules: cm,
      sections: newSections,
    );
  }

  Stream<List<FormationModel>> watchFormations(String userId) {
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? subFs;
    StreamSubscription<void>? subPr;

    late final StreamController<List<FormationModel>> ctl;
    ctl = StreamController<List<FormationModel>>(
      onListen: () {
        Future<void> push() async {
          try {
            final base = await TipCatalogLoader.loadOptimusFormation();
            final merged = await _mergeWithProgress(base);
            registerModules(merged);
            if (!ctl.isClosed) ctl.add(merged);
          } catch (e, st) {
            if (!ctl.isClosed) ctl.addError(e, st);
          }
        }

        push();
        subFs = _db.collection('formations').snapshots().listen((_) => push());
        subPr = TipProgressRepository.updates.listen((_) => push());
      },
      onCancel: () {
        subFs?.cancel();
        subPr?.cancel();
      },
    );
    return ctl.stream;
  }
}
