import 'package:flutter/material.dart';

/// Référence visuelle — alignée `blueprint v3.md` (violet #6C63FF, accent succès #43E97B).
abstract final class EskoliaVisual {
  EskoliaVisual._();

  static const Color bgDeep = Color(0xFF0F0F1A);
  static const Color bgElevated = Color(0xFF151528);

  static const Color neonCyan = Color(0xFF5EEAD4);
  static const Color neonCyanSoft = Color(0xFF2DD4BF);
  static const Color neonViolet = Color(0xFF6C63FF);
  static const Color neonPurple = Color(0xFF8B7CFF);
  static const Color neonGreen = Color(0xFF43E97B);
  static const Color neonGold = Color(0xFFFFD700);
  static const Color neonAmber = Color(0xFFFF9F0A);
  static const Color neonOrange = Color(0xFFFF6B35);

  static const List<Color> borderPrimary = [
    neonViolet,
    Color(0xFFFF6584),
    neonGreen,
  ];

  static const List<Color> borderLive = [
    neonGreen,
    Color(0xFF34D399),
  ];

  static const List<Color> borderGold = [
    Color(0xFFFFE066),
    Color(0xFFB8860B),
  ];

  static List<BoxShadow> glow(Color c, {double blur = 20, double alpha = 0.35}) {
    return [
      BoxShadow(
        color: c.withValues(alpha: alpha),
        blurRadius: blur,
        spreadRadius: -4,
      ),
    ];
  }
}
