import 'package:flutter/material.dart';

abstract final class EskoliaTokens {
  EskoliaTokens._();

  // ─── FONDS ───────────────────────────────────────────────────────────────
  static const Color bgBase    = Color(0xFF0B1120);
  static const Color surface1  = Color(0xFF111827);
  static const Color surface2  = Color(0xFF1E2A3B);
  static const Color surface3  = Color(0xFF243044);

  // ─── PRIMAIRES ───────────────────────────────────────────────────────────
  static const Color violet     = Color(0xFF7C6FFF);
  static const Color violetSoft = Color(0xFF6C63FF);
  static const Color cyan       = Color(0xFF00D4E8);
  static const Color cyanSoft   = Color(0xFF00D4E8);
  static const Color gold       = Color(0xFFF5C842);
  static const Color amber      = Color(0xFFF59E0B);
  static const Color orange     = Color(0xFFFF9800);

  // ─── STATUTS ─────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF10B981);
  static const Color error   = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info    = Color(0xFF3B82F6);

  // ─── TEXTES ───────────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textDisabled  = Color(0xFF475569);
  static const Color slate         = textSecondary;

  // ─── BORDURES ─────────────────────────────────────────────────────────────
  static const Color borderSubtle = Color(0x14FFFFFF);
  static const Color borderGlass  = Color(0x33FFFFFF);
  static const Color borderFocus  = Color(0x807C6FFF);

  // ─── SPACING (grille 8pt) ─────────────────────────────────────────────────
  static const double spaceXs  = 4;
  static const double spaceSm  = 8;
  static const double spaceMd  = 16;
  static const double spaceLg  = 24;
  static const double spaceXl  = 32;
  static const double spaceXxl = 48;

  // ─── BORDER RADIUS ────────────────────────────────────────────────────────
  static const double radiusSm   = 8;
  static const double radiusMd   = 12;
  static const double radiusLg   = 16;
  static const double radiusXl   = 20;
  static const double radiusFull = 999;

  // ─── GLOWS ────────────────────────────────────────────────────────────────
  static List<BoxShadow> glow(Color c, {double blur = 20, double alpha = 0.20}) =>
      [BoxShadow(color: c.withValues(alpha: alpha), blurRadius: blur, spreadRadius: -4)];

  static List<BoxShadow> get glowViolet => glow(violet, blur: 24, alpha: 0.20);
  static List<BoxShadow> get glowCyan   => glow(cyan,   blur: 16, alpha: 0.15);
  static List<BoxShadow> get glowGold   => glow(gold,   blur: 20, alpha: 0.25);
  static List<BoxShadow> get glowError  => glow(error,  blur: 20, alpha: 0.30);
}
