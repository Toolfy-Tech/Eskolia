import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/eskolia_tokens.dart';
import '../../../core/theme/eskolia_layout.dart';
import '../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../shared/widgets/eskolia_shell_body.dart';
import '../../../shared/widgets/eskolia_card.dart';

const Color _slateLight = EskoliaTokens.textSecondary;
const Color _cyan = EskoliaTokens.cyan;
const Color _green = EskoliaTokens.success;
const Color _violet = EskoliaTokens.violetSoft;
const Color _orange = EskoliaTokens.orange;

class SoloScreen extends StatelessWidget {
  const SoloScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final hPad = EskoliaLayout.lessonHorizontalPadding(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const EskoliaAmbientBackground(),
          EskoliaShellBody(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 0),
                  child: const Text(
                    'Pratique',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 24),
                    children: [
                      const _CategoryHeader(
                        title: 'QUIZ SOLO',
                        color: EskoliaTokens.cyan,
                      ),
                      const SizedBox(height: 12),
                      _SoloMenuCard(
                        title: 'Creer un Quiz',
                        subtitle:
                            'Selectionne des chapitres, importe un fichier ou joue un quiz Eskolia en solo.',
                        icon: Icons.quiz_rounded,
                        accentColor: _cyan,
                        onTap: () => context.push('/quiz/setup'),
                      ),
                      const SizedBox(height: 12),
                      _SoloMenuCard(
                        title: 'Mode Maitrise IA',
                        subtitle:
                            'Genere un quiz personnalise depuis tes notes via l\'IA — comme le multi, mais en solo.',
                        icon: Icons.auto_awesome_rounded,
                        accentColor: _violet,
                        onTap: () => context.push('/solo/quiz-solo'),
                      ),
                      const SizedBox(height: 32),
                      const _CategoryHeader(
                        title: 'CONTENU OFFICIEL',
                        color: EskoliaTokens.violetSoft,
                      ),
                      const SizedBox(height: 12),
                      _SoloMenuCard(
                        title: 'Travaux Pratiques (TP)',
                        subtitle:
                            'Mise en situation reelle sur Windows Server (Active Directory).',
                        icon: Icons.terminal_rounded,
                        accentColor: Colors.blueAccent,
                        onTap: () => context.push('/tp'),
                      ),
                      const SizedBox(height: 32),
                      const _CategoryHeader(
                        title: 'ENTRAINEMENT LIBRE',
                        color: EskoliaTokens.cyan,
                      ),
                      const SizedBox(height: 12),
                      _SoloMenuCard(
                        title: 'Flashcards',
                        subtitle: 'Memorisation active par repetition espacee.',
                        icon: Icons.style_rounded,
                        accentColor: _green,
                        onTap: () => context.push('/flashcards'),
                      ),
                      const SizedBox(height: 12),
                      _SoloMenuCard(
                        title: 'Lexique IT',
                        subtitle:
                            'Retrouve la signification des acronymes IT — sans indices.',
                        icon: Icons.abc_rounded,
                        accentColor: _orange,
                        onTap: () => context.push('/lexique'),
                      ),
                      const SizedBox(height: 40),
                      Text(
                        'Mode Active Recall active : toutes les reponses sont a saisir librement pour un ancrage memoriel maximal.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _slateLight.withValues(alpha: 0.5),
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 100),
                    ],
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

class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader({required this.title, required this.color});

  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      padding: const EdgeInsets.only(left: 10),
      child: Text(
        title,
        style: TextStyle(
          color: EskoliaTokens.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 11 * 0.08,
        ),
      ),
    );
  }
}

class _SoloMenuCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;

  const _SoloMenuCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return EskoliaCardContent(
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accentColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: _slateLight.withValues(alpha: 0.8),
                    fontSize: 11,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: Colors.white.withValues(alpha: 0.3),
            size: 20,
          ),
        ],
      ),
    );
  }
}
