import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/eskolia_tokens.dart';
import '../../core/theme/theme_palette_provider.dart';

/// Fond global de l'application — Grille technique de dessin millimétré (Blueprint Grid)
/// posée sur un dégradé dynamique selon le thème de couleurs choisi.
class EskoliaAmbientBackground extends ConsumerWidget {
  const EskoliaAmbientBackground({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = ref.watch(themePaletteProvider);

    return IgnorePointer(
      child: Stack(
        children: [
          // Fond dégradé radial dynamique
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              decoration: BoxDecoration(
                gradient: palette.backgroundGradient,
              ),
            ),
          ),
          // Grille technique de blueprint en CustomPainter
          Positioned.fill(
            child: CustomPaint(
              painter: _BlueprintGridPainter(
                primaryGridColor: palette.gridPrimaryColor,
                secondaryGridColor: palette.gridSecondaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BlueprintGridPainter extends CustomPainter {
  const _BlueprintGridPainter({
    required this.primaryGridColor,
    required this.secondaryGridColor,
  });

  final Color primaryGridColor;
  final Color secondaryGridColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paintGrid = Paint()
      ..color = primaryGridColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;

    final paintSubGrid = Paint()
      ..color = secondaryGridColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.4;

    const double step = 40.0; // Grille principale tous les 40px
    const int subDivisions = 4; // Sous-divisions de 10px

    // Lignes verticales
    for (double x = 0.0; x <= size.width; x += step / subDivisions) {
      final double remainder = x % step;
      final bool isMain = remainder < 0.1 || (step - remainder) < 0.1;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        isMain ? paintGrid : paintSubGrid,
      );
    }

    // Lignes horizontales
    for (double y = 0.0; y <= size.height; y += step / subDivisions) {
      final double remainder = y % step;
      final bool isMain = remainder < 0.1 || (step - remainder) < 0.1;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        isMain ? paintGrid : paintSubGrid,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BlueprintGridPainter oldDelegate) =>
      oldDelegate.primaryGridColor != primaryGridColor ||
      oldDelegate.secondaryGridColor != secondaryGridColor;
}
