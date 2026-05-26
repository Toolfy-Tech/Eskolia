import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/eskolia_visual.dart';
import '../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../shared/widgets/eskolia_shell_body.dart';

const Color _slate = Color(0xFF94A3B8);

/// Ecran post-inscription : guide le nouvel utilisateur vers sa premiere formation.
class FormationChoiceScreen extends StatelessWidget {
  const FormationChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const EskoliaAmbientBackground(),
          EskoliaShellBody(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 56),
                  const Text(
                    'Par ou veux-tu\ncommencer ?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      height: 1.15,
                    ),
                  ).animate().fadeIn(duration: 320.ms).slideY(begin: 0.1, duration: 320.ms),
                  const SizedBox(height: 10),
                  Text(
                    'Choisis ton premier objectif — tu pourras tout explorer ensuite.',
                    style: TextStyle(
                      color: _slate.withValues(alpha: 0.9),
                      fontSize: 15,
                      height: 1.45,
                    ),
                  ).animate().fadeIn(duration: 320.ms, delay: 60.ms),
                  const SizedBox(height: 36),
                  _FormationCard(
                    emoji: '\u{1F4DA}',
                    title: 'Parcours Optimus',
                    subtitle: 'TIP structuré section par section',
                    description:
                        'Cours théoriques, quiz de validation et progression guidée. '
                        'Le chemin recommandé pour l\'examen TIP.',
                    accentColor: EskoliaVisual.neonViolet,
                    delay: 120,
                    onTap: () => context.go('/parcours'),
                  ),
                  const SizedBox(height: 16),
                  _FormationCard(
                    emoji: '⚡',
                    title: 'TIP-Quiz',
                    subtitle: 'Entrainement rapide en mode quiz',
                    description:
                        'Des centaines de questions classées par theme. '
                        'Ideal pour réviser vite et repérer les lacunes.',
                    accentColor: EskoliaVisual.neonCyan,
                    delay: 200,
                    onTap: () => context.go('/quiz/tip'),
                  ),
                  const SizedBox(height: 16),
                  _FormationCard(
                    emoji: '\u{1F9EA}',
                    title: 'Travaux Pratiques',
                    subtitle: 'Mise en situation et exercices terrain',
                    description:
                        'TP réseau, scénarios Active Directory et PowerShell. '
                        'Pour les apprenants qui veulent pratiquer directement.',
                    accentColor: const Color(0xFF34D399),
                    delay: 280,
                    onTap: () => context.go('/tp'),
                  ),
                  const Spacer(),
                  Center(
                    child: TextButton(
                      onPressed: () => context.go('/home'),
                      child: Text(
                        'Explorer d\'abord',
                        style: TextStyle(
                          color: _slate.withValues(alpha: 0.7),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormationCard extends StatelessWidget {
  const _FormationCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.accentColor,
    required this.onTap,
    required this.delay,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final String description;
  final Color accentColor;
  final VoidCallback onTap;
  final int delay;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: accentColor.withValues(alpha: 0.35)),
            color: accentColor.withValues(alpha: 0.05),
          ),
          padding: const EdgeInsets.all(18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: TextStyle(
                        color: _slate.withValues(alpha: 0.85),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_ios_rounded, color: accentColor.withValues(alpha: 0.6), size: 16),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 320.ms, delay: Duration(milliseconds: delay))
        .slideY(begin: 0.08, duration: 320.ms, delay: Duration(milliseconds: delay));
  }
}
