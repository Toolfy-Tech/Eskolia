import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../home/presentation/providers/home_providers.dart';
import '../../home/presentation/widgets/home_card_settings_dialog.dart';
import '../../../core/services/eskolia_folder_service.dart';
import '../../../core/theme/eskolia_layout.dart';
import '../../../core/theme/eskolia_visual.dart';
import '../../../core/widgets/bottom_nav.dart';
import '../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../shared/widgets/eskolia_shell_body.dart';
import '../../../shared/widgets/eskolia_card.dart';
import 'docs_mini_course_dialog.dart';
import '../../../core/constants/eskolia_tokens.dart';
import 'providers/docs_providers.dart';

import '../../quiz/services/quiz_repository.dart';
import '../../flashcards/data/flashcard_deck_repository.dart';
import '../../flashcards/presentation/flashcard_session_screen.dart';

const Color _slate = EskoliaTokens.textSecondary;

Future<void> openDocsUrl(BuildContext context, String url) async {
  final uri = Uri.parse(url);
  final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!ok && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Impossible d\'ouvrir le lien.')),
    );
  }
}

/// Ressources métiers : conformité, cybersécurité, réseaux, gestion des services IT.
class DocsScreen extends ConsumerStatefulWidget {
  const DocsScreen({super.key});

  @override
  ConsumerState<DocsScreen> createState() => _DocsScreenState();

  static const String assetMiniRgpd = 'data/docs/mini_formation_rgpd.md';
  static const String assetMiniCnil = 'data/docs/mini_formation_cnil.md';
  static const String assetMiniAnssi = 'data/docs/mini_formation_anssi.md';
  static const String assetMiniItil = 'data/docs/mini_formation_itil.md';
  static const String assetMiniOsi = 'data/docs/mini_formation_osi.md';

  static const String cnilRgpd =
      'https://www.cnil.fr/fr/reglement-europeen-protection-donnees';
  static const String cnilHome = 'https://www.cnil.fr/';
  static const String anssiHome = 'https://www.ssi.gouv.fr/';
  static const String itilHome = 'https://www.axelos.com/best-practice-solutions/itil';

  static const String rgpdBody = '• Finalité et base légale avant de traiter des données perso.\n'
      '• Minimisation : ne collecter que le nécessaire.\n'
      '• Droits des personnes : information, accès, rectification, effacement, '
      'limitation, opposition, portabilité selon les cas.\n'
      '• Sécurité : mesures techniques et organisationnelles adaptées au risque.\n'
      '• Violation de données : analyse et notification dans les délais (souvent 72 h).\n'
      '• Registre des traitements et AIPD lorsque requis.';

  static const String cnilBody = 'La CNIL est l\'autorité française de protection des données. '
      'Elle publie guides, modèles et recommandations (sécurité, cookies, RH, etc.) '
      'et peut être saisie en cas de difficulté. Identifier un DPO si la taille '
      'ou le type d\'activité l\'impose.';

  static const String anssiBody = 'L\'ANSSI oriente la cybersécurité en France : bonnes pratiques, '
      'guides d\'hygiène numérique, référentiels et réponse à incident. '
      'Pour un technicien : durcissement, segmentation, journaux, sauvegardes testées, '
      'gestion des mises à jour et culture du signalement.';

  static const String itilBody = '• SVS (Service Value System) : gouvernance, pratiques, '
      'chaîne de valeur et amélioration continue.\n'
      '• 4 dimensions : Organisations, Information/Tech, Partenaires, Flux de valeur.\n'
      '• Pratiques clés : gestion des incidents, des problèmes, des changements, '
      'centre de services, SLA/OLA.\n'
      '• Incident = interruption non planifiée. Problème = cause racine. '
      'CMDB = inventaire des CI.\n'
      '• 7 principes directeurs dont : focaliser sur la valeur, itérer avec feedback, simplifier.';

  static const String osiBody = '• 7 couches (bas → haut) : Physique, Liaison, Réseau, '
      'Transport, Session, Présentation, Application.\n'
      '• Couche 3 (Réseau) : IP, routeurs. Couche 2 (Liaison) : MAC, switches.\n'
      '• TCP (couche 4) : fiable et ordonné. UDP : rapide mais sans garantie.\n'
      '• Encapsulation : données → segment → paquet → trame → bits.\n'
      '• TCP/IP regroupe en 4 couches : Application, Transport, Internet, Accès réseau.';

  static const String technicianBody = '• Moindre privilège et comptes nominatifs (éviter les comptes partagés).\n'
      '• Traçabilité : qui a accédé à quoi, et pourquoi.\n'
      '• Sauvegardes 3-2-1 et tests de restauration réguliers.\n'
      '• Patchs et inventaire : savoir ce qui est exposé.\n'
      '• Pas de copie de bases de prod sur poste non sécurisé.\n'
      '• Chiffrement des supports nomades et des canaux sensibles.\n'
      '• En cas d\'incident : préserver les preuves, escalader, ne pas improviser seul.';
}

class _DocsScreenState extends ConsumerState<DocsScreen> {
  Timer? _dragDebounceTimer;
  String? _hoveredDragKey;
  final Map<String, GlobalKey> _cardKeys = {};

  GlobalKey _getOrCreateKey(String cardKey) {
    return _cardKeys.putIfAbsent(cardKey, () => GlobalKey(debugLabel: cardKey));
  }

  @override
  void dispose() {
    _dragDebounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hPad = EskoliaLayout.lessonHorizontalPadding(context);
    final width = MediaQuery.sizeOf(context).width;

    int numColumns;
    if (width > 1200) {
      numColumns = 3;
    } else if (width > 800) {
      numColumns = 2;
    } else {
      numColumns = 1;
    }

    final sidebarWidth = width > 800 ? (ref.watch(sidebarCollapsedProvider) ? 78 : 250) : 0;
    final availableWidth = width - sidebarWidth - 48; // marges et padding
    final cardWidth = numColumns == 3
        ? (availableWidth - 32) / 3
        : (numColumns == 2 ? (availableWidth - 16) / 2 : (width - 40));

    final order = ref.watch(docsCardsOrderProvider);
    final pinned = ref.watch(docsPinnedCardsProvider);

    List<Widget> addSpacing(List<Widget> list) {
      if (list.isEmpty) return [];
      final res = <Widget>[];
      for (var i = 0; i < list.length; i++) {
        res.add(list[i]);
        if (i < list.length - 1) {
          res.add(const SizedBox(height: 16));
        }
      }
      return res;
    }

    Widget buildGrid(List<String> keys) {
      final cards = keys.map((key) {
        return _buildDraggableCard(key, _buildCardContent(key, context), cardWidth);
      }).toList();

      if (numColumns == 3) {
        final col1 = <Widget>[];
        final col2 = <Widget>[];
        final col3 = <Widget>[];
        for (var i = 0; i < keys.length; i++) {
          if (i % 3 == 0) {
            col1.add(cards[i]);
          } else if (i % 3 == 1) {
            col2.add(cards[i]);
          } else {
            col3.add(cards[i]);
          }
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Column(children: addSpacing(col1))),
            const SizedBox(width: 16),
            Expanded(child: Column(children: addSpacing(col2))),
            const SizedBox(width: 16),
            Expanded(child: Column(children: addSpacing(col3))),
          ],
        );
      } else if (numColumns == 2) {
        final col1 = <Widget>[];
        final col2 = <Widget>[];
        for (var i = 0; i < keys.length; i++) {
          if (i % 2 == 0) {
            col1.add(cards[i]);
          } else {
            col2.add(cards[i]);
          }
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Column(children: addSpacing(col1))),
            const SizedBox(width: 16),
            Expanded(child: Column(children: addSpacing(col2))),
          ],
        );
      } else {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: addSpacing(cards),
        );
      }
    }

    Widget content;
    if (pinned.isEmpty) {
      content = buildGrid(order);
    } else {
      final pinnedKeys = order.where((k) => pinned.contains(k)).toList();
      final otherKeys = order.where((k) => !pinned.contains(k)).toList();
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSectionHeader('Épinglées'),
          buildGrid(pinnedKeys),
          if (otherKeys.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildSectionHeader('Autres'),
            buildGrid(otherKeys),
          ],
        ],
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const EskoliaAmbientBackground(),
          EskoliaShellBody(
            showBack: false,
            child: ListView(
              padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 120),
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24, top: 8),
                    child: Text(
                      '📁 Docs métier',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                content,
                const SizedBox(height: 40),
                Text(
                  'Repères pour techniciens : conformité, protection des données, cybersécurité et gestion des services IT.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: EskoliaTokens.textSecondary.withValues(alpha: 0.5),
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
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Row(
        children: [
          const SizedBox(width: 4),
          Text(
            title.toUpperCase(),
            style: GoogleFonts.outfit(
              color: Colors.white60,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Divider(
              color: Colors.white12,
              thickness: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDraggableCard(String key, Widget child, double width) {
    final isWebOrDesktop = kIsWeb || 
        defaultTargetPlatform == TargetPlatform.macOS || 
        defaultTargetPlatform == TargetPlatform.windows || 
        defaultTargetPlatform == TargetPlatform.linux;

    final feedbackWidget = Material(
      color: Colors.transparent,
      child: Transform.rotate(
        angle: 0.015,
        child: Transform.scale(
          scale: 1.02,
          child: Opacity(
            opacity: 0.85,
            child: Container(
              width: width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: EskoliaTokens.cyan.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: child,
            ),
          ),
        ),
      ),
    );

    return DragTarget<String>(
      key: _getOrCreateKey(key),
      onWillAcceptWithDetails: (details) {
        final dragKey = details.data;
        if (dragKey != key) {
          if (_hoveredDragKey != key) {
            _hoveredDragKey = key;
            _dragDebounceTimer?.cancel();
            _dragDebounceTimer = Timer(const Duration(milliseconds: 60), () {
              if (mounted && _hoveredDragKey == key) {
                final pinned = ref.read(docsPinnedCardsProvider);
                final isDragPinned = pinned.contains(dragKey);
                final isTargetPinned = pinned.contains(key);

                if (isDragPinned != isTargetPinned) {
                  ref.read(docsPinnedCardsProvider.notifier).togglePin(dragKey);
                }

                final order = ref.read(docsCardsOrderProvider);
                final oldIdx = order.indexOf(dragKey);
                final newIdx = order.indexOf(key);
                if (oldIdx != -1 && newIdx != -1) {
                  ref.read(docsCardsOrderProvider.notifier).reorder(oldIdx, newIdx);
                }
              }
            });
          }
        }
        return true;
      },
      onLeave: (data) {
        if (_hoveredDragKey == key) {
          _dragDebounceTimer?.cancel();
          _hoveredDragKey = null;
        }
      },
      builder: (context, candidateData, rejectedData) {
        final isHovered = candidateData.isNotEmpty;

        final cardWidget = SizedBox(
          width: width,
          child: child,
        );

        Widget mainChild;
        if (isWebOrDesktop) {
          mainChild = Draggable<String>(
            key: ValueKey('${key}_drag'),
            data: key,
            feedback: feedbackWidget,
            childWhenDragging: Opacity(
              opacity: 0.15,
              child: cardWidget,
            ),
            child: cardWidget,
          );
        } else {
          mainChild = LongPressDraggable<String>(
            key: ValueKey('${key}_drag'),
            data: key,
            feedback: feedbackWidget,
            childWhenDragging: Opacity(
              opacity: 0.15,
              child: cardWidget,
            ),
            child: cardWidget,
          );
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isHovered ? EskoliaTokens.cyan.withValues(alpha: 0.8) : Colors.transparent,
              width: 2.0,
            ),
            boxShadow: isHovered
                ? [
                    BoxShadow(
                      color: EskoliaTokens.cyan.withValues(alpha: 0.15),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: mainChild,
          ),
        );
      },
    );
  }

  Widget _buildCardContent(String key, BuildContext context) {
    if (key == 'feature:docs_mes_cours') {
      return _buildInteractiveCard(
        key: key,
        category: 'MÉMOS PERSO',
        title: 'Mes cours sauvegardés',
        defaultEmoji: '📚',
        accentColor: EskoliaTokens.violetSoft,
        body: const MesCoursCard(),
      );
    }
    if (key == 'feature:docs_mes_quiz') {
      return _buildInteractiveCard(
        key: key,
        category: 'QUIZ PERSO',
        title: 'Mes quiz sauvegardés',
        defaultEmoji: '🎮',
        accentColor: EskoliaTokens.cyan,
        body: const MesQuizCard(),
      );
    }
    if (key == 'feature:docs_rgpd') {
      return _buildInteractiveCard(
        key: key,
        category: 'CONFORMITÉ',
        title: 'RGPD (UE)',
        defaultEmoji: '⚖️',
        accentColor: EskoliaVisual.neonViolet,
        body: DocSectionCardBody(
          accent: EskoliaVisual.neonViolet,
          body: DocsScreen.rgpdBody,
          linkLabel: 'Fiche CNIL sur le règlement européen',
          onLink: () => openDocsUrl(context, DocsScreen.cnilRgpd),
          onQuiz: () => context.go('/quiz/quick'),
        ),
        onCardTap: () => showDocsMiniCourseDialog(
          context,
          title: 'Mini-formation — RGPD',
          assetPath: DocsScreen.assetMiniRgpd,
          officialUrl: DocsScreen.cnilRgpd,
          officialLinkLabel: 'Fiche CNIL sur le règlement européen',
        ),
      );
    }
    if (key == 'feature:docs_cnil') {
      return _buildInteractiveCard(
        key: key,
        category: 'CONFORMITÉ',
        title: 'CNIL',
        defaultEmoji: '🏢',
        accentColor: EskoliaVisual.neonCyan,
        body: DocSectionCardBody(
          accent: EskoliaVisual.neonCyan,
          body: DocsScreen.cnilBody,
          linkLabel: 'Site de la CNIL',
          onLink: () => openDocsUrl(context, DocsScreen.cnilHome),
          onQuiz: () => context.go('/quiz/quick'),
        ),
        onCardTap: () => showDocsMiniCourseDialog(
          context,
          title: 'Mini-formation — CNIL',
          assetPath: DocsScreen.assetMiniCnil,
          officialUrl: DocsScreen.cnilHome,
          officialLinkLabel: 'Site de la CNIL',
        ),
      );
    }
    if (key == 'feature:docs_anssi') {
      return _buildInteractiveCard(
        key: key,
        category: 'SÉCURITÉ',
        title: 'ANSSI & bonnes pratiques',
        defaultEmoji: '🛡️',
        accentColor: EskoliaVisual.neonGreen,
        body: DocSectionCardBody(
          accent: EskoliaVisual.neonGreen,
          body: DocsScreen.anssiBody,
          linkLabel: 'Site de l\'ANSSI',
          onLink: () => openDocsUrl(context, DocsScreen.anssiHome),
          onQuiz: () => context.go('/quiz/quick'),
        ),
        onCardTap: () => showDocsMiniCourseDialog(
          context,
          title: 'Mini-formation — ANSSI',
          assetPath: DocsScreen.assetMiniAnssi,
          officialUrl: DocsScreen.anssiHome,
          officialLinkLabel: 'Site de l\'ANSSI',
        ),
      );
    }
    if (key == 'feature:docs_itil') {
      return _buildInteractiveCard(
        key: key,
        category: 'SERVICES IT',
        title: 'ITIL 4 (Services IT)',
        defaultEmoji: '🎟️',
        accentColor: const Color(0xFF60A5FA),
        body: DocSectionCardBody(
          accent: const Color(0xFF60A5FA),
          body: DocsScreen.itilBody,
          linkLabel: 'Site officiel ITIL (Axelos)',
          onLink: () => openDocsUrl(context, DocsScreen.itilHome),
          onQuiz: () => context.go('/quiz/quick'),
        ),
        onCardTap: () => showDocsMiniCourseDialog(
          context,
          title: 'Mini-formation — ITIL 4',
          assetPath: DocsScreen.assetMiniItil,
          officialUrl: DocsScreen.itilHome,
          officialLinkLabel: 'Site officiel ITIL',
        ),
      );
    }
    if (key == 'feature:docs_osi') {
      return _buildInteractiveCard(
        key: key,
        category: 'INFRA & RÉSEAUX',
        title: 'Modèle OSI & réseaux',
        defaultEmoji: '🌐',
        accentColor: const Color(0xFF34D399),
        body: DocSectionCardBody(
          accent: const Color(0xFF34D399),
          body: DocsScreen.osiBody,
          linkLabel: null,
          onLink: null,
          onQuiz: () => context.go('/quiz/quick'),
        ),
        onCardTap: () => showDocsMiniCourseDialog(
          context,
          title: 'Mini-formation — Modèle OSI',
          assetPath: DocsScreen.assetMiniOsi,
          officialUrl: null,
          officialLinkLabel: null,
        ),
      );
    }
    if (key == 'feature:docs_technician') {
      return _buildInteractiveCard(
        key: key,
        category: 'BONNES PRATIQUES',
        title: 'Technicien - Bonnes pratiques',
        defaultEmoji: '💡',
        accentColor: const Color(0xFFFFB74D),
        body: DocSectionCardBody(
          accent: const Color(0xFFFFB74D),
          body: DocsScreen.technicianBody,
          linkLabel: null,
          onLink: null,
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildInteractiveCard({
    required String key,
    required String category,
    required String title,
    required String defaultEmoji,
    required Color accentColor,
    required Widget body,
    VoidCallback? onCardTap,
  }) {
    final settingsMap = ref.watch(homeCardSettingsProvider);
    final settings = settingsMap[key];
    final displayTitle = settings?.title.isNotEmpty == true ? settings!.title : title;
    final isCollapsed = settings?.isCollapsed ?? false;
    
    final isPinned = ref.watch(docsPinnedCardsProvider).contains(key);
    final isAddedToHome = ref.watch(homeCardsOrderProvider).contains(key);
    final displayAccentColor = settings != null
        ? Color(settings.colorHex)
        : (isPinned ? EskoliaTokens.cyan : accentColor);

    Widget cardWidget = EskoliaCardContent(
      accentBorderColor: displayAccentColor,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              EskoliaCardSectionBadge(
                sectionName: 'DOCS',
                color: displayAccentColor,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => ref.read(homeCardSettingsProvider.notifier).toggleCollapse(key),
                        child: Text(
                          displayTitle,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    if (key == 'feature:docs_mes_cours' || key == 'feature:docs_mes_quiz') ...[
                      const SizedBox(width: 6),
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(4),
                        tooltip: 'Comment organiser',
                        onPressed: () => _showOrganizerTutoDialog(context, key),
                        icon: Icon(
                          Icons.info_outline_rounded,
                          color: displayAccentColor.withValues(alpha: 0.8),
                          size: 16,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(4),
                tooltip: isCollapsed ? 'Afficher' : 'Masquer',
                onPressed: () => ref.read(homeCardSettingsProvider.notifier).toggleCollapse(key),
                icon: Icon(
                  isCollapsed ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                  color: isCollapsed ? Colors.white70 : displayAccentColor,
                  size: 18,
                ),
              ),
              IconButton(
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(4),
                tooltip: 'Personnaliser',
                onPressed: () => showHomeCardSettingsDialog(context, ref, key),
                icon: const Icon(
                  Icons.edit_note_rounded,
                  color: Colors.white70,
                  size: 20,
                ),
              ),
              IconButton(
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(4),
                tooltip: isPinned ? 'Désépingler' : 'Épingler localement',
                onPressed: () => ref.read(docsPinnedCardsProvider.notifier).togglePin(key),
                icon: Icon(
                  isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                  color: isPinned ? displayAccentColor : Colors.white38,
                  size: 16,
                ),
              ),
              IconButton(
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(4),
                tooltip: isAddedToHome ? 'Retirer de l\'accueil' : 'Ajouter à l\'accueil',
                onPressed: () {
                  if (isAddedToHome) {
                    ref.read(homeCardsOrderProvider.notifier).removeCard(key);
                  } else {
                    ref.read(homeCardsOrderProvider.notifier).addCard(key);
                  }
                },
                icon: Icon(
                  isAddedToHome ? Icons.add_circle_rounded : Icons.add_circle_outline_rounded,
                  color: isAddedToHome ? EskoliaTokens.cyan : Colors.white38,
                  size: 16,
                ),
              ),
            ],
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 14),
              child: body,
            ),
            crossFadeState: !isCollapsed ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );

    if (onCardTap != null) {
      cardWidget = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onCardTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: displayAccentColor.withValues(alpha: 0.12),
          highlightColor: displayAccentColor.withValues(alpha: 0.06),
          child: cardWidget,
        ),
      );
    }

    return cardWidget;
  }

  void _showOrganizerTutoDialog(BuildContext context, String key) {
    final isCours = key == 'feature:docs_mes_cours';
    final title = isCours
        ? 'Organiser tes cours sauvegardés'
        : 'Organiser tes quiz et flashcards';

    final settingsMap = ref.read(homeCardSettingsProvider);
    final settings = settingsMap[key];
    final displayAccentColor = settings != null
        ? Color(settings.colorHex)
        : (isCours ? EskoliaTokens.violetSoft : EskoliaTokens.cyan);

    showDialog<void>(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            decoration: BoxDecoration(
              color: EskoliaTokens.surface1,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Row(
                    children: [
                      Icon(
                        isCours ? Icons.menu_book_rounded : Icons.sports_esports_rounded,
                        color: displayAccentColor,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        icon: const Icon(Icons.close_rounded, color: Colors.white38, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                Divider(color: Colors.white.withValues(alpha: 0.08), height: 1),
                // Body
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTutoStep(
                          number: '1',
                          title: 'Sélectionne un dossier sur ton PC',
                          subtitle: 'Rends-toi dans l\'onglet Réglages ⚙️ puis sous la section « Mes fichiers » pour connecter un dossier de ton choix (ex: Documents/Eskolia).',
                        ),
                        const SizedBox(height: 16),
                        _buildTutoStep(
                          number: '2',
                          title: 'Classe tes fichiers librement',
                          subtitle: isCours
                              ? 'Tous les cours que tu sauvegarderas s\'enregistreront dans le sous-dossier « Cours ». Crée des dossiers par matière (Maths, Réseau, etc.) directement depuis ton ordinateur pour les trier !'
                              : 'Les quiz se placent dans « Quiz » et les flashcards dans « Flashcards ». Tu peux créer des sous-dossiers par matière sur ton PC pour organiser ta liste automatiquement.',
                        ),
                        const SizedBox(height: 16),
                        _buildTutoStep(
                          number: '3',
                          title: 'Profite de la sauvegarde en ligne',
                          subtitle: 'Si tu n\'as pas connecté de dossier sur ton PC, pas d\'inquiétude ! Tous tes contenus restent sauvegardés en mémoire dans l\'application.',
                        ),
                        if (isCours) ...[
                          const SizedBox(height: 18),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: displayAccentColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: displayAccentColor.withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              children: [
                                const Text('✨', style: TextStyle(fontSize: 16)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Un grand merci à Angélique pour la rédaction soignée des cours !',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.white.withValues(alpha: 0.9),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                Divider(color: Colors.white.withValues(alpha: 0.08), height: 1),
                // Action
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: displayAccentColor,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      minimumSize: const Size(0, 40),
                    ),
                    child: const Text('Compris !', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTutoStep({
    required String number,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.white60, fontSize: 12, height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class MesCoursCard extends StatefulWidget {
  const MesCoursCard({super.key});

  @override
  State<MesCoursCard> createState() => _MesCoursCardState();
}

class _MesCoursCardState extends State<MesCoursCard> {
  Future<void> _pick() async {
    final fs = EskoliaFolderService.instance;
    final files = await fs.listFiles(EskoliaFolder.cours);
    if (!mounted) return;
    if (files.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucun cours dans Eskolia/Cours/. Genere des cours depuis le Notebook.')),
      );
      return;
    }
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: EskoliaTokens.surface2,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _DocFilePicker(
        files: files,
        title: 'Choisir un cours',
        icon: Icons.description_rounded,
        iconColor: EskoliaTokens.violetSoft,
      ),
    );
    if (picked == null || !mounted) return;
    final content = await fs.readFile(EskoliaFolder.cours, picked);
    if (content == null) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Impossible de lire ce cours.')));
      return;
    }
    if (!mounted) return;
    final title = picked.replaceAll('cours_', '').replaceAll('.md', '').replaceAll('_', ' ');
    _openCours(title, content);
  }

  void _openCours(String title, String content) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: EskoliaTokens.surface2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 12, 0),
        contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        title: Row(
          children: [
            Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700))),
            IconButton(icon: const Icon(Icons.close, color: Colors.white54, size: 20), onPressed: () => Navigator.of(ctx).pop()),
          ],
        ),
        content: SizedBox(
          width: 600,
          child: SingleChildScrollView(
            child: MarkdownBody(
              data: content,
              styleSheet: MarkdownStyleSheet(
                h1: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                h2: const TextStyle(color: EskoliaTokens.cyan, fontSize: 15, fontWeight: FontWeight.w600),
                h3: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
                p: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
                listBullet: const TextStyle(color: EskoliaTokens.textSecondary),
                strong: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                code: const TextStyle(color: EskoliaVisual.neonGreen, fontFamily: 'monospace', fontSize: 12, backgroundColor: EskoliaTokens.bgBase),
                blockquote: const TextStyle(color: Color(0xFFFFC107), fontStyle: FontStyle.italic),
              ),
            ),
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Fermer', style: TextStyle(color: EskoliaTokens.textSecondary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Lis les cours .md que tu as generés depuis le Notebook et sauvegardes dans Eskolia/Cours/.',
          style: TextStyle(color: _slate.withValues(alpha: 0.85), fontSize: 12, height: 1.4),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _pick,
          style: OutlinedButton.styleFrom(
            foregroundColor: EskoliaTokens.violetSoft,
            side: BorderSide(color: EskoliaTokens.violetSoft.withValues(alpha: 0.5)),
            padding: const EdgeInsets.symmetric(vertical: 10),
          ),
          icon: const Icon(Icons.folder_open_rounded, size: 16),
          label: const Text('Ouvrir un cours'),
        ),
      ],
    );
  }
}

class _DocFilePicker extends StatelessWidget {
  const _DocFilePicker({
    required this.files,
    required this.title,
    required this.icon,
    required this.iconColor,
  });

  final List<String> files;
  final String title;
  final IconData icon;
  final Color iconColor;

  String _label(String f) => f
      .replaceAll('cours_', '')
      .replaceAll('quiz_', '')
      .replaceAll('flashcards_', '')
      .replaceAll('.md', '')
      .replaceAll('.json', '')
      .replaceAll('_', ' ');

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 12),
        Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Flexible(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: files.length,
            itemBuilder: (_, i) => ListTile(
              leading: Icon(icon, color: iconColor),
              title: Text(_label(files[i]), style: const TextStyle(color: Colors.white, fontSize: 14)),
              subtitle: Text(files[i], style: TextStyle(color: _slate.withValues(alpha: 0.6), fontSize: 11)),
              onTap: () => Navigator.of(context).pop(files[i]),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class MesQuizCard extends StatefulWidget {
  const MesQuizCard({super.key});

  @override
  State<MesQuizCard> createState() => _MesQuizCardState();
}

class _MesQuizCardState extends State<MesQuizCard> {
  Future<void> _pickQuiz() async {
    final fs = EskoliaFolderService.instance;
    final files = await fs.listFiles(EskoliaFolder.quiz);
    if (!mounted) return;
    if (files.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucun quiz dans Eskolia/Quiz/. Génère des quiz depuis le Notebook.')),
      );
      return;
    }
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: EskoliaTokens.surface2,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _DocFilePicker(
        files: files,
        title: 'Choisir un quiz',
        icon: Icons.quiz_rounded,
        iconColor: EskoliaTokens.cyan,
      ),
    );
    if (picked == null || !mounted) return;
    final content = await fs.readFile(EskoliaFolder.quiz, picked);
    if (content == null) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Impossible de lire ce quiz.')));
      return;
    }
    try {
      final subject = picked.replaceAll('quiz_', '').replaceAll('.json', '').replaceAll('_', ' ');
      final session = await QuizRepository().buildFromNotebookQuizJson(content, subject);
      if (mounted) context.push('/quiz/run', extra: session);
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erreur lors du décodage du quiz.')));
    }
  }

  Future<void> _pickFlashcards() async {
    final fs = EskoliaFolderService.instance;
    final files = await fs.listFiles(EskoliaFolder.flashcards);
    if (!mounted) return;
    if (files.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucune flashcard dans Eskolia/Flashcards/. Génère des flashcards depuis le Notebook.')),
      );
      return;
    }
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: EskoliaTokens.surface2,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _DocFilePicker(
        files: files,
        title: 'Choisir des flashcards',
        icon: Icons.style_rounded,
        iconColor: Colors.amber,
      ),
    );
    if (picked == null || !mounted) return;
    final content = await fs.readFile(EskoliaFolder.flashcards, picked);
    if (content == null) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Impossible de lire ces flashcards.')));
      return;
    }
    try {
      final data = jsonDecode(content) as Map<String, dynamic>;
      final questions = data['questions'] as List<dynamic>? ?? [];
      final cards = <DeckFlashcard>[];
      for (var i = 0; i < questions.length; i++) {
        final q = questions[i];
        cards.add(DeckFlashcard(
          id: 'fc_$i',
          front: q['question'] ?? '',
          back: q['answer'] ?? '',
          mastery: 0,
          nextDue: DateTime.now(),
        ));
      }
      if (mounted) {
        context.push('/flashcards/session', extra: FlashcardSessionRouteArgs(cards: cards, ephemeral: true));
      }
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erreur lors du décodage des flashcards.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Joue aux quiz et flashcards que tu as générés depuis le Notebook et sauvegardés sur ton PC.',
          style: TextStyle(color: _slate.withValues(alpha: 0.85), fontSize: 12, height: 1.4),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickQuiz,
                style: OutlinedButton.styleFrom(
                  foregroundColor: EskoliaTokens.cyan,
                  side: BorderSide(color: EskoliaTokens.cyan.withValues(alpha: 0.5)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                icon: const Icon(Icons.quiz_rounded, size: 16),
                label: const Text('Lancer un quiz'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickFlashcards,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.amber,
                  side: BorderSide(color: Colors.amber.withValues(alpha: 0.5)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                icon: const Icon(Icons.style_rounded, size: 16),
                label: const Text('Ouvrir Flashcards'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class DocSectionCardBody extends StatelessWidget {
  const DocSectionCardBody({
    super.key,
    required this.accent,
    required this.body,
    required this.linkLabel,
    required this.onLink,
    this.onCardTap,
    this.onQuiz,
  });

  final Color accent;
  final String body;
  final String? linkLabel;
  final VoidCallback? onLink;
  final VoidCallback? onCardTap;
  final VoidCallback? onQuiz;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (onCardTap != null) ...[
          InkWell(
            onTap: onCardTap,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Icon(
                    Icons.school_outlined,
                    size: 16,
                    color: accent.withValues(alpha: 0.9),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Mini-formation disponible (cliquer pour ouvrir)',
                    style: TextStyle(
                      color: accent.withValues(alpha: 0.85),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
        Text(
          body,
          style: const TextStyle(
            color: _slate,
            fontSize: 12.5,
            height: 1.45,
          ),
        ),
        if (linkLabel != null && onLink != null) ...[
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: onLink,
              icon: Icon(Icons.open_in_new_rounded, size: 14, color: accent),
              label: Text(
                linkLabel!,
                style: TextStyle(
                  color: accent,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
        ],
        if (onQuiz != null) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: onQuiz,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: accent.withValues(alpha: 0.15),
                  border: Border.all(color: accent.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.quiz_rounded, size: 12, color: accent),
                    const SizedBox(width: 6),
                    Text(
                      'Quiz rapide',
                      style: TextStyle(
                        color: accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
