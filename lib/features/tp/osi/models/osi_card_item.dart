/// Type d'élément à trier
enum OsiCardType {
  protocol('Protocole', '⚡'),
  hardware('Équipement', '🔌'),
  pdu('PDU / Format', '📦'),
  concept('Concept / Port', '🏷️');

  const OsiCardType(this.label, this.emoji);
  final String label;
  final String emoji;
}

/// Modèle d'une carte pour le mini-jeu « Le Tri Sélectif »
class OsiCardItem {
  const OsiCardItem({
    required this.id,
    required this.title,
    required this.type,
    required this.targetLayer,
    required this.description,
    this.hint,
  });

  final String id;
  final String title; // ex: "Switch Ethernet (L2)", "HTTPS", "Segment TCP"
  final OsiCardType type;
  final int targetLayer; // 1 à 7
  final String description; // Explication pédagogique affichée lors de la correction
  final String? hint; // Indice optionnel
}
