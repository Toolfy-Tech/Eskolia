import 'dart:math';

/// Une affirmation Vrai / Faux pour le mode swipe.
class TrueFalseItem {
  const TrueFalseItem({
    required this.statement,
    required this.answer,
    required this.explanation,
  });

  final String statement;
  final bool answer;
  final String explanation;
}

/// Repository pour le mode Vrai/Faux.
/// Note: Le fichier local a été supprimé. Le repository est neutralisé en attendant une nouvelle source.
class TrueFalseRepository {
  Future<List<TrueFalseItem>> loadAll() async {
    return [];
  }

  /// Mélange et retourne au plus [count] cartes pour une partie.
  Future<List<TrueFalseItem>> loadRound({int count = 10, Random? rng}) async {
    return [];
  }
}
