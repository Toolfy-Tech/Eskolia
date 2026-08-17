import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:eskolia/core/constants/eskolia_tokens.dart';
import 'package:eskolia/features/tp/osi/data/osi_progress_repository.dart';

class TpOsiCardBody extends ConsumerWidget {
  const TpOsiCardBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(osiStatsProvider);
    final stats = statsAsync.value ?? const OsiStats();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Brief Description
        Text(
          '3 ateliers interactifs pour maîtriser les 7 couches OSI, l\'encapsulation et le diagnostic d\'incidents réseau.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 13,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 14),

        // 3 Game Mode chips / quick launchers
        Row(
          children: [
            Expanded(
              child: _buildMiniGameChip(
                context: context,
                emoji: '⚡',
                title: 'Tri Sélectif',
                subtitle: 'Classification',
                color: EskoliaTokens.cyan,
                onTap: () => context.push('/tp/osi/tri'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMiniGameChip(
                context: context,
                emoji: '📦',
                title: 'Voyage Paquet',
                subtitle: 'Encapsulation',
                color: EskoliaTokens.violet,
                onTap: () => context.push('/tp/osi/paquet'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMiniGameChip(
                context: context,
                emoji: '🔍',
                title: 'Enquêteur',
                subtitle: 'Diagnostic IT',
                color: Colors.amberAccent,
                onTap: () => context.push('/tp/osi/enqueteur'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Mastery Progress Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Progression de maîtrise',
                    style: TextStyle(color: Colors.white70, fontSize: 11.5, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${stats.globalMasteryPercent}%',
                    style: const TextStyle(
                      color: EskoliaTokens.cyan,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: stats.globalMasteryPercent / 100,
                  minHeight: 6,
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  valueColor: const AlwaysStoppedAnimation(EskoliaTokens.cyan),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Main CTA
        ElevatedButton.icon(
          onPressed: () => context.push('/tp/osi'),
          icon: const Icon(Icons.play_arrow_rounded, size: 20),
          label: const Text('Ouvrir le Hub Modèle OSI'),
          style: ElevatedButton.styleFrom(
            backgroundColor: EskoliaTokens.cyan,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 12),
            textStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }

  Widget _buildMiniGameChip({
    required BuildContext context,
    required String emoji,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              subtitle,
              style: TextStyle(color: color, fontSize: 9.5, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
