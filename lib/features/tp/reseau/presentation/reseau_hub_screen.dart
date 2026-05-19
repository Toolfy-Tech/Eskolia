import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/eskolia_layout.dart';
import '../../../../core/theme/eskolia_visual.dart';
import '../../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../../shared/widgets/eskolia_app_bar.dart';
import '../../../../shared/widgets/eskolia_shell_body.dart';
import '../data/network_exercise_engine.dart';
import 'network_calculator_sheet.dart';

const Color _slate  = Color(0xFF94A3B8);
const Color _violet = Color(0xFF6C63FF);
const Color _cyan   = Color(0xFF00BCD4);

class ReseauHubScreen extends StatelessWidget {
  const ReseauHubScreen({super.key});

  static const _categories = [
    _CategoryInfo(
      category: NetworkExerciseCategory.binaryConversion,
      slug: 'binaryConversion',
      emoji: '0️⃣',
      title: 'Conversion Binaire',
      description: 'Transforme des octets decimaux en binaire et vice-versa. La brique fondamentale du reseau.',
      color: Color(0xFF6C63FF),
    ),
    _CategoryInfo(
      category: NetworkExerciseCategory.ipClass,
      slug: 'ipClass',
      emoji: '🏷️',
      title: 'Classes IP',
      description: 'Identifie la classe (A, B ou C) d\'une adresse IP a partir de son premier octet.',
      color: Color(0xFF00BCD4),
    ),
    _CategoryInfo(
      category: NetworkExerciseCategory.defaultMask,
      slug: 'defaultMask',
      emoji: '🎭',
      title: 'Masques par defaut',
      description: 'Retrouve le masque de sous-reseau par defaut associe a chaque classe d\'adresse.',
      color: Color(0xFF4CAF50),
    ),
    _CategoryInfo(
      category: NetworkExerciseCategory.cidrNotation,
      slug: 'cidrNotation',
      emoji: '/',
      title: 'Notation CIDR',
      description: 'Convertis un masque en notation /prefix et inversement. Indispensable pour la configuration reseau.',
      color: Color(0xFFFFC107),
      emojiIsText: true,
    ),
    _CategoryInfo(
      category: NetworkExerciseCategory.subnetCalc,
      slug: 'subnetCalc',
      emoji: '🧮',
      title: 'Calcul de sous-reseau',
      description: 'Determine l\'adresse reseau, le broadcast et le nombre d\'hotes a partir d\'une IP et d\'un prefixe.',
      color: Color(0xFFE53935),
    ),
  ];

  void _openCalculator(BuildContext ctx) {
    showModalBottomSheet<void>(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const NetworkCalculatorSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hPad = EskoliaLayout.screenPaddingH;

    return Scaffold(
      backgroundColor: EskoliaVisual.bgDeep,
      appBar: EskoliaAppBar.standard(
        context,
        title: 'Reseau & Adressage IP',
        actions: [
          IconButton(
            icon: const Icon(Icons.calculate_rounded, color: _cyan),
            tooltip: 'Calculatrice reseau',
            onPressed: () => _openCalculator(context),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Stack(
        children: [
          const EskoliaAmbientBackground(),
          EskoliaShellBody(
            safeAreaTop: false,
            child: ListView(
              padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 100),
              children: [
                // Intro banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _cyan.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _cyan.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: _cyan, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '10 questions par session. Utilise la calculatrice (icone en haut a droite) pour t\'aider.',
                          style: TextStyle(color: _slate, fontSize: 13, height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Section label
                Container(
                  decoration: const BoxDecoration(
                    border: Border(left: BorderSide(color: _cyan, width: 3)),
                  ),
                  padding: const EdgeInsets.only(left: 10),
                  child: const Text(
                    'CHOISISSEZ UN ENTRAINEMENT',
                    style: TextStyle(
                      color: _slate,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 11 * 0.08,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ..._categories.map(
                  (cat) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _CategoryCard(info: cat),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------ data

class _CategoryInfo {
  const _CategoryInfo({
    required this.category,
    required this.slug,
    required this.emoji,
    required this.title,
    required this.description,
    required this.color,
    this.emojiIsText = false,
  });

  final NetworkExerciseCategory category;
  final String slug;
  final String emoji;
  final String title;
  final String description;
  final Color color;
  final bool emojiIsText;
}

// ------------------------------------------------------------------ card

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.info});
  final _CategoryInfo info;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/tp/reseau/${info.slug}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border(
            left: BorderSide(color: info.color, width: 3),
            top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
            right: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
            bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: info.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: info.emojiIsText
                    ? Text(
                        info.emoji,
                        style: TextStyle(
                          color: info.color,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'monospace',
                        ),
                      )
                    : Text(info.emoji, style: const TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    info.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    info.description,
                    style: TextStyle(
                      color: _slate.withValues(alpha: 0.8),
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, color: Colors.white24),
          ],
        ),
      ),
    );
  }
}
