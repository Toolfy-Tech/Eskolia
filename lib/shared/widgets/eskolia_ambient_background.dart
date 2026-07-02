import 'dart:ui';
import 'package:flutter/material.dart';

import '../../core/constants/eskolia_tokens.dart';

/// Fond global de l'application — Grille technique de dessin millimétré (Blueprint Grid)
/// posée sur un dégradé bleu TARDIS profond.
class EskoliaAmbientBackground extends StatelessWidget {
  const EskoliaAmbientBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          // Fond dégradé radial bleu TARDIS profond
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.3,
                  colors: [
                    Color(0xFF0C2445), // Tardis bleu de surface
                    Color(0xFF071426), // Tardis bleu sombre de base
                  ],
                ),
              ),
            ),
          ),
          // Grille technique de blueprint en CustomPainter
          Positioned.fill(
            child: CustomPaint(
              painter: _BlueprintGridPainter(),
            ),
          ),
        ],
      ),
    );
  }
}

class _BlueprintGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintGrid = Paint()
      ..color = EskoliaTokens.cyan.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;

    final paintSubGrid = Paint()
      ..color = EskoliaTokens.cyan.withValues(alpha: 0.02)
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
