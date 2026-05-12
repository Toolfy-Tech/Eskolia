import 'practical_track_models.dart';

/// Repository pour les parcours « Exercices pratiques ».
/// Note: L'index local a été retiré. Le système est prêt pour une future source de données.
class PracticalCatalogRepository {
  PracticalCatalogRepository._();

  static Future<List<PracticalTrackSummary>> loadTrackSummaries() async {
    // Retourne une liste vide car les fichiers locaux ont été supprimés pour refonte.
    return [];
  }

  static Future<PracticalTrackManifest> loadTrackManifest(String trackId) async {
    throw UnimplementedError('Le parcours $trackId est en cours de refonte.');
  }

  static Future<List<PracticalExercise>> loadExercises(String assetPath) async {
    return [];
  }

  static Future<PracticalMissionsPack> loadMissionsPack(String assetPath) async {
    throw UnimplementedError('Contenu indisponible.');
  }
}
