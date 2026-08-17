import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/eskolia_layout.dart';
import '../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../shared/widgets/eskolia_shell_body.dart';
import '../../../shared/widgets/eskolia_app_bar.dart';
import '../../auth/data/user_model.dart';
import '../../home/data/home_repository.dart';
import '../../home/presentation/providers/home_providers.dart';
import '../../home/presentation/widgets/tech_news_section.dart';
import '../../home/presentation/widgets/home_favoris_card.dart';
import '../../home/presentation/widgets/home_merged_card.dart';
import '../../home/presentation/widgets/home_sources_dialog.dart';
import '../../home/presentation/widgets/home_messages_card.dart';
import '../../home/presentation/widgets/home_astuces_card.dart';
import '../../../core/constants/eskolia_tokens.dart';
import 'package:flutter/foundation.dart';
import '../../../core/widgets/bottom_nav.dart';
import '../../../shared/widgets/eskolia_column_switcher.dart';
import '../../../shared/widgets/eskolia_page_header_toolbar.dart';

const Color _surfaceBar = EskoliaTokens.surface2;
const Color _redStreak  = EskoliaTokens.error;

class VeilleScreen extends ConsumerStatefulWidget {
  const VeilleScreen({super.key});

  @override
  ConsumerState<VeilleScreen> createState() => _VeilleScreenState();
}

class _VeilleScreenState extends ConsumerState<VeilleScreen> {
  final HomeRepository _repo = HomeRepository();

  UserModel? _user;
  bool _isLoading = true;
  String? _errorMessage;

  StreamSubscription<UserModel?>? _userSub;
  Timer? _dragDebounceTimer;
  String? _hoveredDragKey;

  @override
  void initState() {
    super.initState();
    _subscribeToUser();
  }

  @override
  void dispose() {
    _userSub?.cancel();
    _dragDebounceTimer?.cancel();
    super.dispose();
  }

  void _subscribeToUser() {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    _userSub = _repo.watchCurrentUser().listen(
      (user) {
        if (!mounted) return;
        if (user == null) {
          setState(() => _isLoading = false);
          context.go('/login');
          return;
        }
        setState(() {
          _user = user;
          _isLoading = false;
        });
      },
      onError: (Object e) {
        if (!mounted) return;
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: false,
      body: Stack(
        children: [
          const EskoliaAmbientBackground(),
          EskoliaShellBody(
            showBack: false,
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.sizeOf(context).width > 800
                      ? double.infinity
                      : EskoliaLayout.shellContentMaxWidth,
                ),
                child: _isLoading
                    ? _buildSkeleton()
                    : _errorMessage != null
                        ? _buildError()
                        : _user == null
                            ? const SizedBox.shrink()
                            : _buildMain(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeleton() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(height: 36, width: 36, decoration: BoxDecoration(color: _surfaceBar, borderRadius: BorderRadius.circular(18))),
              const SizedBox(width: 8),
              Container(height: 36, width: 36, decoration: BoxDecoration(color: _surfaceBar, borderRadius: BorderRadius.circular(18))),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 16, width: 200, decoration: BoxDecoration(color: _surfaceBar, borderRadius: BorderRadius.circular(8))),
          const SizedBox(height: 20),
          Container(height: 100, width: double.infinity, decoration: BoxDecoration(color: _surfaceBar, borderRadius: BorderRadius.circular(14))),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: _redStreak, size: 48),
          Text(_errorMessage ?? 'Erreur'),
          ElevatedButton(onPressed: _subscribeToUser, child: const Text('Réessayer')),
        ],
      ),
    );
  }

  Widget _buildCardByKey(String key, UserModel user) {
    if (key.startsWith('merge:')) {
      return HomeMergedCard(
        mergeKey: key,
        username: user.username,
        streak: user.streak,
      );
    }
    if (key.startsWith('source:')) {
      final sourceName = key.substring(7);
      String displayTitle = 'Veille $sourceName';
      String subtitle = 'Flux RSS dédié aux publications de $sourceName';
      if (sourceName.startsWith('custom:')) {
        try {
          final map = jsonDecode(sourceName.substring(7)) as Map<String, dynamic>;
          displayTitle = 'Veille ${map['label'] ?? 'perso'}';
          subtitle = 'Flux RSS personnalisé';
        } catch (_) {}
      }
      return TechNewsSection(
        category: 'all',
        title: displayTitle,
        subtitle: subtitle,
        emoji: '📡',
        sourceFilter: sourceName,
        isVeilleScreen: true,
      );
    }
    switch (key) {
      case 'it_pro':
        return const TechNewsSection(
          category: 'all',
          title: 'Veille Générale',
          subtitle: 'Actualités IT, infra, cloud, et développement — flux RSS externes',
          emoji: '🖥️',
          isVeilleScreen: true,
        );
      case 'it':
        return const TechNewsSection(
          category: 'it',
          title: 'Veille IT',
          subtitle: 'Flux RSS dédié aux thèmes IT et Infrastructure',
          emoji: '💻',
          isVeilleScreen: true,
        );
      case 'security':
        return const TechNewsSection(
          category: 'security',
          title: 'Sécurité & Menaces',
          subtitle: 'Cybersécurité, vulnérabilités, alertes… — flux RSS externes',
          emoji: '🛡️',
          isVeilleScreen: true,
        );
      case 'hardware':
        return const TechNewsSection(
          category: 'hardware',
          title: 'Veille Hardware',
          subtitle: 'Actualités matériel, composants et nouveautés hardware',
          emoji: '🔌',
          isVeilleScreen: true,
        );
      case 'software':
        return const TechNewsSection(
          category: 'software',
          title: 'Veille Software',
          subtitle: 'Actualités systèmes, logiciels et dev — flux RSS externes',
          emoji: '💿',
          isVeilleScreen: true,
        );
      case 'favoris':
        return const HomeFavorisCard(isVeilleScreen: true);
      case 'messages':
        return HomeMessagesCard(username: user.username, streak: user.streak, isVeilleScreen: true);
      case 'astuces':
        return const HomeAstucesCard(isVeilleScreen: true);
      case 'add_source':
        return const VeilleAddSourceCard();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildMain(BuildContext context) {
    final user = _user!;
    final width = MediaQuery.sizeOf(context).width;

    final isDesktopOrTablet = width >= 700;
    final sidebarWidth = isDesktopOrTablet ? (ref.watch(sidebarCollapsedProvider) ? 72 : 250) : 0;
    final availableWidth = (width - sidebarWidth - 40).clamp(280.0, double.infinity);

    final colPref = ref.watch(columnPreferenceProvider('veille'));
    final colRes = ColumnResolution.compute(
      preference: colPref,
      availableWidth: availableWidth,
      maxAutoColumns: 4,
    );
    final numColumns = colRes.columns;
    final cardWidth = colRes.cardWidth;

    final subSources = ref.watch(homeSubscribedSourcesProvider);
    final order = ref.watch(veilleCardsOrderProvider);

    final coreVeilleKeys = ['messages', 'astuces', 'it_pro', 'it', 'security', 'hardware', 'software', 'favoris'];
    final customSourceKeys = subSources.map((s) => 'source:$s').toList();
    final activeKeys = [...coreVeilleKeys, ...customSourceKeys];

    final veilleKeys = order.where((k) => activeKeys.contains(k)).toList();
    for (final key in activeKeys) {
      if (!veilleKeys.contains(key)) {
        veilleKeys.add(key);
      }
    }
    veilleKeys.add('add_source');

    const availableVeilleCards = [
      EskoliaCardOption(key: 'messages', title: 'Messages', emoji: '👋'),
      EskoliaCardOption(key: 'astuces', title: 'Astuces', emoji: '💡'),
      EskoliaCardOption(key: 'it_pro', title: 'Veille IT Générale', emoji: '🖥️'),
      EskoliaCardOption(key: 'it', title: 'Veille IT', emoji: '💻'),
      EskoliaCardOption(key: 'security', title: 'Sécurité & Menaces', emoji: '🛡️'),
      EskoliaCardOption(key: 'hardware', title: 'Veille Hardware', emoji: '🔌'),
      EskoliaCardOption(key: 'software', title: 'Veille Software', emoji: '💿'),
      EskoliaCardOption(key: 'favoris', title: 'Articles Favoris', emoji: '❤️'),
    ];

    Widget buildGrid(List<String> keys) {
      final cards = keys.map((key) {
        return _buildDraggableCard(key, _buildCardByKey(key, user), cardWidth);
      }).toList();

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

    final pinned = ref.watch(veillePinnedCardsProvider);

    Widget gridContent;
    if (veilleKeys.isEmpty) {
      gridContent = Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40.0),
          child: Text(
            'Aucun flux RSS sélectionné.\nUtilise "Flux & Sources" ci-dessus pour t\'abonner.',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(color: Colors.white54, fontSize: 14),
          ),
        ),
      );
    } else {
      if (pinned.isEmpty) {
        gridContent = buildGrid(veilleKeys);
      } else {
        final pinnedKeys = veilleKeys.where((k) => pinned.contains(k)).toList();
        final otherKeys = veilleKeys.where((k) => !pinned.contains(k)).toList();
        gridContent = Column(
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

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EskoliaPageHeaderToolbar(
            title: 'Espace Veille',
            screenKey: 'veille',
            onCollapseAll: () => ref.read(homeCardSettingsProvider.notifier).collapseAll(veilleKeys),
            onExpandAll: () => ref.read(homeCardSettingsProvider.notifier).expandAll(veilleKeys),
            extraActions: [
              TextButton.icon(
                onPressed: () => showHomeSourcesDialog(context, ref),
                icon: const Icon(Icons.rss_feed_rounded, color: EskoliaTokens.cyan, size: 16),
                label: const Text(
                  'Flux & Sources',
                  style: TextStyle(color: EskoliaTokens.cyan, fontSize: 11.5, fontWeight: FontWeight.w700),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: EskoliaTokens.cyan.withValues(alpha: 0.1),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: EskoliaTokens.cyan, width: 1.5),
                  ),
                ),
              ),
            ],
            availableCards: availableVeilleCards,
            maxColumns: 4,
          ),
          const SizedBox(height: 12),
          gridContent,
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
    if (key == 'add_source') {
      return SizedBox(
        width: width,
        child: child,
      );
    }

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
                final pinned = ref.read(veillePinnedCardsProvider);
                final isDragPinned = pinned.contains(dragKey);
                final isTargetPinned = pinned.contains(key);

                // Si déplacement vers une section différente, on bascule l'épinglage
                if (isDragPinned != isTargetPinned) {
                  ref.read(veillePinnedCardsProvider.notifier).togglePin(dragKey);
                }

                final order = ref.read(veilleCardsOrderProvider);
                final oldIdx = order.indexOf(dragKey);
                final newIdx = order.indexOf(key);
                if (oldIdx != -1 && newIdx != -1) {
                  ref.read(veilleCardsOrderProvider.notifier).reorder(oldIdx, newIdx);
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
}

class VeilleAddSourceCard extends ConsumerWidget {
  const VeilleAddSourceCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 140,
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => showHomeSourcesDialog(context, ref),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: EskoliaTokens.cyan.withValues(alpha: 0.3),
                width: 1.5,
                style: BorderStyle.solid,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  Positioned(
                    right: -20,
                    bottom: -20,
                    child: Icon(
                      Icons.add_circle_outline_rounded,
                      size: 100,
                      color: EskoliaTokens.cyan.withValues(alpha: 0.05),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: EskoliaTokens.cyan.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            color: EskoliaTokens.cyan,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Ajouter une source de veille',
                          style: GoogleFonts.outfit(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Flux RSS personnalisé ou catégorie IT',
                          style: GoogleFonts.outfit(
                            color: EskoliaTokens.textSecondary.withValues(alpha: 0.7),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
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
      ),
    );
  }
}
