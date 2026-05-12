import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/eskolia_layout.dart';
import '../../../core/theme/eskolia_visual.dart';
import '../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../shared/widgets/eskolia_shell_body.dart';
import '../../../shared/widgets/eskolia_card.dart';

const Color _slateLight = Color(0xFF94A3B8);
const Color _cyan = Color(0xFF00BCD4);
const Color _orange = Color(0xFFFF9800);
const Color _green = Color(0xFF43E97B);

class SoloScreen extends StatefulWidget {
  const SoloScreen({super.key});

  @override
  State<SoloScreen> createState() => _SoloScreenState();
}

class _SoloScreenState extends State<SoloScreen> {
  @override
  Widget build(BuildContext context) {
    final hPad = EskoliaLayout.lessonHorizontalPadding(context);
    
    return Scaffold(
      backgroundColor: EskoliaVisual.bgDeep,
      body: Stack(
        children: [
          const EskoliaAmbientBackground(),
          EskoliaShellBody(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(hPad),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 24),
                    children: [
                      const _CategoryHeader(title: 'CONTENU OFFICIEL', color: Color(0xFF6C63FF)),
                      const SizedBox(height: 12),
                      _SoloMenuCard(
                        title: "Travaux Pratiques (TP)",
                        subtitle: "Mise en situation réelle sur Windows Server (Active Directory).",
                        icon: Icons.terminal_rounded,
                        accentColor: Colors.blueAccent,
                        onTap: () => context.push('/tp'),
                      ),
                      const SizedBox(height: 32),
                      
                      const _CategoryHeader(title: 'ENTRAÎNEMENT LIBRE', color: Color(0xFF22D3EE)),
                      const SizedBox(height: 12),
                      _SoloMenuCard(
                        title: "Configurateur Maîtrise",
                        subtitle: "Mixez les thèmes pour renforcer vos points faibles.",
                        icon: Icons.settings_input_component_rounded,
                        accentColor: _cyan,
                        onTap: () => context.push('/solo/quiz-solo'),
                      ),
                      const SizedBox(height: 12),
                      _SoloMenuCard(
                        title: "Vrai ou Faux",
                        subtitle: "Décision rapide pour ancrer les concepts clés.",
                        icon: Icons.thumbs_up_down_rounded,
                        accentColor: Colors.amber,
                        onTap: () => context.push('/true-false'),
                      ),
                      const SizedBox(height: 12),
                      _SoloMenuCard(
                        title: "Flashcards",
                        subtitle: "Mémorisation active par répétition espacée.",
                        icon: Icons.style_rounded,
                        accentColor: _green,
                        onTap: () => context.push('/flashcards'),
                      ),
                      const SizedBox(height: 32),

                      const _CategoryHeader(title: 'RÉVISION', color: Color(0xFFEF9F27)),
                      const SizedBox(height: 12),
                      _SoloMenuCard(
                        title: "Mes lacunes",
                        subtitle: "Reprends les questions où tu as échoué récemment.",
                        icon: Icons.error_outline_rounded,
                        accentColor: _orange,
                        onTap: () => context.push('/quiz/revision-lacunes'),
                      ),
                      const SizedBox(height: 12),
                      _SoloMenuCard(
                        title: "Le Pool",
                        subtitle: "Tes questions épinglées pour une révision ciblée.",
                        icon: Icons.push_pin_rounded,
                        accentColor: _orange,
                        onTap: () => context.push('/revision-pool'),
                      ),
                      const SizedBox(height: 32),
                      
                      const SizedBox(height: 40),
                      Text(
                        "Mode Active Recall activé : toutes les réponses sont à saisir librement pour un ancrage mémoriel maximal.",
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

  Widget _buildHeader(double hPad) {
    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "S'entraîner",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
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
        title.toUpperCase(),
        style: TextStyle(
          color: const Color(0xFF94A3B8),
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
          Icon(Icons.chevron_right_rounded, color: Colors.white.withValues(alpha: 0.3), size: 20),
        ],
      ),
    );
  }
}
