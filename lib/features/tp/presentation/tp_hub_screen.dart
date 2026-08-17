import 'dart:async';
import 'dart:convert';
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
import '../../solo/data/practical_missions_firestore_repository.dart';
import '../../../core/services/asset_cache_service.dart';
import 'tp_scenario_screen.dart';
import '../../../core/widgets/bottom_nav.dart';
import '../../ai/data/ai_key_repository.dart';
import '../reseau/data/tp_binaire_data.dart';
import '../reseau/presentation/tp_binaire_hub_screen.dart';
import '../../home/presentation/widgets/home_card_settings_dialog.dart';
import '../../home/presentation/providers/home_providers.dart';
import '../osi/presentation/widgets/tp_osi_card_body.dart';
import 'providers/tp_providers.dart';

class TpHubScreen extends ConsumerStatefulWidget {
  const TpHubScreen({super.key});

  @override
  ConsumerState<TpHubScreen> createState() => _TpHubScreenState();
}

class _TpHubScreenState extends ConsumerState<TpHubScreen> {
  Timer? _dragDebounceTimer;
  String? _hoveredDragKey;

  @override
  void dispose() {
    _dragDebounceTimer?.cancel();
    super.dispose();
  }



  Widget _buildInteractiveCard({
    required String key,
    required String title,
    required String defaultEmoji,
    required Color accentColor,
    required Widget body,
    List<Widget>? headerActions,
  }) {
    final isPinned = ref.watch(tpPinnedCardsProvider).contains(key);
    final isAddedToHome = ref.watch(homeCardsOrderProvider).contains(key);

    return EskoliaSectionCard(
      cardKey: key,
      badge: 'TP',
      title: title,
      accentColor: accentColor,
      isPinned: isPinned,
      onTogglePin: () => ref.read(tpPinnedCardsProvider.notifier).togglePin(key),
      isAddedToHome: isAddedToHome,
      onToggleHome: () {
        if (isAddedToHome) {
          ref.read(homeCardsOrderProvider.notifier).removeCard(key);
        } else {
          ref.read(homeCardsOrderProvider.notifier).addCard(key);
        }
      },
      onInfoTap: () => _showInfoDialog(context, key),
      extraHeaderActions: headerActions ?? const [],
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
                final pinned = ref.read(tpPinnedCardsProvider);
                final isDragPinned = pinned.contains(dragKey);
                final isTargetPinned = pinned.contains(key);

                if (isDragPinned != isTargetPinned) {
                  ref.read(tpPinnedCardsProvider.notifier).togglePin(dragKey);
                }

                final order = ref.read(tpCardsOrderProvider);
                final oldIdx = order.indexOf(dragKey);
                final newIdx = order.indexOf(key);
                if (oldIdx != -1 && newIdx != -1) {
                  ref.read(tpCardsOrderProvider.notifier).reorder(oldIdx, newIdx);
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

  Widget _buildCardByKey(String key, double cardWidth) {
    if (key == 'feature:tp_reseau') {
      return _buildCardByKeyForReseau(key, cardWidth);
    } else if (key == 'feature:tp_osi') {
      return _buildDraggableCard(
        key,
        _buildInteractiveCard(
          key: key,
          title: 'Modèle OSI',
          defaultEmoji: '🌐',
          accentColor: EskoliaTokens.cyan,
          body: const TpOsiCardBody(),
        ),
        cardWidth,
      );
    } else if (key == 'feature:tp_ad') {
      return _buildDraggableCard(
        key,
        _buildInteractiveCard(
          key: key,
          title: 'Active Directory',
          defaultEmoji: '👥',
          accentColor: EskoliaTokens.info,
          body: const TpActiveDirectoryCardBody(),
        ),
        cardWidth,
      );
    } else if (key == 'feature:tp_powershell') {
      return _buildDraggableCard(
        key,
        _buildInteractiveCard(
          key: key,
          title: 'Scripting PowerShell',
          defaultEmoji: '💻',
          accentColor: EskoliaTokens.violet,
          body: const TpPowerShellCardBody(),
        ),
        cardWidth,
      );
    } else if (key == 'feature:tp_packet_tracer') {
      return _buildDraggableCard(
        key,
        _buildInteractiveCard(
          key: key,
          title: 'Packet Tracer',
          defaultEmoji: '⚡',
          accentColor: EskoliaTokens.cyan,
          body: const TpPacketTracerCardBody(),
        ),
        cardWidth,
      );
    } else if (key == 'feature:tp_itil') {
      return _buildDraggableCard(
        key,
        _buildInteractiveCard(
          key: key,
          title: 'Gestion de Tickets (ITIL)',
          defaultEmoji: '🎟️',
          accentColor: EskoliaTokens.violet,
          headerActions: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'BIENTÔT',
                style: TextStyle(color: EskoliaTokens.textSecondary, fontSize: 9, fontWeight: FontWeight.bold),
              ),
            ),
          ],
          body: const TpItilCardBody(),
        ),
        cardWidth,
      );
    } else if (key == 'feature:tp_glpi') {
      return _buildDraggableCard(
        key,
        _buildInteractiveCard(
          key: key,
          title: 'TP GLPI',
          defaultEmoji: '📦',
          accentColor: EskoliaTokens.textDisabled,
          headerActions: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'BIENTÔT',
                style: TextStyle(color: EskoliaTokens.textSecondary, fontSize: 9, fontWeight: FontWeight.bold),
              ),
            ),
          ],
          body: const TpGlpiCardBody(),
        ),
        cardWidth,
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildCardByKeyForReseau(String key, double cardWidth) {
    return _buildDraggableCard(
      key,
      _buildInteractiveCard(
        key: key,
        title: 'Réseau & Adressage IP',
        defaultEmoji: '🌐',
        accentColor: EskoliaTokens.cyan,
        body: const TpReseauCardBody(),
      ),
      cardWidth,
    );
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

  Widget _buildCardsGrid(BuildContext context, double cardWidth, int numColumns) {
    final rawOrder = ref.watch(tpCardsOrderProvider);
    final pinned = ref.watch(tpPinnedCardsProvider);

    Widget buildGrid(List<String> keys) {
      final cards = keys.map((key) => _buildCardByKey(key, cardWidth)).toList();

      if (numColumns >= 4) {
        final cols = List.generate(4, (_) => <Widget>[]);
        for (var i = 0; i < keys.length; i++) {
          cols[i % 4].add(cards[i]);
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Column(children: _addSpacing(cols[0]))),
            const SizedBox(width: 16),
            Expanded(child: Column(children: _addSpacing(cols[1]))),
            const SizedBox(width: 16),
            Expanded(child: Column(children: _addSpacing(cols[2]))),
            const SizedBox(width: 16),
            Expanded(child: Column(children: _addSpacing(cols[3]))),
          ],
        );
      } else if (numColumns == 3) {
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
    final hPad = EskoliaLayout.screenPaddingH;
    final width = MediaQuery.sizeOf(context).width;
    final isDesktopOrTablet = width >= 700;

    final sidebarWidth = isDesktopOrTablet ? (ref.watch(sidebarCollapsedProvider) ? 72 : 250) : 0;
    final availableWidth = (width - sidebarWidth - (hPad * 2)).clamp(280.0, double.infinity);

    final colPref = ref.watch(columnPreferenceProvider('tp'));
    final colRes = ColumnResolution.compute(
      preference: colPref,
      availableWidth: availableWidth,
      maxAutoColumns: 4,
    );
    final numColumns = colRes.columns;
    final cardWidth = colRes.cardWidth;

    final rawOrder = ref.watch(tpCardsOrderProvider);

    const availableTpCards = [
      EskoliaCardOption(key: 'feature:tp_reseau', title: 'Réseau & Adressage IP', emoji: '🌐'),
      EskoliaCardOption(key: 'feature:tp_osi', title: 'Modèle OSI', emoji: '🌐'),
      EskoliaCardOption(key: 'feature:tp_ad', title: 'Active Directory', emoji: '👥'),
      EskoliaCardOption(key: 'feature:tp_powershell', title: 'Scripting PowerShell', emoji: '💻'),
      EskoliaCardOption(key: 'feature:tp_packet_tracer', title: 'Packet Tracer', emoji: '⚡'),
      EskoliaCardOption(key: 'feature:tp_itil', title: 'Gestion de Tickets (ITIL)', emoji: '🎟️'),
      EskoliaCardOption(key: 'feature:tp_glpi', title: 'TP GLPI', emoji: '📦'),
    ];

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
                  title: 'Travaux Pratiques',
                  screenKey: 'tp',
                  onCollapseAll: () => ref.read(homeCardSettingsProvider.notifier).collapseAll(rawOrder),
                  onExpandAll: () => ref.read(homeCardSettingsProvider.notifier).expandAll(rawOrder),
                  availableCards: availableTpCards,
                  maxColumns: 4,
                ),
                const SizedBox(height: 12),
                _buildCardsGrid(context, cardWidth, numColumns),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- STANDALONE PUBLIC CARD BODIES ---

const Map<String, String> _kScenarioAssets = {
  'tp_ad_aerotech':       'assets/tp/AD/scenario_a_aerotech.json',
  'tp_ad_pixel':          'assets/tp/AD/scenario_b_pixel_academy.json',
  'tp_ad_saint_lazare':   'assets/tp/AD/scenario_c_saint_lazare.json',
  'tp_ps_fondamentaux':   'assets/tp/PS/scenario_ps_fondamentaux.json',
  'tp_ps_systeme':        'assets/tp/PS/scenario_ps_systeme.json',
  'tp_ps_scripting':      'assets/tp/PS/scenario_ps_scripting.json',
  'tp_pt_fondamentaux':   'assets/tp/PT/scenario_pt_fondamentaux.json',
  'tp_pt_depannage_1':    'assets/tp/PT/scenario_pt_depannage_1.json',
  'tp_pt_vlans':          'assets/tp/PT/scenario_pt_vlans.json',
  'tp_pt_multisites':     'assets/tp/PT/scenario_pt_multisites.json',
};

class TpScenarioTile extends ConsumerStatefulWidget {
  const TpScenarioTile({
    super.key,
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.difficulty,
    required this.missionCount,
    required this.accentColor,
  });

  final String id;
  final String title;
  final String description;
  final String emoji;
  final String difficulty;
  final int missionCount;
  final Color accentColor;

  @override
  ConsumerState<TpScenarioTile> createState() => _TpScenarioTileState();
}

class _TpScenarioTileState extends ConsumerState<TpScenarioTile> {
  final _progressRepo = PracticalMissionsFirestoreRepository();
  bool _isExpanded = false;
  bool _loading = false;
  Map<String, dynamic>? _scenario;
  int _nextMissionIndex = 0;
  String? _errorMessage;

  Future<void> _loadScenarioData() async {
    if (_scenario != null) return;
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    final assetPath = _kScenarioAssets[widget.id];
    if (assetPath == null) {
      setState(() {
        _errorMessage = 'Scénario introuvable.';
        _loading = false;
      });
      return;
    }
    try {
      final raw = await AssetCacheService.loadString(assetPath);
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final next = await _progressRepo.readNextMissionIndex(widget.id);
      if (!mounted) return;
      setState(() {
        _scenario = data;
        _nextMissionIndex = next;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Impossible de charger les missions.';
        _loading = false;
      });
    }
  }

  void _showMissionDetail(Map<String, dynamic> mission, int flatIndex) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => TpMissionDetailSheet(
        mission: mission,
        flatIndex: flatIndex,
        trackId: widget.id,
        onComplete: () async {
          await _progressRepo.setNextMissionIndex(widget.id, flatIndex + 1);
          if (mounted) {
            setState(() => _nextMissionIndex = flatIndex + 1);
          }
          if (ctx.mounted) Navigator.pop(ctx);
        },
      ),
    );
  }

  Color _hexColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return EskoliaTokens.violet;
    }
  }

  Widget _badge(String label, Color color) {
    final isWhite24Value = color == Colors.white24;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withValues(alpha: isWhite24Value ? 0.15 : 0.25),
          width: 0.8,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isWhite24Value ? EskoliaTokens.textSecondary : color,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: () {
          setState(() => _isExpanded = !_isExpanded);
          if (_isExpanded) {
            _loadScenarioData();
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: widget.accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(widget.emoji, style: const TextStyle(fontSize: 18)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            _badge('${widget.missionCount} m.', widget.accentColor),
                            const SizedBox(width: 4),
                            _badge(widget.difficulty, Colors.white24),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.description,
                          style: TextStyle(
                            color: EskoliaTokens.textSecondary.withValues(alpha: 0.8),
                            fontSize: 11,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Center(
                    child: Icon(
                      _isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                      color: Colors.white38,
                      size: 20,
                    ),
                  ),
                ],
              ),
              if (_isExpanded) ...[
                const SizedBox(height: 12),
                if (_loading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: CircularProgressIndicator(strokeWidth: 2, color: EskoliaTokens.cyan),
                    ),
                  )
                else if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: EskoliaTokens.error, fontSize: 11),
                    ),
                  )
                else if (_scenario != null) ...[
                  const Divider(height: 1, color: Colors.white10),
                  const SizedBox(height: 8),
                  for (final lvl in (_scenario!['levels'] as List<dynamic>? ?? [])) ...[
                    () {
                      final level = Map<String, dynamic>.from(lvl);
                      final levelColor = _hexColor(level['color'] as String? ?? '#7C6FFF');
                      final missions = (level['missions'] as List<dynamic>?) ?? [];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                Container(width: 3, height: 14, decoration: BoxDecoration(color: levelColor, borderRadius: BorderRadius.circular(2))),
                                const SizedBox(width: 8),
                                Text(
                                  level['emoji'] as String? ?? '',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    level['title'] as String? ?? '',
                                    style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          for (int mi = 0; mi < missions.length; mi++) ...[
                            () {
                              final mission = Map<String, dynamic>.from(missions[mi]);
                              final levelsList = _scenario!['levels'] as List<dynamic>;
                              int flatIndex = 0;
                              for (int i = 0; i < levelsList.length; i++) {
                                final l = Map<String, dynamic>.from(levelsList[i]);
                                if (l['title'] == level['title']) {
                                  break;
                                }
                                flatIndex += (l['missions'] as List<dynamic>? ?? []).length;
                              }
                              flatIndex += mi;

                              final isCompleted = flatIndex < _nextMissionIndex;
                              final isCurrent = flatIndex == _nextMissionIndex;
                              final isLocked = flatIndex > _nextMissionIndex;
                              final minutes = mission['estimated_minutes'] as int? ?? 0;
                              final tappable = !isLocked;

                              return Opacity(
                                opacity: isLocked ? 0.45 : 1.0,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(6),
                                  onTap: tappable ? () => _showMissionDetail(mission, flatIndex) : null,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                                    child: Row(
                                      children: [
                                        isCompleted
                                            ? const Icon(Icons.check_circle_rounded, color: EskoliaTokens.success, size: 14)
                                            : isCurrent
                                                ? Icon(Icons.radio_button_checked_rounded, color: levelColor, size: 14)
                                                : const Icon(Icons.lock_rounded, color: EskoliaTokens.textSecondary, size: 12),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            mission['title'] as String? ?? '',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: isCompleted
                                                  ? Colors.white54
                                                  : Colors.white.withValues(alpha: 0.9),
                                              fontSize: 12,
                                              decoration: isCompleted ? TextDecoration.lineThrough : null,
                                            ),
                                          ),
                                        ),
                                        if (minutes > 0) ...[
                                          const SizedBox(width: 4),
                                          Text(
                                            '$minutes min',
                                            style: const TextStyle(color: EskoliaTokens.textSecondary, fontSize: 10),
                                          ),
                                        ],
                                        const SizedBox(width: 6),
                                        if (tappable)
                                          Icon(Icons.play_arrow_rounded, color: widget.accentColor.withValues(alpha: 0.8), size: 14),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }(),
                          ],
                          const SizedBox(height: 8),
                        ],
                      );
                    }(),
                  ],
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class TpReseauCardBody extends ConsumerStatefulWidget {
  const TpReseauCardBody({super.key});

  @override
  ConsumerState<TpReseauCardBody> createState() => _TpReseauCardBodyState();
}

class _TpReseauCardBodyState extends ConsumerState<TpReseauCardBody> {
  TpDifficulty _reseauDifficulty = TpDifficulty.facile;

  Color _diffColor(TpDifficulty d) => switch (d) {
        TpDifficulty.facile    => EskoliaTokens.success,
        TpDifficulty.moyen     => EskoliaTokens.amber,
        TpDifficulty.difficile => EskoliaTokens.error,
      };

  IconData _diffIcon(TpDifficulty d) => switch (d) {
        TpDifficulty.facile    => Icons.emoji_events_outlined,
        TpDifficulty.moyen     => Icons.bar_chart_rounded,
        TpDifficulty.difficile => Icons.bolt_rounded,
      };

  String _diffDescription(TpDifficulty d) => switch (d) {
        TpDifficulty.facile =>
            'Nombres ronds, classes A/B/C simples, masques /8 /16 /24. Idéal pour débuter.',
        TpDifficulty.moyen =>
            'Valeurs variées, masques /25 /26 /22 /28, classes mixtes. Pour consolider.',
        TpDifficulty.difficile =>
            'Valeurs complexes, masques /19 /21 /27 /29, subnetting non trivial.',
      };

  Widget _badge(String label, Color color) {
    final isWhite24Value = color == Colors.white24;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withValues(alpha: isWhite24Value ? 0.15 : 0.25),
          width: 0.8,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isWhite24Value ? EskoliaTokens.textSecondary : color,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _sectionPill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color.withValues(alpha: 0.85),
          fontSize: 8.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDifficultySelector() {
    return Row(
      children: TpDifficulty.values.map((d) {
        final isSelected = _reseauDifficulty == d;
        final color = _diffColor(d);
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: InkWell(
              onTap: () => setState(() => _reseauDifficulty = d),
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? color.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? color.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.08),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      d == TpDifficulty.facile
                          ? 'Facile'
                          : (d == TpDifficulty.moyen ? 'Moyen' : 'Difficile'),
                      style: TextStyle(
                        color: isSelected ? Colors.white : EskoliaTokens.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDifficultyBanner(TpDifficulty d) {
    final color = _diffColor(d);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Icon(_diffIcon(d), color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _diffDescription(d),
              style: TextStyle(
                color: EskoliaTokens.textSecondary.withValues(alpha: 0.9),
                fontSize: 11,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiGenerateCard(BuildContext context, AiConnectionState aiState, TpDifficulty difficulty) {
    return EskoliaCardContent(
      accentBorderColor: EskoliaTokens.violet,
      padding: const EdgeInsets.all(12),
      onTap: () => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => AiGenerateSheet(
          aiState: aiState,
          initialDifficulty: difficulty,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: EskoliaTokens.violet.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Icon(Icons.auto_awesome_rounded, color: EskoliaTokens.violet, size: 18),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Générer un TP avec l\'IA',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Exercices uniques en temps réel',
                  style: TextStyle(color: EskoliaTokens.textSecondary.withValues(alpha: 0.7), fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 14),
        ],
      ),
    );
  }

  Widget _buildTpListItem(TpBinaire tp, int index, Color color) {
    final totalQ = tp.sections.fold(0, (s, sec) => s + sec.questions.length);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$index',
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'TP N°$index',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 6),
                    _badge('${tp.totalPoints} pts', color),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '$totalQ questions · 6 sections',
                  style: TextStyle(
                    color: EskoliaTokens.textSecondary.withValues(alpha: 0.7),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    _sectionPill('Dec→Bin',    EskoliaTokens.violet),
                    _sectionPill('Bin→Dec',    EskoliaTokens.cyan),
                    _sectionPill('Classes IP', EskoliaTokens.success),
                    _sectionPill('Masques',    EskoliaTokens.amber),
                    _sectionPill('CIDR',       EskoliaTokens.error),
                    _sectionPill('Subnetting', EskoliaTokens.textSecondary),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => context.push('/tp/binaire/${tp.id}'),
            style: IconButton.styleFrom(
              backgroundColor: color.withValues(alpha: 0.1),
              foregroundColor: color,
              padding: const EdgeInsets.all(8),
            ),
            icon: const Icon(Icons.play_arrow_rounded, size: 20),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final aiState = ref.watch(aiConnectionStateProvider).value;
    final aiConnected = aiState?.isConnected == true;
    final tps = tpsByDifficulty(_reseauDifficulty);
    final diffCol = _diffColor(_reseauDifficulty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildDifficultySelector(),
        const SizedBox(height: 12),
        _buildDifficultyBanner(_reseauDifficulty),
        const SizedBox(height: 14),
        if (aiConnected) ...[
          _buildAiGenerateCard(context, aiState!, _reseauDifficulty),
          const SizedBox(height: 14),
        ],
        Row(
          children: [
            const SizedBox(width: 4),
            Text(
              '${tps.length} TRAVAUX PRATIQUES',
              style: TextStyle(
                color: diffCol,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
            const Expanded(child: Divider(color: Colors.white10, height: 1, indent: 8)),
          ],
        ),
        const SizedBox(height: 8),
        for (int i = 0; i < tps.length; i++) ...[
          _buildTpListItem(tps[i], i + 1, diffCol),
          if (i < tps.length - 1) const Divider(height: 1, color: Colors.white10),
        ],
      ],
    );
  }
}

class TpActiveDirectoryCardBody extends StatelessWidget {
  const TpActiveDirectoryCardBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TpScenarioTile(
          id: 'tp_ad_aerotech',
          title: 'AeroTech Solutions',
          description: 'Installation et configuration de base d\'un contrôleur de domaine Windows Server 2022.',
          emoji: '✈️',
          difficulty: 'Débutant',
          missionCount: 18,
          accentColor: EskoliaTokens.info,
        ),
        const Divider(height: 1, color: Colors.white10),
        TpScenarioTile(
          id: 'tp_ad_pixel',
          title: 'Pixel Academy',
          description: 'Gestion des GPO et déploiement de logiciels pour une école de design.',
          emoji: '🎨',
          difficulty: 'Intermédiaire',
          accentColor: EskoliaTokens.info,
          missionCount: 16,
        ),
        const Divider(height: 1, color: Colors.white10),
        TpScenarioTile(
          id: 'tp_ad_saint_lazare',
          title: 'Saint-Lazare Digital',
          description: 'Sécuriser l\'infrastructure d\'un hôpital sous contraintes RGPD.',
          emoji: '🏥',
          difficulty: 'Avancé',
          accentColor: EskoliaTokens.error,
          missionCount: 16,
        ),
      ],
    );
  }
}

class TpPowerShellCardBody extends StatelessWidget {
  const TpPowerShellCardBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TpScenarioTile(
          id: 'tp_ps_fondamentaux',
          title: 'Fondamentaux PowerShell',
          description: 'Navigation, fichiers, variables et pipeline — les bases indispensables.',
          emoji: '💻',
          difficulty: 'Débutant',
          missionCount: 16,
          accentColor: EskoliaTokens.info,
        ),
        const Divider(height: 1, color: Colors.white10),
        TpScenarioTile(
          id: 'tp_ps_systeme',
          title: 'Gestion du système Windows',
          description: 'Processus, services, utilisateurs locaux et réseau en ligne de commande.',
          emoji: '⚙️',
          difficulty: 'Intermédiaire',
          missionCount: 16,
          accentColor: EskoliaTokens.violet,
        ),
        const Divider(height: 1, color: Colors.white10),
        TpScenarioTile(
          id: 'tp_ps_scripting',
          title: 'Scripting PowerShell',
          description: 'Automatiser les tâches admin : boucles, fonctions, gestion d\'erreurs, CSV.',
          emoji: '🚀',
          difficulty: 'Avancé',
          missionCount: 16,
          accentColor: EskoliaTokens.success,
        ),
      ],
    );
  }
}

class TpPacketTracerCardBody extends StatelessWidget {
  const TpPacketTracerCardBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TpScenarioTile(
          id: 'tp_pt_fondamentaux',
          title: 'Fondamentaux Réseau',
          description: 'Construis le réseau de TechCorp depuis zéro — câblage, IP, routage statique.',
          emoji: '🌐',
          difficulty: 'Débutant',
          missionCount: 4,
          accentColor: EskoliaTokens.cyan,
        ),
        const Divider(height: 1, color: Colors.white10),
        TpScenarioTile(
          id: 'tp_pt_depannage_1',
          title: 'Dépannage Réseau — Niveau 1',
          description: 'Trois pannes à diagnostiquer et corriger. Fichiers .pkt fournis.',
          emoji: '🔧',
          difficulty: 'Débutant',
          missionCount: 3,
          accentColor: EskoliaTokens.amber,
        ),
        const Divider(height: 1, color: Colors.white10),
        TpScenarioTile(
          id: 'tp_pt_vlans',
          title: 'VLANs & Routage Inter-VLAN',
          description: 'Segmente le réseau TechCorp par département et configure le Router-on-a-Stick.',
          emoji: '🔀',
          difficulty: 'Moyen',
          missionCount: 4,
          accentColor: EskoliaTokens.violet,
        ),
        const Divider(height: 1, color: Colors.white10),
        TpScenarioTile(
          id: 'tp_pt_multisites',
          title: 'TechCorp Multi-Sites',
          description: 'Paris + Lyon — 2 classes d\'adresses, 2 VLANs par site, routage statique complet.',
          emoji: '🏢',
          difficulty: 'Moyen+',
          missionCount: 5,
          accentColor: EskoliaTokens.amber,
        ),
      ],
    );
  }
}

class TpComingSoonCardBody extends ConsumerStatefulWidget {
  const TpComingSoonCardBody({
    super.key,
    required this.id,
    required this.accentColor,
    required this.description,
  });

  final String id;
  final Color accentColor;
  final String description;

  @override
  ConsumerState<TpComingSoonCardBody> createState() => _TpComingSoonCardBodyState();
}

class _TpComingSoonCardBodyState extends ConsumerState<TpComingSoonCardBody> {
  final _firestoreRepo = PracticalMissionsFirestoreRepository();
  bool _interested = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.description,
          style: TextStyle(color: EskoliaTokens.textSecondary.withValues(alpha: 0.6), fontSize: 12, height: 1.35),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _interested ? null : () async {
            await _firestoreRepo.markInterest(widget.id);
            if (!mounted) return;
            setState(() => _interested = true);
            ScaffoldMessenger.of(this.context).showSnackBar(
              const SnackBar(content: Text('C\'est noté ! On vous préviendra. 🚀')),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _interested ? Colors.transparent : widget.accentColor.withValues(alpha: 0.15),
            foregroundColor: _interested ? EskoliaTokens.textSecondary : widget.accentColor,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: _interested ? Colors.white10 : widget.accentColor.withValues(alpha: 0.3)),
            ),
          ),
          child: Text(_interested ? 'Inscrit ✔' : 'Ça m\'intéresse', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

class TpItilCardBody extends StatelessWidget {
  const TpItilCardBody({super.key});

  @override
  Widget build(BuildContext context) {
    return const TpComingSoonCardBody(
      id: 'tp_itil',
      accentColor: EskoliaTokens.violet,
      description: 'Apprends à gérer un Service Desk comme un pro.',
    );
  }
}

class TpGlpiCardBody extends StatelessWidget {
  const TpGlpiCardBody({super.key});

  @override
  Widget build(BuildContext context) {
    return const TpComingSoonCardBody(
      id: 'tp_glpi',
      accentColor: EskoliaTokens.textDisabled,
      description: 'Déploiement et configuration de GLPI pour la gestion d\'actifs et de tickets.',
    );
  }
}
