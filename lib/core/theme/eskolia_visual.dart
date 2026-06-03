import 'package:flutter/material.dart';

import '../constants/eskolia_tokens.dart';

export '../constants/eskolia_tokens.dart';

/// Helpers visuels (glows, gradients) — s'appuient sur EskoliaTokens.
abstract final class EskoliaVisual {
  EskoliaVisual._();

  // Aliases rétro-compatibles
  static const Color bgDeep = EskoliaTokens.bgBase;
  static const Color bgElevated = EskoliaTokens.surface1;

  static const Color neonCyan = EskoliaTokens.cyan;
  static const Color neonCyanSoft = EskoliaTokens.cyanSoft;
  static const Color neonViolet = EskoliaTokens.violet;
  static const Color neonPurple = Color(0xFF8B7CFF);
  static const Color neonGreen = EskoliaTokens.success;
  static const Color neonGold = EskoliaTokens.gold;
  static const Color neonAmber = EskoliaTokens.amber;
  static const Color neonOrange = EskoliaTokens.orange;

  static const List<Color> borderPrimary = [
    EskoliaTokens.violet,
    Color(0xFFFF6584),
    EskoliaTokens.success,
  ];

  static const List<Color> borderLive = [
    EskoliaTokens.success,
    Color(0xFF34D399),
  ];

  static const List<Color> borderGold = [
    Color(0xFFFFE066),
    Color(0xFFB8860B),
  ];

  static List<BoxShadow> glow(Color c, {double blur = 20, double alpha = 0.25}) =>
      EskoliaTokens.glow(c, blur: blur, alpha: alpha);
}
