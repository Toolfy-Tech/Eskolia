import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/eskolia_tokens.dart';
import '../../../core/utils/feature_info_resolver.dart';
import '../../../core/theme/eskolia_layout.dart';
import '../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../shared/widgets/eskolia_shell_body.dart';
import '../../../shared/widgets/eskolia_card.dart';
import '../../../shared/widgets/eskolia_column_switcher.dart';
import '../../../shared/widgets/eskolia_page_header_toolbar.dart';
import '../../../shared/widgets/eskolia_section_card.dart';
import '../../../core/widgets/bottom_nav.dart';
import '../../home/presentation/providers/home_providers.dart';
import '../../home/presentation/widgets/home_card_settings_dialog.dart';
import 'providers/solo_providers.dart';
import 'widgets/solo_quiz_card_body.dart';
import 'widgets/solo_lacunes_card_body.dart';
import 'widgets/solo_pool_card_body.dart';
import 'widgets/solo_quiz_ai_card_body.dart';
import 'widgets/solo_flashcards_card_body.dart';
import 'widgets/solo_lexique_card_body.dart';

class SoloScreen extends ConsumerStatefulWidget {
  const SoloScreen({super.key});

  @override
  ConsumerState<SoloScreen> createState() => _SoloScreenState();
}

class _SoloScreenState extends ConsumerState<SoloScreen> {
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
    final isDesktopOrTablet = width >= 700;
    final sidebarWidth = isDesktopOrTablet ? (ref.watch(sidebarCollapsedProvider) ? 72 : 250) : 0;
    final availableWidth = (width - sidebarWidth - (hPad * 2)).clamp(280.0, double.infinity);

    final colPref = ref.watch(columnPreferenceProvider('solo'));
    final colRes = ColumnResolution.compute(
      preference: colPref,
      availableWidth: availableWidth,
      maxAutoColumns: 4,
    );
    final numColumns = colRes.columns;
    final cardWidth = colRes.cardWidth;

    final rawOrder = ref.watch(soloCardsOrderProvider);
    final pinned = ref.watch(soloPinnedCardsProvider);

    final aiState = ref.watch(aiConnectionStateProvider);
    final isAiActive = aiState.value?.isConnected ?? false;

    // Filtrer les cartes
    final order = rawOrder.where((key) {
      if (key == 'feature:solo_true_false' || key == 'feature:tp' || key == 'tp') {
        return false;
      }
      return true;
    }).toList();

    const availableSoloCards = [
      EskoliaCardOption(key: 'feature:solo_quiz', title: 'Générateur de Quiz', emoji: '🎮'),
      EskoliaCardOption(key: 'feature:solo_quiz_ai', title: 'Génération avec IA', emoji: '🧠'),
      EskoliaCardOption(key: 'feature:solo_lacunes', title: 'Mes fautes', emoji: '❌'),
      EskoliaCardOption(key: 'feature:solo_pool', title: 'À revoir', emoji: '📌'),
      EskoliaCardOption(key: 'feature:flashcards', title: 'Flashcards', emoji: '📚'),
      EskoliaCardOption(key: 'feature:lexique', title: 'Lexique & Glossaire', emoji: '📖'),
    ];

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
      final settingsMap = ref.watch(homeCardSettingsProvider);
      final cards = keys.map((key) {
        return _buildDraggableCard(key, _buildCardContent(key, context), cardWidth);
      }).toList();

      final columns = distributeMasonryColumns<int>(
        items: List.generate(keys.length, (i) => i),
        numColumns: numColumns,
        estimateHeight: (index) {
          final key = keys[index];
          final isCollapsed = settingsMap[key]?.isCollapsed ?? false;
          if (isCollapsed) return 65.0;
          if (key == 'feature:solo_quiz') return 340.0;
          if (key == 'feature:solo_lacunes') return 380.0;
          return 300.0;
        },
      );

      final widgetColumns = columns.map((colIndices) => colIndices.map((i) => cards[i]).toList()).toList();
      return buildMasonryColumnsRow(columns: widgetColumns);
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
            safeAreaTop: true,
            child: ListView(
              padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 120),
              children: [
                EskoliaPageHeaderToolbar(
                  title: 'Entraînement Solo',
                  screenKey: 'solo',
                  onCollapseAll: () => ref.read(homeCardSettingsProvider.notifier).collapseAll(order),
                  onExpandAll: () => ref.read(homeCardSettingsProvider.notifier).expandAll(order),
                  availableCards: availableSoloCards,
                  maxColumns: 4,
                ),
                const SizedBox(height: 12),
                content,
                const SizedBox(height: 40),
                Text(
                  'Mode Active Recall activé : toutes les réponses sont à saisir librement pour un ancrage mémoriel maximal.',
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
                final pinned = ref.read(soloPinnedCardsProvider);
                final isDragPinned = pinned.contains(dragKey);
                final isTargetPinned = pinned.contains(key);

                if (isDragPinned != isTargetPinned) {
                  ref.read(soloPinnedCardsProvider.notifier).togglePin(dragKey);
                }

                final order = ref.read(soloCardsOrderProvider);
                final oldIdx = order.indexOf(dragKey);
                final newIdx = order.indexOf(key);
                if (oldIdx != -1 && newIdx != -1) {
                  ref.read(soloCardsOrderProvider.notifier).reorder(oldIdx, newIdx);
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
    if (key == 'feature:solo_quiz') {
      return _buildInteractiveCard(
        key: key,
        category: 'IA & SUR MESURE',
        title: 'Générateur de Quiz',
        defaultEmoji: '🎮',
        accentColor: EskoliaTokens.cyan,
        body: const SoloQuizCardBody(isExpandedOverride: true),
      );
    }
    if (key == 'feature:solo_quiz_ai') {
      return _buildInteractiveCard(
        key: key,
        category: 'IA & SUR MESURE',
        title: 'Génération avec IA',
        defaultEmoji: '🧠',
        accentColor: EskoliaTokens.violet,
        body: const SoloQuizAiCardBody(isExpandedOverride: true),
      );
    }
    if (key == 'feature:solo_lacunes') {
      return _buildInteractiveCard(
        key: key,
        category: 'RÉVISION CIBLÉE',
        title: 'Mes fautes',
        defaultEmoji: '❌',
        accentColor: EskoliaTokens.error,
        body: const SoloLacunesCardBody(isExpandedOverride: true),
      );
    }
    if (key == 'feature:solo_pool') {
      return _buildInteractiveCard(
        key: key,
        category: 'RÉVISION CIBLÉE',
        title: 'À revoir',
        defaultEmoji: '📌',
        accentColor: EskoliaTokens.success,
        body: const SoloPoolCardBody(isExpandedOverride: true),
      );
    }
    if (key == 'feature:tp' || key == 'tp') {
      return _buildInteractiveCard(
        key: 'feature:tp',
        category: 'OFFICIEL',
        title: 'Travaux Pratiques (TP)',
        defaultEmoji: '🛠️',
        accentColor: Colors.blueAccent,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Mise en situation réelle sur Windows Server (Active Directory).',
              style: TextStyle(color: EskoliaTokens.textSecondary, fontSize: 11, height: 1.3),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.push('/tp'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              child: const Text('Entrer dans le TP Hub', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }
    if (key == 'feature:flashcards' || key == 'flashcards') {
      return _buildInteractiveCard(
        key: 'feature:flashcards',
        category: 'ENTRAINEMENT LIBRE',
        title: 'Flashcards',
        defaultEmoji: '📚',
        accentColor: EskoliaTokens.success,
        body: const SoloFlashcardsCardBody(isExpandedOverride: true),
      );
    }
    if (key == 'feature:lexique' || key == 'lexique') {
      return _buildInteractiveCard(
        key: 'feature:lexique',
        category: 'ENTRAINEMENT LIBRE',
        title: 'Lexique TIP',
        defaultEmoji: '📖',
        accentColor: EskoliaTokens.orange,
        body: const SoloLexiqueCardBody(isExpandedOverride: true),
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
  }) {
    final isPinned = ref.watch(soloPinnedCardsProvider).contains(key);
    final isAddedToHome = ref.watch(homeCardsOrderProvider).contains(key);

    return EskoliaSectionCard(
      cardKey: key,
      badge: 'SOLO',
      title: title,
      accentColor: accentColor,
      isPinned: isPinned,
      onTogglePin: () => ref.read(soloPinnedCardsProvider.notifier).togglePin(key),
      isAddedToHome: isAddedToHome,
      onToggleHome: () {
        if (isAddedToHome) {
          ref.read(homeCardsOrderProvider.notifier).removeCard(key);
        } else {
          ref.read(homeCardsOrderProvider.notifier).addCard(key);
        }
      },
      onInfoTap: () => _showInfoDialog(context, key),
      body: body,
    );
  }

  void _showInfoDialog(BuildContext context, String key) {
    final info = FeatureInfoResolver.getInfo(key);
    if (info == null) return;

    showDialog<void>(
      context: context,
      builder: (ctx) {
        final isErrorAccent = key == 'feature:solo_lacunes' || key == 'feature:tp';
        return AlertDialog(
          backgroundColor: EskoliaTokens.surface1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              if (info.emoji.isNotEmpty) ...[
                Text(info.emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  info.title,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          content: FeatureInfoResolver.buildRichDescription(
            info.description,
            const TextStyle(color: Colors.white70, fontSize: 13.5, height: 1.45),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Compris',
                style: TextStyle(
                  color: isErrorAccent ? EskoliaTokens.error : EskoliaTokens.cyan,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
