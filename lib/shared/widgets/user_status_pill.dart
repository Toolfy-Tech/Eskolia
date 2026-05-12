import 'package:flutter/material.dart';

import '../../core/theme/eskolia_visual.dart';

/// Barre de statut type maquette : initiale, niveau, barre XP, série.
class UserStatusPill extends StatelessWidget {
  const UserStatusPill({
    super.key,
    required this.displayName,
    required this.level,
    required this.xp,
    required this.streak,
  });

  final String displayName;
  final int level;
  final int xp;
  final int streak;

  @override
  Widget build(BuildContext context) {
    final initial =
        displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';
    final inLevel = xp % 1000;
    const cap = 1000;
    final ratio = (inLevel / cap).clamp(0.0, 1.0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF111827).withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
            ),
            boxShadow: EskoliaVisual.glow(
              EskoliaVisual.neonViolet,
              blur: 18,
              alpha: 0.15,
            ),
          ),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          EskoliaVisual.neonViolet.withValues(alpha: 0.9),
                          EskoliaVisual.neonCyanSoft.withValues(alpha: 0.75),
                        ],
                      ),
                      boxShadow: EskoliaVisual.glow(
                        EskoliaVisual.neonCyanSoft,
                        alpha: 0.25,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initial,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Positioned(
                    right: -4,
                    bottom: -2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1F2E),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: EskoliaVisual.neonAmber.withValues(alpha: 0.6),
                        ),
                      ),
                      child: Text(
                        'Niv.$level',
                        style: TextStyle(
                          color: EskoliaVisual.neonAmber,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: SizedBox(
                        height: 7,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Container(
                              color: Colors.white.withValues(alpha: 0.08),
                            ),
                            FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: ratio,
                              child: Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF5B8DEF),
                                      Color(0xFF6C63FF),
                                      Color(0xFF00BCD4),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$inLevel / $cap XP',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (streak >= 1)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('\u{1F525}', style: TextStyle(fontSize: 18)),
                    Text(
                      '$streak',
                      style: TextStyle(
                        color: EskoliaVisual.neonOrange,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ],
                )
              else
                Text(
                  'Commence\nta série !',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.35),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
            ],
          ),
        ),
    );
  }
}
