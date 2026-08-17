import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../data/repositories/user_repository.dart';
import '../../../core/theme/eskolia_layout.dart';
import '../../../core/theme/eskolia_visual.dart';
import '../../../core/theme/tip_section_theme.dart';
import '../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../shared/widgets/eskolia_shell_body.dart';
import '../../../shared/widgets/eskolia_card.dart';
import '../../../core/utils/eskolia_snackbar.dart';
import '../../economy/data/achievement_triggers.dart';
import '../../economy/data/daily_quest_reward_service.dart';
import '../../home/data/daily_quests_repository.dart';
import '../../podcasts/data/podcast_model.dart';
import '../../podcasts/presentation/podcast_player_card.dart';
import '../data/parcours_repository.dart';
import '../../../core/constants/eskolia_tokens.dart';
import '../../../core/utils/feature_info_resolver.dart';
import '../../../core/widgets/bottom_nav.dart';
import '../../home/presentation/providers/home_providers.dart';
import '../../home/presentation/widgets/home_card_settings_dialog.dart';
import 'providers/parcours_providers.dart';
import 'widgets/examen_blanc_card_body.dart';
import 'widgets/mega_lexique_card_body.dart';
import 'widgets/mega_mediatheque_card_body.dart';

const Color _violetBrand = EskoliaTokens.violetSoft;
const Color _slate = EskoliaTokens.textSecondary;
const Color _slateLight = EskoliaTokens.textSecondary;
const Color _surface = EskoliaTokens.surface2;

class ParcoursScreen extends ConsumerStatefulWidget {
  const ParcoursScreen({super.key, this.expandFormationId});

  /// Si présent (`tip`, `optimus`, …), la carte du parcours correspondant s’ouvre dépliée.
  final String? expandFormationId;

  @override
  ConsumerState<ParcoursScreen> createState() => _ParcoursScreenState();
}

class _ParcoursScreenState extends ConsumerState<ParcoursScreen>
    with SingleTickerProviderStateMixin {
  final ParcoursRepository _repo = ParcoursRepository();
  late AnimationController _pulseController;
  int _streamRetry = 0;

  Timer? _dragDebounceTimer;
  String? _hoveredDragKey;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await DailyQuestRewardService().onParcoursVisited(uid);
        final u = await UserRepository().getUserById(uid);
        if (u != null) {
          await AchievementTriggers(
            onUnlocked: (emoji, title) {
              if (!mounted) return;
              showAchievementSnackBar(context, emoji, title);
            },
          ).syncFromUserSnapshot(u);
        }
      } else {
        await DailyQuestsRepository().markParcoursProgressDone();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _dragDebounceTimer?.cancel();
    super.dispose();
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
        angle: 0.035,
        child: Transform.scale(
          scale: 1.04,
          child: Opacity(
            opacity: 0.9,
            child: Container(
              width: width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: EskoliaTokens.cyan.withValues(alpha: 0.45),
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
      key: ValueKey(key),
      onWillAcceptWithDetails: (details) {
        final dragKey = details.data;
        if (dragKey != key) {
          if (_hoveredDragKey != key) {
            _hoveredDragKey = key;
            _dragDebounceTimer?.cancel();
            _dragDebounceTimer = Timer(const Duration(milliseconds: 150), () {
              if (mounted && _hoveredDragKey == key) {
                final pinned = ref.read(parcoursPinnedCardsProvider);
                final isDragPinned = pinned.contains(dragKey);
                final isTargetPinned = pinned.contains(key);

                if (isDragPinned != isTargetPinned) {
                  ref.read(parcoursPinnedCardsProvider.notifier).togglePin(dragKey);
                }

                final order = ref.read(parcoursCardsOrderProvider);
                final oldIdx = order.indexOf(dragKey);
                final newIdx = order.indexOf(key);
                if (oldIdx != -1 && newIdx != -1) {
                  ref.read(parcoursCardsOrderProvider.notifier).reorder(oldIdx, newIdx);
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
            key: ValueKey(key),
            data: key,
            feedback: feedbackWidget,
            childWhenDragging: Opacity(
              opacity: 0.2,
              child: cardWidget,
            ),
            child: cardWidget,
          );
        } else {
          mainChild = LongPressDraggable<String>(
            key: ValueKey(key),
            data: key,
            feedback: feedbackWidget,
            childWhenDragging: Opacity(
              opacity: 0.2,
              child: cardWidget,
            ),
            child: cardWidget,
          );
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
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

  Widget _buildInteractiveCard({
    required String key,
    required String title,
    required String defaultEmoji,
    required Color accentColor,
    required Widget body,
    bool disableCollapseAnimation = false,
  }) {
    final settingsMap = ref.watch(homeCardSettingsProvider);
    final settings = settingsMap[key];
    final displayTitle = settings?.title.isNotEmpty == true ? settings!.title : title;
    final isCollapsed = settings?.isCollapsed ?? false;
    
    final isPinned = ref.watch(parcoursPinnedCardsProvider).contains(key.startsWith('feature:') ? key.substring(8) : key);
    final isAddedToHome = ref.watch(homeCardsOrderProvider).contains(key);
    final displayAccentColor = settings != null
        ? Color(settings.colorHex)
        : (isPinned ? EskoliaTokens.cyan : accentColor);

    return EskoliaCardContent(
      accentBorderColor: displayAccentColor,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              EskoliaCardSectionBadge(
                sectionName: 'PARCOURS',
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
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    if (FeatureInfoResolver.getInfo(key) != null) ...[
                      const SizedBox(width: 4),
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(4),
                        tooltip: 'Comment ça marche ?',
                        onPressed: () => _showInfoDialog(context, key),
                        icon: const Icon(
                          Icons.info_outline_rounded,
                          color: Colors.white60,
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
                onPressed: () => ref.read(parcoursPinnedCardsProvider.notifier).togglePin(key.startsWith('feature:') ? key.substring(8) : key),
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
          disableCollapseAnimation
              ? Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: body,
                )
              : AnimatedCrossFade(
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

  Widget _buildCardByKey(String key, FormationModel formation, double cardWidth) {
    final settingsMap = ref.watch(homeCardSettingsProvider);
    final settings = settingsMap['feature:$key'] ?? settingsMap[key];
    final displayTitle = settings?.title.isNotEmpty == true ? settings!.title : '';
    final isCollapsed = settings?.isCollapsed ?? false;

    if (key == 'formation') {
      return _buildDraggableCard(
        key,
        _buildInteractiveCard(
          key: 'feature:parcours',
          title: displayTitle.isNotEmpty ? displayTitle : formation.title,
          defaultEmoji: '🎓',
          accentColor: _violetBrand,
          body: _FormationCardBody(formation: formation, accentColor: _violetBrand),
        ),
        cardWidth,
      );
    } else if (key == 'podcasts') {
      return _buildDraggableCard(
        key,
        _buildInteractiveCard(
          key: 'feature:podcasts',
          title: displayTitle.isNotEmpty ? displayTitle : 'Podcast TIP',
          defaultEmoji: '🎙️',
          accentColor: EskoliaTokens.violet,
          disableCollapseAnimation: true,
          body: _PodcastsCardBody(isCollapsed: isCollapsed),
        ),
        cardWidth,
      );
    } else if (key == 'examen_blanc') {
      return _buildDraggableCard(
        key,
        _buildInteractiveCard(
          key: 'feature:examen_blanc',
          title: displayTitle.isNotEmpty ? displayTitle : 'Validation TIP',
          defaultEmoji: '🏆',
          accentColor: EskoliaTokens.amber,
          body: ExamenBlancCardBody(formation: formation),
        ),
        cardWidth,
      );
    } else if (key == 'lexique') {
      final accent = settings != null ? Color(settings.colorHex) : EskoliaTokens.orange;
      return _buildDraggableCard(
        key,
        _buildInteractiveCard(
          key: 'feature:lexique',
          title: displayTitle.isNotEmpty ? displayTitle : 'Lexique TIP',
          defaultEmoji: '📖',
          accentColor: accent,
          body: MegaLexiqueCardBody(accentColor: accent),
        ),
        cardWidth,
      );
    } else if (key == 'mediatheque') {
      final accent = settings != null ? Color(settings.colorHex) : EskoliaTokens.violetSoft;
      return _buildDraggableCard(
        key,
        _buildInteractiveCard(
          key: 'feature:mediatheque',
          title: displayTitle.isNotEmpty ? displayTitle : 'Média TIP',
          defaultEmoji: '📁',
          accentColor: accent,
          body: MegaMediathequeCardBody(accentColor: accent),
        ),
        cardWidth,
      );
    }
    return const SizedBox.shrink();
  }

  List<Widget> _addSpacing(List<Widget> list) {
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

  Widget _buildCardsGrid(BuildContext context, FormationModel formation, double cardWidth, int numColumns) {
    final rawOrder = ref.watch(parcoursCardsOrderProvider);
    final pinned = ref.watch(parcoursPinnedCardsProvider);

    Widget buildGrid(List<String> keys) {
      final cards = keys.map((key) => _buildCardByKey(key, formation, cardWidth)).toList();

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
            Expanded(child: Column(children: _addSpacing(col1))),
            const SizedBox(width: 16),
            Expanded(child: Column(children: _addSpacing(col2))),
            const SizedBox(width: 16),
            Expanded(child: Column(children: _addSpacing(col3))),
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
            Expanded(child: Column(children: _addSpacing(col1))),
            const SizedBox(width: 16),
            Expanded(child: Column(children: _addSpacing(col2))),
          ],
        );
      } else {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _addSpacing(cards),
        );
      }
    }

    if (pinned.isEmpty) {
      return buildGrid(rawOrder);
    } else {
      final pinnedKeys = rawOrder.where((k) => pinned.contains(k)).toList();
      final otherKeys = rawOrder.where((k) => !pinned.contains(k)).toList();
      return Column(
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
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktopOrTablet = screenWidth >= 700;

    final sidebarWidth = isDesktopOrTablet ? (ref.watch(sidebarCollapsedProvider) ? 72 : 250) : 0;
    final availableWidth = (screenWidth - sidebarWidth - 48).clamp(280.0, double.infinity);

    int numColumns;
    double cardWidth;
    if (availableWidth >= 1050) {
      numColumns = 3;
      cardWidth = (availableWidth - 32) / 3;
    } else if (availableWidth >= 660) {
      numColumns = 2;
      cardWidth = (availableWidth - 16) / 2;
    } else {
      numColumns = 1;
      cardWidth = availableWidth;
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const EskoliaAmbientBackground(),
          EskoliaShellBody(
            safeAreaTop: true,
            child: uid.isEmpty
                ? const _EmptyState(
                    emoji: '📭',
                    message: 'Aucune formation disponible',
                  )
                : StreamBuilder<List<FormationModel>>(
                    key: ValueKey(_streamRetry),
                    stream: _repo.watchFormations(uid),
                    builder: (context, snap) {
                      if (snap.hasError) {
                        return _ErrorState(
                          message: snap.error.toString(),
                          onRetry: () => setState(() => _streamRetry++),
                        );
                      }
                      if (snap.connectionState == ConnectionState.waiting && !snap.hasData) {
                        return _SkeletonLoader(
                          pulse: _pulseController,
                        );
                      }
                      if (!snap.hasData) {
                        return _SkeletonLoader(
                          pulse: _pulseController,
                        );
                      }
                      final list = snap.data!;
                      if (list.isEmpty) {
                        return const _EmptyState(
                          emoji: '📭',
                          message: 'Aucune formation disponible',
                        );
                      }

                      final formation = list.first;

                      return ListView(
                        padding: const EdgeInsets.fromLTRB(
                          EskoliaLayout.screenPaddingH,
                          16,
                          EskoliaLayout.screenPaddingH,
                          120,
                        ),
                        children: [
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 24, top: 8),
                              child: Text(
                                'Mon Syllabus',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                          _buildCardsGrid(context, formation, cardWidth, numColumns),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _FormationCardBody extends StatefulWidget {
  const _FormationCardBody({required this.formation, required this.accentColor});
  final FormationModel formation;
  final Color accentColor;

  @override
  State<_FormationCardBody> createState() => _FormationCardBodyState();
}

class _FormationCardBodyState extends State<_FormationCardBody> {
  int _selectedSectionIndex = 0;

  @override
  Widget build(BuildContext context) {
    final f = widget.formation;
    final ratio = f.progress.clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          f.description,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: EskoliaTokens.textSecondary.withValues(alpha: 0.85),
            fontSize: 11.5,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progression générale'.toUpperCase(),
                    style: GoogleFonts.outfit(
                      color: Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                    ),
                  ),
                  Text(
                    '${f.completedModules} / ${f.totalModules} chapitres (${(ratio * 100).toInt()}%)',
                    style: GoogleFonts.outfit(
                      color: EskoliaTokens.cyan,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SizedBox(
                  height: 8,
                  child: Stack(
                    children: [
                      Container(color: Colors.white.withValues(alpha: 0.05)),
                      FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: ratio,
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [EskoliaTokens.violetSoft, EskoliaTokens.cyan],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (f.sections.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 12),
          _buildSyllabusCarousel(f),
        ],
      ],
    );
  }

  Widget _buildSyllabusCarousel(FormationModel f) {
    final section = f.sections[_selectedSectionIndex];
    final t = TipSectionTheme.colorsFor(section.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left_rounded, color: EskoliaTokens.cyan),
              onPressed: _selectedSectionIndex > 0
                  ? () => setState(() => _selectedSectionIndex--)
                  : null,
            ),
            Expanded(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: t.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: t.primary.withValues(alpha: 0.40)),
                    ),
                    child: Text(
                      section.id,
                      style: TextStyle(
                        color: t.primary,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    section.title,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right_rounded, color: EskoliaTokens.cyan),
              onPressed: _selectedSectionIndex < f.sections.length - 1
                  ? () => setState(() => _selectedSectionIndex++)
                  : null,
            ),
          ],
        ),
        const SizedBox(height: 12),
        _SectionPodcastWidget(sectionId: section.id, accentColor: t.primary),
        const SizedBox(height: 8),
        for (var i = 0; i < section.modules.length; i++)
          _ModuleTile(
            module: section.modules[i],
            sectionAccent: t.primary,
            chapterIndex: i + 1,
            isFirst: i == 0,
            isLast: i == section.modules.length - 1,
          ),
      ],
    );
  }
}

class _CompactPodcastTile extends ConsumerWidget {
  const _CompactPodcastTile({required this.podcast, required this.accentColor});
  final Podcast podcast;
  final Color accentColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(podcastPlayerProvider);
    final isThis = playerState.podcast?.url == podcast.url;
    final isPlaying = isThis && playerState.isPlaying;
    final isLoading = isThis && playerState.loading;

    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: accentColor.withValues(alpha: 0.15)),
          color: Colors.white.withValues(alpha: 0.01),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          child: Row(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isLoading
                      ? null
                      : () => ref.read(podcastPlayerProvider.notifier).play(podcast),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accentColor.withValues(alpha: 0.15),
                    ),
                    child: isLoading
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(
                              strokeWidth: 1.5,
                              color: accentColor,
                            ),
                          )
                        : Icon(
                            isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            color: accentColor,
                            size: 18,
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.3),
                    width: 0.6,
                  ),
                ),
                child: Text(
                  'PODCAST',
                  style: TextStyle(
                    color: accentColor.withValues(alpha: 0.85),
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  podcast.displayTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (isPlaying)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Icon(
                    Icons.volume_up_rounded,
                    color: accentColor,
                    size: 14,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionPodcastWidget extends StatefulWidget {
  const _SectionPodcastWidget({required this.sectionId, required this.accentColor});
  final String sectionId;
  final Color accentColor;

  @override
  State<_SectionPodcastWidget> createState() => _SectionPodcastWidgetState();
}

class _SectionPodcastWidgetState extends State<_SectionPodcastWidget> {
  Podcast? _podcast;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPodcast();
  }

  @override
  void didUpdateWidget(covariant _SectionPodcastWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.sectionId != oldWidget.sectionId) {
      _loadPodcast();
    }
  }

  Future<void> _loadPodcast() async {
    setState(() => _loading = true);
    final p = await PodcastCatalog.forSection(widget.sectionId);
    if (!mounted) return;
    setState(() {
      _podcast = p;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(
        height: 40,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: EskoliaTokens.cyan)),
      );
    }
    if (_podcast == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: _CompactPodcastTile(podcast: _podcast!, accentColor: widget.accentColor),
    );
  }
}

class _PodcastsCardBody extends ConsumerWidget {
  const _PodcastsCardBody({required this.isCollapsed});
  final bool isCollapsed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(podcastPlayerProvider);
    final podcastsSnap = ref.watch(allPodcastsProvider);

    return podcastsSnap.when(
      data: (podcasts) {
        if (podcasts.isEmpty) {
          return const Center(
            child: Text(
              'Aucun podcast disponible',
              style: TextStyle(color: Colors.white60, fontSize: 12),
            ),
          );
        }

        final activePodcast = playerState.podcast ?? podcasts.first;
        final isPlaying = playerState.podcast?.url == activePodcast.url && playerState.isPlaying;
        final isLoading = playerState.podcast?.url == activePodcast.url && playerState.loading;

        final total = playerState.podcast?.url == activePodcast.url ? (playerState.duration ?? Duration.zero) : Duration.zero;
        final hasDuration = total.inMilliseconds > 0;
        final pos = playerState.podcast?.url == activePodcast.url
            ? playerState.position.inMilliseconds.clamp(0, hasDuration ? total.inMilliseconds : 0).toDouble()
            : 0.0;

        String fmt(Duration d) {
          final m = d.inMinutes;
          final s = d.inSeconds % 60;
          return '$m:${s < 10 ? '0$s' : '$s'}';
        }

        void playNextPrev(bool next) {
          final current = playerState.podcast ?? podcasts.first;
          int idx = podcasts.indexWhere((p) => p.url == current.url);
          if (idx == -1) idx = 0;
          if (next) {
            idx = (idx + 1) % podcasts.length;
          } else {
            idx = (idx - 1 + podcasts.length) % podcasts.length;
          }
          ref.read(podcastPlayerProvider.notifier).play(podcasts[idx]);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.02),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: isLoading
                          ? null
                          : () => ref.read(podcastPlayerProvider.notifier).play(activePodcast),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [EskoliaTokens.cyan, EskoliaTokens.violet],
                          ),
                        ),
                        child: isLoading
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Icon(
                                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 24,
                               ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activePodcast.displayTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (activePodcast.subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            activePodcast.subtitle!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: EskoliaTokens.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_previous_rounded, color: Colors.white70, size: 20),
                    onPressed: () => playNextPrev(false),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.skip_next_rounded, color: Colors.white70, size: 20),
                    onPressed: () => playNextPrev(true),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 2,
                activeTrackColor: EskoliaTokens.cyan,
                inactiveTrackColor: Colors.white12,
                thumbColor: EskoliaTokens.cyan,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
              ),
              child: Slider(
                value: pos,
                max: hasDuration ? total.inMilliseconds.toDouble() : 1.0,
                onChanged: hasDuration ? (v) {} : null,
                onChangeEnd: hasDuration
                    ? (v) => ref.read(podcastPlayerProvider.notifier).seek(Duration(milliseconds: v.round()))
                    : null,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    playerState.podcast?.url == activePodcast.url ? fmt(playerState.position) : '0:00',
                    style: const TextStyle(color: EskoliaTokens.textSecondary, fontSize: 10),
                  ),
                  Text(
                    hasDuration ? fmt(total) : '--:--',
                    style: const TextStyle(color: EskoliaTokens.textSecondary, fontSize: 10),
                  ),
                ],
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white10, height: 1),
                  const SizedBox(height: 12),
                  const Text(
                    'Tous les podcasts',
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 180),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: podcasts.length,
                      itemBuilder: (context, idx) {
                        final p = podcasts[idx];
                        final isCurrent = p.url == activePodcast.url;
                        return ListTile(
                          dense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                          leading: Icon(
                            isCurrent ? Icons.volume_up_rounded : Icons.audiotrack_rounded,
                            color: isCurrent ? EskoliaTokens.cyan : Colors.white38,
                            size: 16,
                          ),
                          title: Text(
                            p.displayTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isCurrent ? EskoliaTokens.cyan : Colors.white70,
                              fontSize: 12,
                              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          subtitle: p.subtitle != null
                              ? Text(
                                  p.subtitle!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 10),
                                )
                              : null,
                          onTap: () {
                            ref.read(podcastPlayerProvider.notifier).play(p);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
              crossFadeState: !isCollapsed ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 250),
            ),
          ],
        );
      },
      loading: () => const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: EskoliaTokens.cyan),
        ),
      ),
      error: (e, _) => Center(
        child: Text(
          'Erreur: $e',
          style: const TextStyle(color: Colors.red, fontSize: 11),
        ),
      ),
    );
  }
}

class _SectionTile extends StatefulWidget {
  const _SectionTile({required this.section});

  final SectionModel section;

  @override
  State<_SectionTile> createState() => _SectionTileState();
}

class _SectionTileState extends State<_SectionTile> {
  Podcast? _podcast;

  @override
  void initState() {
    super.initState();
    _loadPodcast();
  }

  Future<void> _loadPodcast() async {
    final p = await PodcastCatalog.forSection(widget.section.id);
    if (!mounted) return;
    setState(() => _podcast = p);
  }

  @override
  Widget build(BuildContext context) {
    final t = TipSectionTheme.colorsFor(widget.section.id);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: t.primary.withValues(alpha: 0.22)),
        color: t.primary.withValues(alpha: 0.06),
      ),
      padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: t.primary,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: EskoliaVisual.glow(t.glow, blur: 10, alpha: 0.4),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: t.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: t.primary.withValues(alpha: 0.40)),
                ),
                child: Text(
                  widget.section.id,
                  style: TextStyle(
                    color: t.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.section.title,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.98),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          if (_podcast != null) ...[
            const SizedBox(height: 10),
            PodcastPlayerCard(podcast: _podcast!),
          ],
          const SizedBox(height: 8),
          for (var i = 0; i < widget.section.modules.length; i++)
            _ModuleTile(
              module: widget.section.modules[i],
              sectionAccent: t.primary,
              chapterIndex: i + 1,
              isFirst: i == 0,
              isLast: i == widget.section.modules.length - 1,
            ),
        ],
      ),
    );
  }
}


class _ModuleTile extends StatelessWidget {
  const _ModuleTile({
    required this.module,
    required this.sectionAccent,
    required this.chapterIndex,
    required this.isFirst,
    required this.isLast,
  });

  final ModuleModel module;
  final Color sectionAccent;
  final int chapterIndex;
  final bool isFirst;
  final bool isLast;

  IconData _iconForType(String type) {
    switch (type) {
      case 'exam':
        return Icons.school_rounded;
      case 'quiz':
        return Icons.quiz_rounded;
      case 'flashcard':
        return Icons.style_rounded;
      case 'chapitre':
      case 'cours':
      default:
        return Icons.menu_book_rounded;
    }
  }

  void _onTap(BuildContext context) {
    if (module.isLocked) return;
    switch (module.type) {
      case 'exam':
        if (module.quizAssetPath != null) {
          context.push('/quiz/${module.id}');
        }
        break;
      case 'chapitre':
        if (module.lessonAssetPath != null) {
          context.push('/cours/${module.id}');
        } else if (module.quizAssetPath != null) {
          context.push('/quiz/${module.id}');
        }
        break;
      case 'quiz':
        context.push('/quiz/${module.id}');
        break;
      case 'cours':
        if (module.lessonAssetPath != null) {
          context.push('/cours/${module.id}');
        } else if (module.quizAssetPath != null) {
          context.push('/quiz/${module.id}');
        }
        break;
      case 'flashcard':
        context.push('/flashcards');
        break;
      default:
        if (module.lessonAssetPath != null) {
          context.push('/cours/${module.id}');
        } else if (module.quizAssetPath != null) {
          context.push('/quiz/${module.id}');
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final locked = module.isLocked;
    final completed = module.isCompleted;
    final typeIcon = _iconForType(module.type);
    final typeColor = sectionAccent;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: locked ? null : () => _onTap(context),
            splashColor: typeColor.withValues(alpha: 0.08),
            highlightColor: typeColor.withValues(alpha: 0.04),
            child: Opacity(
              opacity: locked ? 0.45 : 1.0,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Icon Container with glowing background
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: typeColor.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: typeColor.withValues(alpha: 0.20),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          typeIcon,
                          size: 20,
                          color: typeColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Title and Badge
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (module.type != 'exam') ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    color: typeColor.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: typeColor.withValues(alpha: 0.3),
                                      width: 0.6,
                                    ),
                                  ),
                                  child: Text(
                                    'CH.$chapterIndex',
                                    style: TextStyle(
                                      color: typeColor.withValues(alpha: 0.85),
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ),
                              ],
                              Expanded(
                                child: Text(
                                  module.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: completed
                                        ? _slateLight.withValues(alpha: 0.45)
                                        : Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (completed)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            color: EskoliaTokens.cyan.withValues(alpha: 0.8),
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Résolu',
                            style: TextStyle(
                              color: EskoliaTokens.cyan,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      )
                    else if (locked)
                      Icon(
                        Icons.lock_outline_rounded,
                        color: Colors.white.withValues(alpha: 0.25),
                        size: 14,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class _SkeletonLoader extends StatelessWidget {
  const _SkeletonLoader({required this.pulse});

  final Animation<double> pulse;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      children: List.generate(3, (i) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: AnimatedBuilder(
            animation: pulse,
            builder: (context, child) {
              final t = pulse.value;
              final c = Color.lerp(_surface, EskoliaTokens.surface3, t)!;
              return AnimatedContainer(
                duration: Duration.zero,
                height: 140,
                decoration: BoxDecoration(
                  color: c,
                  borderRadius: BorderRadius.circular(20),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '\u{26A0}\u{FE0F}',
                style: TextStyle(fontSize: 40),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _slateLight.withValues(alpha: 0.95),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: onRetry,
                style: FilledButton.styleFrom(
                  backgroundColor: _violetBrand,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.emoji,
    required this.message,
  });

  final String emoji;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(
              color: _slate.withValues(alpha: 0.95),
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
