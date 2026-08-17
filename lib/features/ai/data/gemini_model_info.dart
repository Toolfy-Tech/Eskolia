import 'package:flutter/material.dart';

import '../../../core/constants/eskolia_tokens.dart';

/// Metadonnees enrichies d'un modele Gemini — tier, label, couleur, nom simplifie.
class GeminiModelInfo {
  const GeminiModelInfo({
    required this.rawName,
    required this.modelId,
    required this.simpleName,
    required this.tier,
    required this.tierLabel,
    required this.tierColor,
    required this.sortOrder,
  });

  /// Nom complet retourne par l'API Google (ex: 'models/gemini-2.5-flash').
  final String rawName;

  /// Identifiant court pour les URLs et le stockage (ex: 'gemini-2.5-flash').
  final String modelId;

  /// Nom lisible (ex: 'Gemini 2.5 Flash').
  final String simpleName;

  /// Tier : 'S' | 'A' | 'B' | 'C'.
  final String tier;

  /// Label descriptif (ex: 'Equilibre (Recommande)').
  final String tierLabel;

  final Color tierColor;

  /// Ordre de tri : 0 = S, 1 = A, 2 = B, 3 = C.
  final int sortOrder;

  /// Classe un modele depuis son nom brut (avec ou sans prefixe 'models/').
  factory GeminiModelInfo.from(String name) {
    final rawName = name.startsWith('models/') ? name : 'models/$name';
    final modelId = rawName.replaceFirst('models/', '');
    final lower   = modelId.toLowerCase();
    final simple  = _prettify(modelId);

    if (lower.contains('pro')) {
      return GeminiModelInfo(
        rawName: rawName, modelId: modelId, simpleName: simple,
        tier: 'S', tierLabel: 'Puissant (Cout eleve)',
        tierColor: EskoliaTokens.violet, sortOrder: 0,
      );
    }
    if (lower.contains('flash') && !lower.contains('lite')) {
      return GeminiModelInfo(
        rawName: rawName, modelId: modelId, simpleName: simple,
        tier: 'A', tierLabel: 'Equilibre (Recommande)',
        tierColor: EskoliaTokens.success, sortOrder: 1,
      );
    }
    if (lower.contains('lite')) {
      return GeminiModelInfo(
        rawName: rawName, modelId: modelId, simpleName: simple,
        tier: 'B', tierLabel: 'Rapide & Econome',
        tierColor: EskoliaTokens.orange, sortOrder: 2,
      );
    }
    return GeminiModelInfo(
      rawName: rawName, modelId: modelId, simpleName: simple,
      tier: 'C', tierLabel: 'Experimental',
      tierColor: EskoliaTokens.textDisabled, sortOrder: 3,
    );
  }

  /// Liste par defaut si l'API est inaccessible.
  static List<GeminiModelInfo> defaults() {
    return [
      'gemini-2.0-flash',
      'gemini-1.5-flash',
      'gemini-1.5-pro',
      'gemini-2.5-flash',
      'gemini-2.5-pro',
    ].map(GeminiModelInfo.from).toList()
      ..sort((a, b) {
        final t = a.sortOrder.compareTo(b.sortOrder);
        return t != 0 ? t : b.modelId.compareTo(a.modelId);
      });
  }

  static String _prettify(String modelId) {
    return modelId.split('-').map((p) {
      if (p.isEmpty) return p;
      return p[0].toUpperCase() + p.substring(1);
    }).join(' ');
  }
}
