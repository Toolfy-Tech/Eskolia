import 'package:flutter/material.dart';

/// Référence visuelle — alignée `blueprint v3.md` (violet #6C63FF, accent succès #43E97B).
abstract final class EskoliaVisual {
  EskoliaVisual._();

  static const Color bgDeep = Color(0xFF071426); // Tardis Deep Blue
  static const Color bgElevated = Color(0xFF0C2545); // Tardis Surface 1

  static const Color neonCyan = Color(0xFF00E5FF);
  static const Color neonCyanSoft = Color(0xFF80F3FF);
  static const Color neonViolet = Color(0xFF00BFFF); // Sky Blue
  static const Color neonPurple = Color(0xFF1E90FF); // Dodger Blue
  static const Color neonGreen = Color(0xFF00E5A3);
  static const Color neonGold = Color(0xFFFFD700);
  static const Color neonAmber = Color(0xFFFF9F0A);
  static const Color neonOrange = Color(0xFFFF6B35);

  static const List<Color> borderPrimary = [
    neonViolet,
    Color(0xFFFE4A76),
    neonGreen,
  ];

  static const List<Color> borderLive = [
    neonGreen,
    Color(0xFF00FFC4),
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
