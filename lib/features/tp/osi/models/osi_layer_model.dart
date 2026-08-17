import 'package:flutter/material.dart';

/// Représente l'une des 7 couches du Modèle OSI avec toutes ses explications concrètes
class OsiLayerModel {
  const OsiLayerModel({
    required this.number,
    required this.name,
    required this.englishName,
    required this.pdu,
    required this.role,
    required this.keyProtocols,
    required this.keyHardware,
    required this.accentColor,
    required this.mnemonicHint,
    required this.analogy,
    required this.concreteExplanation,
    required this.diagnosticTools,
    required this.typicalBreakdowns,
  });

  final int number; // 1 à 7
  final String name; // ex: "Application", "Transport"
  final String englishName; // ex: "Application", "Transport"
  final String pdu; // ex: "Données", "Segment / Datagramme", "Paquet", "Trame", "Bit"
  final String role; // Description concise du rôle
  final List<String> keyProtocols; // ex: ["HTTP", "DNS", "SSH"]
  final List<String> keyHardware; // ex: ["Routeur", "Switch", "Câble RJ45"]
  final Color accentColor; // Couleur officielle du thème
  final String mnemonicHint; // ex: "A - Après", "P - Plusieurs"...
  
  /// Analogie concrète du quotidien pour vulgariser
  final String analogy;
  
  /// Explication pédagogique détaillée et concrète
  final String concreteExplanation;
  
  /// Commandes CLI et outils de test réels
  final List<String> diagnosticTools;
  
  /// Exemples réels de pannes vécues en entreprise
  final List<String> typicalBreakdowns;

  String get fullName => 'Couche $number — $name';
  String get tag => 'L$number';
}
