import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/eskolia_tokens.dart';

class WhatsNewAnnouncementDialog extends StatefulWidget {
  const WhatsNewAnnouncementDialog({super.key});

  static const String prefKey = 'has_seen_whats_new_osi_release_v1';

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

  static Future<void> show(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => const WhatsNewAnnouncementDialog(),
    );
  }

  static Future<void> showIfFirstTime(BuildContext context) async {
    final needed = await shouldShow();
    if (!needed || !context.mounted) return;

    await show(context);
    await markAsSeen();
  }

  @override
  State<WhatsNewAnnouncementDialog> createState() => _WhatsNewAnnouncementDialogState();
}

class _WhatsNewAnnouncementDialogState extends State<WhatsNewAnnouncementDialog> {
  int _currentPage = 0;
  final PageController _pageController = PageController();

  final List<_WhatsNewPageData> _pages = const [
    _WhatsNewPageData(
      badgeEmoji: '🌐',
      badgeLabel: 'NOUVEAU MODULE TP',
      title: 'Le Modèle OSI Débarque !',
      subtitle: '3 ateliers interactifs et immersifs pour maîtriser les 7 couches de transmission réseau.',
      accentColor: EskoliaTokens.cyan,
      sections: [
        _WhatsNewSection(
          icon: '⚡',
          title: 'Le Tri Sélectif (Classification)',
          description: 'Glissez-déposez les protocoles, matériels et PDU sur les bonnes couches. Choisissez votre rythme : Série Express (10 cartes), Complète (20 cartes) ou Mode Survie Sans-Faute !',
        ),
        _WhatsNewSection(
          icon: '📦',
          title: 'Le Voyage du Paquet (Encapsulation)',
          description: 'Empilez et décortiquez la structure du paquet de données étape par étape (Émission 7 ➔ 1 et Réception 1 ➔ 7) avec validation progressive sans spoiler.',
        ),
        _WhatsNewSection(
          icon: '🔍',
          title: 'L\'Enquêteur OSI (Diagnostic IT)',
          description: 'Analysez des tickets d\'incident et pannes réelles (logs, câblage, VLAN, DNS, pare-feu). Isolez la couche en cause et appliquez l\'action de support corrective.',
        ),
      ],
      actionButtonLabel: 'Voir le Mémento ➔',
    ),
    _WhatsNewPageData(
      badgeEmoji: '📖',
      badgeLabel: 'COURS & AIDE EN DIRECT',
      title: 'Mémento OSI Concret & Accessible',
      subtitle: 'Finies les définitions abstraites : comprenez chaque couche avec des images concrètes et des cas réels.',
      accentColor: Color(0xFFA855F7),
      sections: [
        _WhatsNewSection(
          icon: '💡',
          title: 'Analogies Vivantes du Quotidien',
          description: 'La lettre écrite (L7), le traducteur chiffré (L6), l\'appel téléphonique (L5), le transporteur (L4), l\'adresse postale IP (L3), l\'étiquette MAC locale (L2), le câble électrique (L1).',
        ),
        _WhatsNewSection(
          icon: '💻',
          title: 'Outils & Commandes CLI',
          description: 'Toutes les commandes utiles en support IT (ping, tracert, nslookup, ipconfig, netstat -ano, wireshark, testeur de câble RJ45).',
        ),
        _WhatsNewSection(
          icon: '🚀',
          title: 'Accessible Partout en 1 Clic',
          description: 'Un bouton 📖 est disponible dans l\'en-tête de chaque TP pour consulter le Mémento sans perdre votre partie en cours !',
        ),
      ],
      actionButtonLabel: 'Voir le Multijoueur ➔',
    ),
    _WhatsNewPageData(
      badgeEmoji: '⚔️',
      badgeLabel: 'STABILITÉ & MULTIJOUEUR',
      title: 'Salons Multijoueurs & Améliorations',
      subtitle: 'Optimisations globales des performances et synchronisation des combats en temps réel.',
      accentColor: Color(0xFFFFB300),
      sections: [
        _WhatsNewSection(
          icon: '🛡️',
          title: 'Salons & Lobbies Multijoueurs',
          description: 'Correction complète des permissions de synchronisation : rejoignez et créez des salons de quiz sans accroc avec vos camarades.',
        ),
        _WhatsNewSection(
          icon: '🎯',
          title: 'Explications Détaillées lors des Erreurs',
          description: 'Chaque erreur commise dans les TP affiche une fiche explicative avec le rôle de la couche et un lien direct vers le cours associé.',
        ),
        _WhatsNewSection(
          icon: '✨',
          title: 'Ergonomie & Design Épuré',
          description: 'Interface TP simplifiée, plus sobre et sans spoilers, pour maximiser la rétention et l\'apprentissage actif.',
        ),
      ],
      actionButtonLabel: 'Explorer les TP Modèle OSI 🚀',
      targetRoute: '/tp/osi',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      final route = _pages[_currentPage].targetRoute;
      Navigator.of(context).pop();
      if (route != null) {
        context.push(route);
      }
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final page = _pages[_currentPage];

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 540,
            maxHeight: screenHeight * 0.88,
          ),
          decoration: BoxDecoration(
            color: EskoliaTokens.surface1.withValues(alpha: 0.98),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: page.accentColor.withValues(alpha: 0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: page.accentColor.withValues(alpha: 0.20),
                blurRadius: 30,
                spreadRadius: -4,
              ),
              const BoxShadow(
                color: Colors.black87,
                blurRadius: 20,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Column(
              children: [
                // Top Header with Badge, Step Tracker and Close Button
                _buildHeader(page),

                // PageView with the 3 sections
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (idx) => setState(() => _currentPage = idx),
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return _buildPageContent(_pages[index]);
                    },
                  ),
                ),

                // Bottom Navigation & Actions
                _buildBottomNav(page),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(_WhatsNewPageData page) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: page.accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: page.accentColor.withValues(alpha: 0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(page.badgeEmoji, style: const TextStyle(fontSize: 13)),
                const SizedBox(width: 6),
                Text(
                  page.badgeLabel,
                  style: TextStyle(
                    color: page.accentColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 10.5,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Dots Indicator
          Row(
            children: List.generate(_pages.length, (idx) {
              final isCurrent = idx == _currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isCurrent ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isCurrent ? page.accentColor : Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
              );
            }),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white60, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'Fermer',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildPageContent(_WhatsNewPageData page) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      children: [
        Text(
          page.title,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          page.subtitle,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 13,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16),
        ...page.sections.map((section) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(section.icon, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        section.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        section.description,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildBottomNav(_WhatsNewPageData page) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
      ),
      child: Row(
        children: [
          if (_currentPage > 0)
            TextButton.icon(
              onPressed: _prevPage,
              icon: const Icon(Icons.arrow_back_rounded, size: 16),
              label: const Text('Précédent'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white60,
                textStyle: const TextStyle(fontSize: 12.5),
              ),
            )
          else
            Text(
              'Page ${_currentPage + 1} / ${_pages.length}',
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            ),
          const Spacer(),
          ElevatedButton(
            onPressed: _nextPage,
            style: ElevatedButton.styleFrom(
              backgroundColor: page.accentColor,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            child: Text(page.actionButtonLabel),
          ),
        ],
      ),
    );
  }
}

class _WhatsNewPageData {
  const _WhatsNewPageData({
    required this.badgeEmoji,
    required this.badgeLabel,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.sections,
    required this.actionButtonLabel,
    this.targetRoute,
  });

  final String badgeEmoji;
  final String badgeLabel;
  final String title;
  final String subtitle;
  final Color accentColor;
  final List<_WhatsNewSection> sections;
  final String actionButtonLabel;
  final String? targetRoute;
}

class _WhatsNewSection {
  const _WhatsNewSection({
    required this.icon,
    required this.title,
    required this.description,
  });

  final String icon;
  final String title;
  final String description;
}
