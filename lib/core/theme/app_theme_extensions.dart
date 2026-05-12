import 'package:flutter/material.dart';

/// Tokens glassmorphism injectés dans [ThemeData.extensions].
class GlassmorphismTheme extends ThemeExtension<GlassmorphismTheme> {
  const GlassmorphismTheme({
    required this.glassColor,
    required this.borderColor,
    required this.blur,
  });

  final Color glassColor;
  final Color borderColor;

  /// Sigma du flou (BackdropFilter).
  final double blur;

  @override
  GlassmorphismTheme copyWith({
    Color? glassColor,
    Color? borderColor,
    double? blur,
  }) {
    return GlassmorphismTheme(
      glassColor: glassColor ?? this.glassColor,
      borderColor: borderColor ?? this.borderColor,
      blur: blur ?? this.blur,
    );
  }

  @override
  GlassmorphismTheme lerp(
    ThemeExtension<GlassmorphismTheme>? other,
    double t,
  ) {
    if (other is! GlassmorphismTheme) return this;
    return GlassmorphismTheme(
      glassColor: Color.lerp(glassColor, other.glassColor, t)!,
      borderColor: Color.lerp(borderColor, other.borderColor, t)!,
      blur: blur + (other.blur - blur) * t,
    );
  }
}

/// Lueur néon pour boutons et accents.
class NeonTheme extends ThemeExtension<NeonTheme> {
  const NeonTheme({
    required this.neonColor,
    required this.shadowColor,
    required this.intensity,
  });

  final Color neonColor;
  final Color shadowColor;

  /// Multiplicateur de force pour les ombres (typ. 0–1.5).
  final double intensity;

  @override
  NeonTheme copyWith({
    Color? neonColor,
    Color? shadowColor,
    double? intensity,
  }) {
    return NeonTheme(
      neonColor: neonColor ?? this.neonColor,
      shadowColor: shadowColor ?? this.shadowColor,
      intensity: intensity ?? this.intensity,
    );
  }

  @override
  NeonTheme lerp(ThemeExtension<NeonTheme>? other, double t) {
    if (other is! NeonTheme) return this;
    return NeonTheme(
      neonColor: Color.lerp(neonColor, other.neonColor, t)!,
      shadowColor: Color.lerp(shadowColor, other.shadowColor, t)!,
      intensity: intensity + (other.intensity - intensity) * t,
    );
  }
}
