import 'dart:convert';
import 'package:flutter/services.dart';
import '../../../core/services/asset_cache_service.dart';
import 'parcours_repository.dart';

typedef TipExamAsset = ({String title, String asset});

/// Charge les parcours depuis [data/curriculum/optimus/index.json],
/// Priorise désormais le champ 'mastery_quiz_path' pour le format Mastery.
class TipCatalogLoader {
  TipCatalogLoader._();

  static Set<String>? _assetsInManifest;

  static Future<bool> assetExists(String assetKey) async {
    if (_assetsInManifest == null) {
      try {
        final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
        _assetsInManifest = manifest.listAssets().toSet();
      } catch (_) {
        try {
          final manifestContent = await rootBundle.loadString('AssetManifest.json');
          final Map<String, dynamic> manifestMap = jsonDecode(manifestContent);
          _assetsInManifest = manifestMap.keys.toSet();
        } catch (_) {
          _assetsInManifest = null;
          return true;
        }
      }
    }
    return _assetsInManifest?.contains(assetKey) ?? true;
  }

  /// Charge la formation Optimus en utilisant les chemins définis dans l'index.json
  static Future<List<FormationModel>> _loadFormationFromIndexJson({
    required String indexAssetPath,
    required String formationId,
    required String formationTitle,
    required String formationDescription,
    required String iconEmoji,
    required String moduleIdPrefix,
  }) async {
    final raw = await AssetCacheService.loadString(indexAssetPath);
    final map = jsonDecode(raw) as Map<String, dynamic>;
    final sectionsJson = (map['sections'] as List<dynamic>).cast<Map<String, dynamic>>();
    final chapitresJson = (map['chapitres'] as List<dynamic>).cast<Map<String, dynamic>>();

    final sectionModels = <SectionModel>[];

    for (final sec in sectionsJson) {
      final sid = sec['id'] as String? ?? '';
      final stitle = sec['titre'] as String? ?? sid;
      final modules = <ModuleModel>[];

      final secChapters = chapitresJson.where((c) => c['section'] == sid).toList();

      for (final ch in secChapters) {
        final slug = ch['slug'] as String? ?? '';
        final titre = ch['titre'] as String? ?? '';
        final path = ch['path'] as String?;
        
        // Nouvelle priorité : mastery_quiz_path
        String? quizPath = ch['mastery_quiz_path'] as String?;
        if (quizPath != null && quizPath.isNotEmpty) {
          quizPath = 'data/$quizPath';
        }

        final lessonPath = path != null && path.isNotEmpty ? 'data/$path' : null;

        modules.add(
          ModuleModel(
            id: '${moduleIdPrefix}_${sid}_$slug',
            title: titre,
            type: quizPath != null ? 'chapitre' : 'cours',
            isCompleted: false,
            isLocked: false,
            quizAssetPath: quizPath,
            lessonAssetPath: lessonPath,
          ),
        );
      }

      sectionModels.add(SectionModel(id: sid, title: stitle, modules: modules));
    }

    return [
      FormationModel(
        id: formationId,
        title: formationTitle,
        description: formationDescription,
        iconEmoji: iconEmoji,
        totalModules: sectionModels.fold(0, (sum, s) => sum + s.modules.length),
        completedModules: 0,
        sections: sectionModels,
      ),
    ];
  }

  /// Alias pour la formation TIP (identique à Optimus).
  static Future<List<FormationModel>> loadTipFormation() => loadOptimusFormation();

  /// Formation TIP (Technicien informatique de proximité) — parcours Optimus.
  static Future<List<FormationModel>> loadOptimusFormation() =>
      _loadFormationFromIndexJson(
        indexAssetPath: 'data/curriculum/optimus/index.json',
        formationId: 'optimus',
        formationTitle: 'Cours formation TIP',
        formationDescription: 'Maîtrisez le métier de Technicien Informatique de Proximité avec le contenu officiel Optimus.',
        iconEmoji: '\u{1F916}',
        moduleIdPrefix: 'optimus',
      );
}

class OptimusCatalogLoader {
  static Future<List<FormationModel>> loadOptimusFormation() => TipCatalogLoader.loadOptimusFormation();
}
