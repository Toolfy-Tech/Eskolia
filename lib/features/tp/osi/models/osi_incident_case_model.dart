/// Action de support proposée pour résoudre l'incident
class OsiSupportAction {
  const OsiSupportAction({
    required this.id,
    required this.title,
    required this.isCorrect,
    required this.explanation,
  });

  final String id;
  final String title; // ex: "Remplacer le câble RJ45 Cat6 par un câble testé"
  final bool isCorrect;
  final String explanation;
}

/// Cas pratique d'incident pour le mini-jeu « L'Enquêteur OSI »
class OsiIncidentCase {
  const OsiIncidentCase({
    required this.id,
    required this.ticketNumber,
    required this.userRole,
    required this.userComplaint,
    required this.technicalSymptoms,
    required this.correctLayerNumber,
    required this.diagnosticHint,
    required this.actions,
    required this.fullRcaExplanation,
  });

  final String id;
  final String ticketNumber; // ex: "INC-2024-884"
  final String userRole; // ex: "Comptable", "Développeur", "Secrétariat"
  final String userComplaint; // Témoignage brut de l'utilisateur
  final List<String> technicalSymptoms; // Données techniques (logs, voyants, captures)
  final int correctLayerNumber; // Couche OSI 1 à 7
  final String diagnosticHint;
  final List<OsiSupportAction> actions; // Propostions d'action de support
  final String fullRcaExplanation; // Root Cause Analysis détaillée
}
