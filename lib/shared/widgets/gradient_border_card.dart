import 'package:flutter/material.dart';

import '../../core/constants/eskolia_tokens.dart';

/// Carte avec bordure en dégradé et fond sombre glassy — proche des maquettes néon.
class GradientBorderCard extends StatelessWidget {
  const GradientBorderCard({
    super.key,
    required this.child,
    this.gradientColors,
    this.borderWidth = 1.5,
    this.borderRadius = 20,
    this.innerColor = EskoliaTokens.surface1,
    this.innerBlurSigma = 12.0,
    this.glowColor,
    this.padding = const EdgeInsets.all(18),
    this.margin,
  });

  final Widget child;
  final List<Color>? gradientColors;
  final double borderWidth;
  final double borderRadius;
  final Color innerColor;
  final double innerBlurSigma;
  final Color? glowColor;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final colors = gradientColors ??
        const [
          EskoliaTokens.violet,
          EskoliaTokens.pink,
          EskoliaTokens.success,
        ];
    final r = borderRadius;
    final innerR = (r - borderWidth).clamp(4.0, r);

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(r),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
          boxShadow: glowColor != null
              ? [
                  BoxShadow(
                    color: glowColor!.withValues(alpha: 0.32),
                    blurRadius: 22,
                    spreadRadius: -3,
                  ),
                ]
              : null,
        ),
        padding: EdgeInsets.all(borderWidth),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(innerR),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: innerColor,
              borderRadius: BorderRadius.circular(innerR),
            ),
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}
