import 'dart:ui';

import 'package:flutter/material.dart';

/// Halos violet électrique / accent succès — `blueprint v3.md`.
class EskoliaAmbientBackground extends StatelessWidget {
  const EskoliaAmbientBackground({super.key});

  static const Color _violet = Color(0xFF6C63FF);
  static const Color _accent = Color(0xFF43E97B);

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -80,
            left: -80,
            child: _BlurredOrb(
              color: _violet,
              sigma: 80,
              diameter: 280,
              opacity: 0.12,
            ),
          ),
          Positioned(
            bottom: -60,
            right: -60,
            child: _BlurredOrb(
              color: _accent,
              sigma: 60,
              diameter: 240,
              opacity: 0.10,
            ),
          ),
        ],
      ),
    );
  }
}

class _BlurredOrb extends StatelessWidget {
  const _BlurredOrb({
    required this.color,
    required this.sigma,
    required this.diameter,
    required this.opacity,
  });

  final Color color;
  final double sigma;
  final double diameter;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: opacity),
        ),
      ),
    );
  }
}
