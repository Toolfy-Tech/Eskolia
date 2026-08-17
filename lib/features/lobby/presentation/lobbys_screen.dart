import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../home/presentation/providers/home_providers.dart';
import '../../home/presentation/widgets/home_card_settings_dialog.dart';
import 'providers/lobby_providers.dart';
import 'widgets/duel_quick_card_body.dart';

import '../../../core/constants/eskolia_tokens.dart';
import '../../../core/utils/feature_info_resolver.dart';
import '../../../core/theme/eskolia_layout.dart';
import '../../../core/theme/eskolia_visual.dart';
import '../../../core/widgets/bottom_nav.dart';
import '../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../shared/widgets/eskolia_app_bar.dart';
import '../../../shared/widgets/eskolia_shell_body.dart';
import '../../../shared/widgets/eskolia_card.dart';
import '../../../shared/widgets/eskolia_column_switcher.dart';
import '../../../shared/widgets/eskolia_page_header_toolbar.dart';
import '../../../shared/widgets/eskolia_section_card.dart';
import 'widgets/lobby_create_card_body.dart';
import 'widgets/lobby_create_ai_card_body.dart';
import 'widgets/lobby_join_private_card_body.dart';
import '../../../shared/widgets/teacher_quiz_picker_widget.dart';
import '../../parcours/data/tip_quiz_catalog.dart';
import '../../quiz/presentation/widgets/quiz_catalog_track_selector.dart';
import '../../quiz/presentation/widgets/quiz_scope_picker.dart';
import '../../../data/repositories/user_repository.dart';
import '../data/lobby_repository.dart';
import '../data/models/custom_quiz_data.dart';
import 'widgets/custom_quiz_import_widget.dart';
import '../../ai/data/ai_key_repository.dart';
import '../../notebook/data/note_ai_generator.dart';

const Color _bg = EskoliaVisual.bgDeep;
const Color _cyan = EskoliaTokens.cyan;
const Color _violet = EskoliaTokens.violet;
const Color _slate = EskoliaTokens.textSecondary;
const Color _slateLight = EskoliaTokens.textSecondary;
const Color _surface = EskoliaTokens.surface2;
const Color _green = EskoliaTokens.success;
const Color _orange = EskoliaTokens.amber;
const Color _red = EskoliaTokens.error;

class LobbyListScreen extends ConsumerStatefulWidget {
  const LobbyListScreen({super.key});

  @override
  ConsumerState<LobbyListScreen> createState() => _LobbyListScreenState();
}

class _LobbyListScreenState extends ConsumerState<LobbyListScreen>
    with SingleTickerProviderStateMixin {
  final LobbyRepository _repo = LobbyRepository();
  int _retry = 0;
  late AnimationController _pulse;
  bool _isStaff = false;

  Timer? _dragDebounceTimer;
  String? _hoveredDragKey;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _cleanupStale();
    _checkStaff();
  }

  Future<void> _checkStaff() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      final user = await UserRepository().getUserById(uid);
      if (mounted && user != null) setState(() => _isStaff = user.isStaff);
    } catch (e) {
      debugPrint('[LobbyListScreen._checkStaff] $e');
    }
  }

  Future<void> _cleanupStale() async {
    try {
      await _repo.cleanupStaleLobbies();
    } catch (e) {
      debugPrint('[LobbyListScreen._cleanupStale] $e');
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    _dragDebounceTimer?.cancel();
    super.dispose();
  }

  List<LobbyModel> _joinableLobbies(List<LobbyModel> all) {
    final open = all
        .where(
          (l) =>
              (l.status == 'waiting' || l.status == 'in_progress') &&
              !l.isFull,
        )
        .toList();
    open.sort((a, b) {
      final wa = a.status == 'waiting' ? 0 : 1;
      final wb = b.status == 'waiting' ? 0 : 1;
      if (wa != wb) return wa.compareTo(wb);
      return b.createdAt.compareTo(a.createdAt);
    });
    return open;
  }

  Future<void> _joinByCode() async {
    final ctrl = TextEditingController();
    final id = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: AlertDialog(
            backgroundColor: EskoliaTokens.surface1.withValues(alpha: 0.94),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
            ),
            title: const Text(
              'Rejoindre par code',
              style: TextStyle(color: Colors.white),
            ),
            content: TextField(
              controller: ctrl,
              style: const TextStyle(color: Colors.white, letterSpacing: 2),
              textCapitalization: TextCapitalization.characters,
              maxLength: 8,
              decoration: InputDecoration(
                counterText: '',
                hintText: 'Ex. A2K9P4',
                hintStyle: TextStyle(color: _slateLight.withValues(alpha: 0.7)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('Annuler', style: TextStyle(color: _slateLight)),
              ),
              FilledButton(
                onPressed: () async {
                  final raw = ctrl.text.trim();
                  if (raw.length < 4) return;
                  final found = await _repo.findLobbyIdByJoinCode(raw);
                  if (!ctx.mounted) return;
                  if (found == null) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(
                        content: Text('Code introuvable ou lobby fermé.'),
                      ),
                    );
                    return;
                  }
                  Navigator.pop(ctx, found);
                },
                style: FilledButton.styleFrom(backgroundColor: _cyan),
                child: const Text('Rejoindre'),
              ),
            ],
          ),
        );
      },
    );
    ctrl.dispose();
    if (id != null && mounted) {
      context.push('/lobby/$id');
    }
  }

  Widget _buildInteractiveCard({
    required String key,
    required String category,
    required String title,
    required String defaultEmoji,
    required Color accentColor,
    required Widget body,
  }) {
    final isPinned = ref.watch(lobbyPinnedCardsProvider).contains(key);
    final isAddedToHome = ref.watch(homeCardsOrderProvider).contains(key);

    return EskoliaSectionCard(
      cardKey: key,
      badge: 'MULTI',
      title: title,
      accentColor: accentColor,
      isPinned: isPinned,
      onTogglePin: () => ref.read(lobbyPinnedCardsProvider.notifier).togglePin(key),
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

  Widget _buildDraggableCard(String key, Widget child, double width) {
    final isWebOrDesktop = kIsWeb || 
        defaultTargetPlatform == TargetPlatform.macOS || 
        defaultTargetPlatform == TargetPlatform.windows || 
        defaultTargetPlatform == TargetPlatform.linux;

    final feedbackWidget = Material(
      color: Colors.transparent,
      child: Transform.rotate(
        angle: 0.035, // ~2 degrés d'inclinaison
        child: Transform.scale(
          scale: 1.04, // léger zoom
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
                final pinned = ref.read(lobbyPinnedCardsProvider);
                final isDragPinned = pinned.contains(dragKey);
                final isTargetPinned = pinned.contains(key);

                if (isDragPinned != isTargetPinned) {
                  ref.read(lobbyPinnedCardsProvider.notifier).togglePin(dragKey);
                }

                final order = ref.read(lobbyCardsOrderProvider);
                final oldIdx = order.indexOf(dragKey);
                final newIdx = order.indexOf(key);
                if (oldIdx != -1 && newIdx != -1) {
                  ref.read(lobbyCardsOrderProvider.notifier).reorder(oldIdx, newIdx);
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

        final mainChild = LongPressDraggable<String>(
          key: ValueKey(key),
          data: key,
          delay: const Duration(milliseconds: 700),
          feedback: feedbackWidget,
          childWhenDragging: Opacity(
            opacity: 0.2,
            child: cardWidget,
          ),
          child: cardWidget,
        );

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

  Widget _buildCardContent(String key, BuildContext context) {
    if (key == 'feature:lobbys_active') {
      return _buildInteractiveCard(
        key: key,
        category: 'PARTIES EN COURS',
        title: 'Salons Actifs',
        defaultEmoji: '🎮',
        accentColor: Colors.pinkAccent,
        body: StreamBuilder<List<LobbyModel>>(
          key: ValueKey(_retry),
          stream: _repo.watchLobbies(),
          builder: (context, snap) {
            if (snap.hasError) {
              return _error(snap.error.toString());
            }
            final waitingConnection =
                snap.connectionState == ConnectionState.waiting &&
                    !snap.hasData;
            final all = snap.data ?? [];
            final joinable = _joinableLobbies(all);
            final waitingCount =
                joinable.where((l) => l.status == 'waiting').length;
            final liveCount = joinable
                .where((l) => l.status == 'in_progress')
                .length;

            if (waitingConnection) {
              return Column(
                children: _skeletonSectionChildren(),
              );
            }

            if (joinable.isEmpty) {
              return _emptyLobbyQueueCard();
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _LobbyQueueBadges(
                      waitingCount: waitingCount,
                      liveCount: liveCount,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Column(
                  children: joinable.asMap().entries.map((e) {
                    final i = e.key;
                    final lobby = e.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: LobbyCard(
                        lobby: lobby,
                        index: i,
                        showJoinCta: true,
                        onTap: () => context.push('/lobby/${lobby.id}'),
                        onDelete: (_isStaff ||
                                lobby.hostId ==
                                    FirebaseAuth
                                        .instance.currentUser?.uid)
                            ? () => _repo.deleteLobby(lobby.id)
                            : null,
                        isAdminDelete: _isStaff &&
                            lobby.hostId !=
                                FirebaseAuth.instance.currentUser?.uid,
                      ),
                    );
                  }).toList(),
                ),
              ],
            );
          },
        ),
      );
    }
    if (key == 'feature:lobbys_create') {
      return _buildInteractiveCard(
        key: key,
        category: 'CRÉATION DE SALON',
        title: 'Créer un Salon',
        defaultEmoji: '➕',
        accentColor: Colors.pinkAccent,
        body: const LobbyCreateCardBody(isExpandedOverride: true),
      );
    }
    if (key == 'feature:lobbys_create_ai') {
      return _buildInteractiveCard(
        key: key,
        category: 'CRÉATION DE SALON IA',
        title: 'Créer un Salon IA',
        defaultEmoji: '🧠',
        accentColor: EskoliaTokens.amber,
        body: const LobbyCreateAiCardBody(isExpandedOverride: true),
      );
    }
    if (key == 'feature:lobbys_join_private') {
      return _buildInteractiveCard(
        key: key,
        category: 'REJOINDRE PAR CODE',
        title: 'Rejoindre par Code',
        defaultEmoji: '🔑',
        accentColor: EskoliaTokens.cyan,
        body: const LobbyJoinPrivateCardBody(isExpandedOverride: true),
      );
    }
    if (key == 'feature:duel_quick') {
      return _buildInteractiveCard(
        key: key,
        category: 'DÉFI EXPRESS 1V1',
        title: 'Défi Express',
        defaultEmoji: '⚡',
        accentColor: Colors.purpleAccent,
        body: const DuelQuickCardBody(isExpandedOverride: true),
      );
    }
    return const SizedBox.shrink();
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

  @override
  Widget build(BuildContext context) {
    final hPad = EskoliaLayout.screenPaddingH;
    final width = MediaQuery.sizeOf(context).width;

    final isLargeScreen = width >= 700;
    final sidebarWidth = isLargeScreen ? (ref.watch(sidebarCollapsedProvider) ? 78.0 : 250.0) : 0.0;
    final availableWidth = (width - sidebarWidth - (hPad * 2)).clamp(280.0, double.infinity);

    final colPref = ref.watch(columnPreferenceProvider('lobbys'));
    final colRes = ColumnResolution.compute(
      preference: colPref,
      availableWidth: availableWidth,
      maxAutoColumns: 4,
    );
    final numColumns = colRes.columns;
    final cardWidth = colRes.cardWidth;

    final rawOrder = ref.watch(lobbyCardsOrderProvider);
    final pinned = ref.watch(lobbyPinnedCardsProvider);

    final order = rawOrder;

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
          if (key == 'feature:lobby_battles') return 380.0;
          return 340.0;
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
                  title: 'Multijoueur',
                  screenKey: 'lobbys',
                  onCollapseAll: () => ref.read(homeCardSettingsProvider.notifier).collapseAll(order),
                  onExpandAll: () => ref.read(homeCardSettingsProvider.notifier).expandAll(order),
                  extraActions: [
                    TextButton(
                      onPressed: _joinByCode,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Code',
                        style: TextStyle(
                          color: _cyan,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                  availableCards: const [
                    EskoliaCardOption(key: 'feature:lobbys_active', title: 'Salons Actifs', emoji: '🎮'),
                    EskoliaCardOption(key: 'feature:lobbys_create', title: 'Créer un Salon', emoji: '➕'),
                    EskoliaCardOption(key: 'feature:lobbys_create_ai', title: 'Créer Salon IA', emoji: '🧠'),
                    EskoliaCardOption(key: 'feature:lobbys_join_private', title: 'Rejoindre par Code', emoji: '🔑'),
                    EskoliaCardOption(key: 'feature:duel_quick', title: 'Défi Express', emoji: '⚡'),
                  ],
                  maxColumns: 4,
                ),
                const SizedBox(height: 24),
                content,
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _skeletonSectionChildren() {
    return List.generate(
      3,
      (i) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: AnimatedBuilder(
          animation: _pulse,
          builder: (context, child) {
            final c = Color.lerp(_surface, EskoliaTokens.surface3, _pulse.value)!;
            return Container(
              height: 132,
              decoration: BoxDecoration(
                color: c,
                borderRadius: BorderRadius.circular(20),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _emptyLobbyQueueCard() {
    return EskoliaCardContent(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 4),
          Text(
            'Sois le premier à lancer une salle ⚡',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Aucune partie ouverte pour l'instant. "
            "Cree un lobby, invite tes coequipiers par code.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _slateLight.withValues(alpha: 0.85),
              fontSize: 12,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _error(String msg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('\u{26A0}\u{FE0F}', style: TextStyle(fontSize: 40)),
              const SizedBox(height: 8),
              Text(msg, style: TextStyle(color: _slateLight)),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => setState(() => _retry++),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

class _LobbyModeCard extends StatelessWidget {
  const _LobbyModeCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return EskoliaCardContent(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 34)),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _slateLight.withValues(alpha: 0.9),
              fontSize: 12,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Lancer la partie →',
            style: TextStyle(
              color: EskoliaTokens.cyan,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _LobbyQueueBadges extends StatelessWidget {
  const _LobbyQueueBadges({
    required this.waitingCount,
    required this.liveCount,
  });

  final int waitingCount;
  final int liveCount;

  @override
  Widget build(BuildContext context) {
    final parts = <Widget>[];
    if (waitingCount > 0) {
      parts.add(
        _BadgePill(
          label: '$waitingCount attente',
          fg: _green,
          bg: _green.withValues(alpha: 0.2),
        ),
      );
    }
    if (liveCount > 0) {
      if (parts.isNotEmpty) parts.add(const SizedBox(width: 6));
      parts.add(
        _BadgePill(
          label: '$liveCount en jeu',
          fg: _orange,
          bg: _orange.withValues(alpha: 0.2),
        ),
      );
    }
    return Row(mainAxisSize: MainAxisSize.min, children: parts);
  }
}

class _BadgePill extends StatelessWidget {
  const _BadgePill({
    required this.label,
    required this.fg,
    required this.bg,
  });

  final String label;
  final Color fg;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class LobbyCard extends StatelessWidget {
  const LobbyCard({
    super.key,
    required this.lobby,
    required this.index,
    required this.onTap,
    this.showJoinCta = false,
    this.onDelete,
    this.isAdminDelete = false,
  });

  final LobbyModel lobby;
  final int index;
  final VoidCallback onTap;
  final bool showJoinCta;
  /// Non-null si l'utilisateur peut supprimer ce lobby (owner ou admin).
  final Future<void> Function()? onDelete;
  /// true → suppression admin (orange), false → suppression owner (rouge).
  final bool isAdminDelete;

  (Color bg, Color fg, String label) _status() {
    switch (lobby.status) {
      case 'in_progress':
        return (
          _orange.withValues(alpha: 0.2),
          _orange,
          'En cours',
        );
      case 'finished':
        return (
          _slate.withValues(alpha: 0.2),
          _slate,
          'Terminé',
        );
      default:
        return (
          _green.withValues(alpha: 0.2),
          _green,
          'Ouvert',
        );
    }
  }

  (Color, Color) _diff() {
    final d = lobby.difficulty.toLowerCase();
    if (d == 'progressive') {
      return (_red.withValues(alpha: 0.2), EskoliaTokens.error);
    }
    if (d == 'mixte' || d.contains('+')) {
      return (_orange.withValues(alpha: 0.2), _orange);
    }
    switch (d) {
      case 'facile':
        return (_green.withValues(alpha: 0.2), _green);
      case 'difficile':
        return (Colors.red.withValues(alpha: 0.2), Colors.redAccent);
      default:
        return (_orange.withValues(alpha: 0.2), _orange);
    }
  }

  (Color bg, Color fg) _modeStyle() {
    if (lobby.isSurvival) {
      return (
        _red.withValues(alpha: 0.22),
        EskoliaTokens.error,
      );
    }
    return (
      _violet.withValues(alpha: 0.22),
      _violet,
    );
  }

  Future<void> _confirmAndDelete(BuildContext context) async {
    final dialogColor = isAdminDelete ? _orange : _red;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: EskoliaTokens.surface1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          isAdminDelete ? 'Supprimer ce lobby (admin) ?' : 'Supprimer ce lobby ?',
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          isAdminDelete
              ? 'Suppression en tant qu\'admin — action irréversible.'
              : 'Cette action est irréversible.',
          style: const TextStyle(color: _slateLight),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: dialogColor),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      try {
        await onDelete!();
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur : $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final st = _status();
    final df = _diff();
    final ms = _modeStyle();
    final ratio = lobby.maxPlayers > 0
        ? lobby.currentPlayers / lobby.maxPlayers
        : 0.0;
    final modeEmoji = lobby.isSurvival ? '\u{1F6E1}' : '\u{1F3AF}';
    final accent = ms.$2;
    final progressColor = lobby.isSurvival ? EskoliaTokens.error : _cyan;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        splashColor: _violet.withValues(alpha: 0.2),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Color.lerp(accent, Colors.white, 0.55)!
                  .withValues(alpha: lobby.isSurvival ? 0.42 : 0.35),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.12),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              if (onDelete != null)
                Positioned(
                  right: 0,
                  top: 0,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      isAdminDelete
                          ? Icons.admin_panel_settings_rounded
                          : Icons.delete_outline_rounded,
                      color: isAdminDelete
                          ? _orange.withValues(alpha: 0.85)
                          : _red.withValues(alpha: 0.75),
                      size: 20,
                    ),
                    tooltip: isAdminDelete ? 'Supprimer (admin)' : 'Supprimer le lobby',
                    onPressed: () => _confirmAndDelete(context),
                  ),
                ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.08),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: Text(lobby.hostAvatar, style: const TextStyle(fontSize: 16)),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 38,
                        height: 38,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: ms.$1,
                          border: Border.all(color: accent.withValues(alpha: 0.45)),
                        ),
                        child: Text(modeEmoji, style: const TextStyle(fontSize: 18)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Hôte : ${lobby.hostName}',
                    style: TextStyle(
                      color: _slateLight.withValues(alpha: 0.8),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    lobby.title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lobby.subject,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _slateLight.withValues(alpha: 0.7),
                      fontSize: 11.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: st.$1,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          st.$3,
                          style: TextStyle(
                            color: st.$2,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: df.$1,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          lobby.difficulty,
                          style: TextStyle(
                            color: df.$2,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: ratio.clamp(0, 1),
                            minHeight: 4,
                            backgroundColor: _surface,
                            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '👥 ${lobby.currentPlayers}/${lobby.maxPlayers}',
                        style: TextStyle(
                          color: _slateLight.withValues(alpha: 0.85),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (showJoinCta) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: onTap,
                        style: FilledButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Rejoindre', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 280.ms, delay: (index * 80).ms)
        .slideX(begin: 0.04, duration: 280.ms, delay: (index * 80).ms);
  }
}
