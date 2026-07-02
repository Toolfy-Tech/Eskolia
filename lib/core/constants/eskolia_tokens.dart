import 'package:flutter/material.dart';

abstract final class EskoliaTokens {
  EskoliaTokens._();

  // ─── FONDS ───────────────────────────────────────────────────────────────
  static const Color bgBase    = Color(0xFF071426); // Tardis Deep Blue
  static const Color surface1  = Color(0xFF0C2545); // Tardis Surface 1
  static const Color surface2  = Color(0xFF12345D); // Tardis Surface 2
  static const Color surface3  = Color(0xFF174375); // Tardis Surface 3

  // ─── PRIMAIRES ───────────────────────────────────────────────────────────
  static const Color violet     = Color(0xFF00BFFF); // Deep Sky Blue (remplace violet)
  static const Color violetSoft = Color(0xFF1E90FF); // Dodger Blue
  static const Color cyan       = Color(0xFF00E5FF); // Hyper Cyan
  static const Color cyanSoft   = Color(0xFF80F3FF); // Light Blueprint Cyan
  static const Color gold       = Color(0xFFFFD700);
  static const Color amber      = Color(0xFFFF9F0A);
  static const Color orange     = Color(0xFFFF6B35);
  static const Color pink       = Color(0xFFFE4A76); // Cyber Pink


  // ─── STATUTS ─────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF00E5A3); // Vert menthe premium
  static const Color error   = Color(0xFFEF4444);
  static const Color warning = Color(0xFFFF9F0A);
  static const Color info    = Color(0xFF3B82F6);

  // ─── TEXTES ───────────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textDisabled  = Color(0xFF475569);
  static const Color slate         = textSecondary;

  // ─── BORDURES ─────────────────────────────────────────────────────────────
  static const Color borderSubtle = Color(0x1AFFFFFF);
  static const Color borderGlass  = Color(0x40FFFFFF);
  static const Color borderFocus  = Color(0x997C5CFF);

  // ─── SPACING (grille 8pt) ─────────────────────────────────────────────────
  static const double spaceXs  = 4;
  static const double spaceSm  = 8;
  static const double spaceMd  = 16;
  static const double spaceLg  = 24;
  static const double spaceXl  = 32;
  static const double spaceXxl = 48;

  // ─── BORDER RADIUS ────────────────────────────────────────────────────────
  static const double radiusSm   = 10;
  static const double radiusMd   = 16;
  static const double radiusLg   = 20;
  static const double radiusXl   = 28;
  static const double radiusFull = 999;

  // ─── GLOWS ────────────────────────────────────────────────────────────────
  static List<BoxShadow> glow(Color c, {double blur = 20, double alpha = 0.20}) =>
      [BoxShadow(color: c.withValues(alpha: alpha), blurRadius: blur, spreadRadius: -4)];

  static List<BoxShadow> get glowViolet => glow(violet, blur: 24, alpha: 0.20);
  static List<BoxShadow> get glowCyan   => glow(cyan,   blur: 16, alpha: 0.15);
  static List<BoxShadow> get glowGold   => glow(gold,   blur: 20, alpha: 0.25);
  static List<BoxShadow> get glowError  => glow(error,  blur: 20, alpha: 0.30);
}
