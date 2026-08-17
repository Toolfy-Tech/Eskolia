import 'package:flutter/material.dart';

enum PacketDirection {
  encapsulation('Émission (Encapsulation)', '7 ➔ 1'),
  decapsulation('Réception (Décapsulation)', '1 ➔ 7');

  const PacketDirection(this.label, this.directionArrow);
  final String label;
  final String directionArrow;
}

/// Étape séquentielle pour le mini-jeu « Le Voyage du Paquet »
class OsiPacketStep {
  const OsiPacketStep({
    required this.id,
    required this.layerNumber,
    required this.headerTitle,
    required this.headerPdu,
    required this.actionDescription,
    required this.dataPayloadPreview,
    required this.accentColor,
    required this.detailedTechnicalNote,
  });

  final String id;
  final int layerNumber; // 1..7
  final String headerTitle; // ex: "[Header TCP]", "[Header IP]", "[MAC Header + FCS]"
  final String headerPdu; // ex: "Segment", "Paquet", "Trame"
  final String actionDescription; // ex: "Ajout des ports source & destination (TCP)"
  final String dataPayloadPreview; // Visualisation du contenu
  final Color accentColor;
  final String detailedTechnicalNote;
}
