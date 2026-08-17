import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/eskolia_tokens.dart';

class ExamBlancAnnouncementDialog extends StatelessWidget {
  const ExamBlancAnnouncementDialog({super.key});

  static const String prefKey = 'has_seen_patchnote_and_exams_v2_2';

  static Future<bool> shouldShow() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return !(prefs.getBool(prefKey) ?? false);
    } catch (_) {
      return false;
    }
  }

  static Future<void> markAsSeen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(prefKey, true);
    } catch (_) {}
  }

  static Future<void> showIfFirstTime(BuildContext context) async {
    final needed = await shouldShow();
    if (!needed || !context.mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => const ExamBlancAnnouncementDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    const goldColor = Color(0xFFFFB300);
    const cyanColor = EskoliaTokens.cyan;

    final screenHeight = MediaQuery.sizeOf(context).height;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 520,
            maxHeight: screenHeight * 0.88,
          ),
          decoration: BoxDecoration(
            color: EskoliaTokens.surface1.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: goldColor.withValues(alpha: 0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: goldColor.withValues(alpha: 0.20),
                blurRadius: 30,
                spreadRadius: -4,
              ),
              const BoxShadow(
                color: Colors.black54,
                blurRadius: 20,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // En-tête fixe
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: goldColor.withValues(alpha: 0.15),
                          border: Border.all(color: goldColor.withValues(alpha: 0.6), width: 1.5),
                        ),
                        alignment: Alignment.center,
                        child: const Text('🚀', style: TextStyle(fontSize: 22)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Nouveautés & Mises à jour',
                                  style: GoogleFonts.outfit(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: cyanColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: cyanColor.withValues(alpha: 0.4)),
                                  ),
                                  child: const Text(
                                    'v2.2',
                                    style: TextStyle(
                                      color: cyanColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Découvrez les dernières améliorations d\'Eskolia',
                              style: TextStyle(
                                fontSize: 12,
                                color: EskoliaTokens.textSecondary.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white12, height: 1),

                // Contenu défilable
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Section 1 : Examens Blancs & TP Pratiques
                        _buildPatchSection(
                          accentColor: goldColor,
                          badgeIcon: '🎓',
                          badgeLabel: 'NOUVEAU MODULE',
                          title: '8 Quiz d\'Examens & 4 TP Pratiques VM',
                          description: 'Une section complète pour préparer le Titre Pro TIP en conditions réelles.',
                          items: [
                            _PatchItem('📝', '8 Quiz d\'examen complets', '280 questions transversales sans chrono (Alpha à Theta).'),
                            _PatchItem('🛠️', '4 Épreuves pratiques sur VM Win 11', 'Francis, Claire, Marc et Sylvain avec checklist et guide de recette.'),
                            _PatchItem('🔓', 'Corrigé & Auto-évaluation sur 20', 'Déblocage des étapes GUI Windows 11 US, scripts PowerShell et grille jury.'),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Section 2 : Responsive & Mobile
                        _buildPatchSection(
                          accentColor: EskoliaTokens.cyan,
                          badgeIcon: '📱',
                          badgeLabel: 'ERGONOMIE & MOBILE',
                          title: 'Optimisation Mobile & Tablette',
                          description: 'Expérience fluide et adaptée à tous vos appareils.',
                          items: [
                            _PatchItem('📲', 'Plein écran smartphone', 'Contenu à 100% de largeur, barre de navigation tactile et tiroir menu latéral.'),
                            _PatchItem('🏷️', 'Titres d\'en-têtes épurés', 'Compaction des actions pour un affichage textuel parfait sans coupures verticales.'),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Section 3 : Colonnes & Thèmes
                        _buildPatchSection(
                          accentColor: const Color(0xFFC084FC),
                          badgeIcon: '🎨',
                          badgeLabel: 'PERSONNALISATION',
                          title: 'Sélecteur de Colonnes & Ambiances',
                          description: 'Adaptez l\'interface selon vos préférences de travail.',
                          items: [
                            _PatchItem('🎛️', 'Disposition 1 à 4 colonnes', 'Basculez librement sur les Lobbys, Bloc-notes et Docs avec mémorisation.'),
                            _PatchItem('🌈', '4 Thèmes de couleurs dans la sidebar', 'Cyan Tardis, Néon Violet, Menthe Émeraude ou Or Impérial avec fond dynamique.'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const Divider(color: Colors.white12, height: 1),

                // Boutons d'action inférieurs
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () async {
                            await markAsSeen();
                            if (context.mounted) Navigator.of(context).pop();
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(
                            'Continuer',
                            style: GoogleFonts.outfit(
                              color: EskoliaTokens.textSecondary,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await markAsSeen();
                            if (context.mounted) {
                              Navigator.of(context).pop();
                              context.push('/exams');
                            }
                          },
                          icon: const Icon(Icons.school_rounded, size: 16, color: Colors.black),
                          label: Text(
                            'Voir les Examens Blancs',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: goldColor,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPatchSection({
    required Color accentColor,
    required String badgeIcon,
    required String badgeLabel,
    required String title,
    required String description,
    required List<_PatchItem> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accentColor.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: accentColor.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(badgeIcon, style: const TextStyle(fontSize: 11)),
                    const SizedBox(width: 4),
                    Text(
                      badgeLabel,
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 14.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            description,
            style: TextStyle(
              color: Colors.white60,
              fontSize: 11.5,
            ),
          ),
          const SizedBox(height: 10),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.emoji, style: const TextStyle(fontSize: 13)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(fontSize: 11.5, height: 1.3),
                          children: [
                            TextSpan(
                              text: '${item.title} : ',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextSpan(
                              text: item.detail,
                              style: TextStyle(
                                color: EskoliaTokens.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _PatchItem {
  const _PatchItem(this.emoji, this.title, this.detail);
  final String emoji;
  final String title;
  final String detail;
}
