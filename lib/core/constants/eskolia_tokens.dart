import 'package:flutter/material.dart';

/// Source unique de vérité pour tous les design tokens Eskolia.
///
/// Règle : aucun écran ou widget ne doit déclarer une couleur `Color(0xFF...)` locale.
/// Toujours importer depuis ici.
abstract final class EskoliaTokens {
  EskoliaTokens._();

  // ─── COULEURS DE FOND ─────────────────────────────────────────────────────

  /// Fond le plus profond (scaffold background).
  static const Color bgBase = Color(0xFF0B1120);

  /// Surface L1 — cartes principales.
  static const Color surface1 = Color(0xFF111827);

  /// Surface L2 — éléments secondaires, modales.
  static const Color surface2 = Color(0xFF1E2A3B);

  /// Surface L3 — hover, skeleton, inputs.
  static const Color surface3 = Color(0xFF243044);

  // ─── COULEURS PRIMAIRES ───────────────────────────────────────────────────

  /// Violet primaire — CTA, accents forts.
  static const Color violet = Color(0xFF7C6FFF);

  /// Violet atténué — hover, backgrounds de sections.
  static const Color violetSoft = Color(0xFF6C63FF);

  /// Cyan — quiz, cours, actions secondaires.
  static const Color cyan = Color(0xFF06B6D4);

  /// Cyan atténué — backgrounds légers.
  static const Color cyanSoft = Color(0xFF00BCD4);

  /// Or — badges, achievements, streaks.
  static const Color gold = Color(0xFFFFD700);

  /// Ambre — notifications, avertissements doux.
  static const Color amber = Color(0xFFF59E0B);

  /// Orange — supports de cours.
  static const Color orange = Color(0xFFFF9800);

  // ─── COULEURS DE STATUT ───────────────────────────────────────────────────

  /// Succès — réponse correcte, progression, validation.
  static const Color success = Color(0xFF10B981);

  /// Erreur — réponse fausse, danger, suppression.
  static const Color error = Color(0xFFEF4444);

  /// Avertissement — attention, non bloquant.
  static const Color warning = Color(0xFFF59E0B);

  /// Info — indication neutre.
  static const Color info = Color(0xFF3B82F6);

  // ─── COULEURS TEXTE ───────────────────────────────────────────────────────

  /// Texte principal.
  static const Color textPrimary = Color(0xFFF1F5F9);

  /// Texte secondaire — descriptions, sous-titres.
  static const Color textSecondary = Color(0xFF94A3B8);

  /// Texte désactivé.
  static const Color textDisabled = Color(0xFF475569);

  /// Alias court utilisé dans les widgets (remplace `_slate` partout).
  static const Color slate = textSecondary;

  // ─── BORDURES ─────────────────────────────────────────────────────────────

  /// Bordure par défaut (cartes, inputs).
  static const Color borderSubtle = Color(0x14FFFFFF);

  /// Bordure focus / verre.
  static const Color borderGlass = Color(0x33FFFFFF);

  /// Bordure focus colorée.
  static const Color borderFocus = Color(0x807C6FFF);

  // ─── SPACING (grille 8pt) ─────────────────────────────────────────────────

  static const double spaceXs = 4;
  static const double spaceSm = 8;
  static const double spaceMd = 16;
  static const double spaceLg = 24;
  static const double spaceXl = 32;
  static const double spaceXxl = 48;

  // ─── BORDER RADIUS ────────────────────────────────────────────────────────

  /// Chips, badges, petits éléments.
  static const double radiusSm = 8;

  /// Boutons, inputs.
  static const double radiusMd = 12;

  /// Cartes secondaires, sections.
  static const double radiusLg = 16;

  /// Cartes principales, modales, drawers.
  static const double radiusXl = 20;

  /// Pills, avatars.
  static const double radiusFull = 999;

  // ─── SHADOWS / GLOWS ─────────────────────────────────────────────────────

  static List<BoxShadow> glow(Color c, {double blur = 20, double alpha = 0.25}) =>
      [BoxShadow(color: c.withValues(alpha: alpha), blurRadius: blur, spreadRadius: -4)];

  static List<BoxShadow> get glowViolet => glow(violet);
  static List<BoxShadow> get glowCyan => glow(cyan);
  static List<BoxShadow> get glowGold => glow(gold, alpha: 0.35);
  static List<BoxShadow> get glowError => glow(error, alpha: 0.30);
}
