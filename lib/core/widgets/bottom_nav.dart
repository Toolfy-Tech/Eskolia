import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/eskolia_tokens.dart';
import '../router/quiz_play_session.dart';
import '../theme/app_theme_extensions.dart';
import '../theme/theme_palette_provider.dart';
import '../../features/podcasts/data/podcast_player_service.dart';
import '../../features/podcasts/presentation/podcast_mini_player.dart';
import '../../shared/widgets/eskolia_ambient_background.dart';
import 'eskolia_tips_banner.dart';
import '../../features/home/data/home_repository.dart';
import '../../features/auth/data/user_model.dart';
import '../utils/eskolia_icons.dart';
import '../../features/ai/data/ai_key_repository.dart';

const Color _inactiveGray = EskoliaTokens.textDisabled;
const Color _cyanGlow = EskoliaTokens.cyan;

/// Espace à laisser sous le contenu du shell pour ne pas passer sous la pill sur mobile.
const double kEskoliaBottomNavReserve = 132;

// Providers de gestion de la Sidebar
class SidebarCollapsedNotifier extends Notifier<bool> {
  @override
  bool build() => true; // Collapsé par défaut pour maximiser l'espace de contenu

  void toggle() => state = !state;
  void setCollapsed(bool value) => state = value;
}

final sidebarCollapsedProvider = NotifierProvider.autoDispose<SidebarCollapsedNotifier, bool>(SidebarCollapsedNotifier.new);

class SidebarOrderNotifier extends Notifier<List<String>> {
  static const String _prefKey = 'eskolia_sidebar_order_v2';
  
  static const List<String> _defaultOrder = [
    '/home',
    '/veille',
    '/parcours',
    '/exams',
    '/solo',
    '/tp',
    '/lobbys',
    '/ai/setup',
    '/notebook',
    '/docs',
    '/leaderboard',
    '/achievements',
    '/labo',
    '/settings',
    '/admin',
  ];

  @override
  List<String> build() {
    _loadFromPrefs();
    return _defaultOrder;
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_prefKey);
      if (list != null && list.isNotEmpty) {
        final Set<String> current = list.toSet();
        final List<String> merged = List<String>.from(list);
        for (final item in _defaultOrder) {
          if (!current.contains(item)) {
            merged.add(item);
          }
        }
        state = merged;
      }
    } catch (e) {
      debugPrint('Error loading sidebar order: $e');
    }
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    var index = newIndex;
    if (oldIndex < index) {
      index -= 1;
    }
    final List<String> list = List<String>.from(state);
    final String item = list.removeAt(oldIndex);
    list.insert(index, item);
    state = list;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_prefKey, list);
    } catch (e) {
      debugPrint('Error saving sidebar order: $e');
    }
  }
}

final sidebarOrderProvider = NotifierProvider<SidebarOrderNotifier, List<String>>(SidebarOrderNotifier.new);

final currentUserStreamProvider = StreamProvider<UserModel?>((ref) {
  return HomeRepository().watchCurrentUser();
});

final aiConnectionStateProvider = StreamProvider<AiConnectionState>((ref) {
  return AiKeyRepository().watch();
});

class EskoliaBottomNav extends ConsumerWidget {
  const EskoliaBottomNav({
    super.key,
    required this.currentPath,
  });

  final String currentPath;

  static const _NavItem _accueil = _NavItem(
    path: '/home',
    emoji: '\u{1F3E0}',
    label: 'Accueil',
  );
  static const _NavItem _veille = _NavItem(
    path: '/veille',
    emoji: '📡',
    label: 'Veille',
  );
  static const _NavItem _parcours = _NavItem(
    path: '/parcours',
    emoji: '\u{1F4DA}',
    label: 'Parcours',
  );
  static const _NavItem _exams = _NavItem(
    path: '/exams',
    emoji: '🎓',
    label: 'Examens Blancs',
    customColor: Color(0xFFFFB300),
  );
  static const _NavItem _solo = _NavItem(
    path: '/solo',
    emoji: '\u{1F3AF}',
    label: 'Solo',
  );
  static const _NavItem _tp = _NavItem(
    path: '/tp',
    emoji: '\u{1F6E0}\u{FE0F}', // 🛠️
    label: 'TP',
  );
  static const _NavItem _multijoueur = _NavItem(
    path: '/lobbys',
    emoji: '\u{1F3AE}',
    label: 'Lobbys',
  );
  static const _NavItem _ai = _NavItem(
    path: '/ai/setup',
    emoji: '🧠',
    label: 'Mon IA',
  );
  static const _NavItem _notebook = _NavItem(
    path: '/notebook',
    emoji: '📝',
    label: 'Mon Bloc-notes',
  );
  static const _NavItem _docs = _NavItem(
    path: '/docs',
    emoji: '📖',
    label: 'Documentation',
  );
  static const _NavItem _leaderboard = _NavItem(
    path: '/leaderboard',
    emoji: '🏆',
    label: 'Classement',
  );
  static const _NavItem _achievements = _NavItem(
    path: '/achievements',
    emoji: '🎖️',
    label: 'Hauts faits',
  );
  static const _NavItem _labo = _NavItem(
    path: '/labo',
    emoji: '🧪',
    label: 'Le Labo',
  );
  static const _NavItem _settings = _NavItem(
    path: '/settings',
    emoji: '⚙️',
    label: 'Réglages',
  );
  static const _NavItem _admin = _NavItem(
    path: '/admin',
    emoji: '🛡️',
    label: 'Administration',
  );


  static const _NavItem _menu = _NavItem(
    path: '#menu',
    emoji: '☰',
    label: 'Menu',
  );

  static List<_NavItem> _itemsFor() => [
        _accueil,
        _parcours,
        _exams,
        _solo,
        _menu,
      ];

  static int _indexForPath(String path, List<_NavItem> items) {
    final normalized = path == '/classement' ? '/leaderboard' : path;
    for (var i = 0; i < items.length; i++) {
      if (normalized == items[i].path ||
          normalized.startsWith('${items[i].path}/')) {
        return i;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final glass = Theme.of(context).extension<GlassmorphismTheme>();
    final neon = Theme.of(context).extension<NeonTheme>();

    final glassBorder =
        glass?.borderColor.withValues(alpha: 0.5) ?? Colors.white24;

    return _buildBar(
      context,
      ref,
      items: _itemsFor(),
      glassBorder: glassBorder,
      neon: neon,
    );
  }

  Widget _buildBar(
    BuildContext context,
    WidgetRef ref, {
    required List<_NavItem> items,
    required Color glassBorder,
    required NeonTheme? neon,
  }) {
    final index = _indexForPath(currentPath, items);

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
            child: Container(
              constraints: const BoxConstraints(
                minHeight: 72,
                maxHeight: 110,
                maxWidth: 540,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    EskoliaTokens.surface2.withValues(alpha: 0.55),
                    EskoliaTokens.surface1.withValues(alpha: 0.65),
                    EskoliaTokens.bgBase.withValues(alpha: 0.70),
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
                border: Border.all(
                  width: 1.5,
                  color: Color.lerp(
                        glassBorder,
                        EskoliaTokens.violet.withValues(alpha: 0.75),
                        neon != null
                            ? 0.35 * neon.intensity.clamp(0.0, 1.2)
                            : 0.25,
                      ) ??
                      glassBorder,
                ),
                boxShadow: [
                  BoxShadow(
                    color: EskoliaTokens.violet.withValues(alpha: 0.32),
                    blurRadius: 28,
                    spreadRadius: -8,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: _cyanGlow.withValues(alpha: 0.12),
                    blurRadius: 22,
                    spreadRadius: -6,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.55),
                    blurRadius: 24,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(items.length, (i) {
                  final item = items[i];
                  final active = i == index;
                  return _NavCell(
                    key: ValueKey(item.path),
                    item: item,
                    active: active,
                    neon: neon,
                    onTap: () async {
                      final target = item.path;
                      if (target == '#menu') {
                        ref.read(mobileDrawerOpenProvider.notifier).open();
                        return;
                      }
                      final router = GoRouter.of(context);
                      final current = GoRouterState.of(context).uri.path;
                      final normalizedCurrent = current == '/classement'
                          ? '/leaderboard'
                          : current;
                      final normalizedTarget = target == '/classement'
                          ? '/leaderboard'
                          : target;
                      if (normalizedCurrent != normalizedTarget &&
                          isQuizPlaySessionPath(normalizedCurrent)) {
                        final ok = await confirmNavigateAwayFromQuiz(context);
                        if (!context.mounted || !ok) return;
                      }
                      if (!context.mounted) return;
                      if (target == '/ai/setup') {
                        router.push(target);
                      } else {
                        router.go(target);
                      }
                    },
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MobileDrawerOpenNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void open() => state = true;
  void close() => state = false;
  void toggle() => state = !state;
}

final mobileDrawerOpenProvider = NotifierProvider.autoDispose<MobileDrawerOpenNotifier, bool>(MobileDrawerOpenNotifier.new);

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  static const double _miniPlayerHeight = 72;
  static const double _miniPlayerBottomGap = 8;

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final width = MediaQuery.sizeOf(context).width;
    final isDesktopOrTablet = width >= 700;

    final hasPodcast = ref.watch(
      podcastPlayerProvider.select((s) => s.podcast != null),
    );

    final double miniPlayerReserve = hasPodcast
        ? _miniPlayerHeight + _miniPlayerBottomGap
        : 0;

    if (isDesktopOrTablet) {
      // Layout Desktop & Tablette avec Sidebar latérale
      return Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            const EskoliaAmbientBackground(),
            Positioned.fill(
              child: Row(
                children: [
                  const EskoliaSidebar(),
                  Expanded(
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Padding(
                            padding: EdgeInsets.only(
                              top: topPad + kTipsBannerHeight,
                              bottom: miniPlayerReserve,
                            ),
                            child: widget.child,
                          ),
                        ),
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: const EskoliaTipsBanner(),
                        ),
                        if (hasPodcast)
                          Positioned(
                            left: 14,
                            right: 20,
                            bottom: 20,
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 440),
                                child: const PodcastMiniPlayer(),
                              ),
                            ),
                          ),
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

    // Layout Mobile (Smartphones < 700px) : Pleine largeur d'écran + Barre de navigation inférieure
    final isDrawerOpen = ref.watch(mobileDrawerOpenProvider);
    final routerPath = GoRouterState.of(context).uri.path;
    final bottomNavReserve = 86.0 + bottomInset + miniPlayerReserve;

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          const EskoliaAmbientBackground(),
          
          // Contenu principal plein écran sur smartphone
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(
                top: topPad + kTipsBannerHeight,
                bottom: bottomNavReserve,
              ),
              child: widget.child,
            ),
          ),
          
          // Tips Banner
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: const EskoliaTipsBanner(),
          ),

          // Podcast Mini Player au-dessus de la barre de navigation
          if (hasPodcast)
            Positioned(
              left: 16,
              right: 16,
              bottom: 84 + bottomInset,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: const PodcastMiniPlayer(),
                ),
              ),
            ),

          // Barre de navigation inférieure flottante Eskolia
          Positioned(
            left: 0,
            right: 0,
            bottom: 10 + bottomInset,
            child: EskoliaBottomNav(currentPath: routerPath),
          ),

          // Filtre d'assombrissement (scrim) quand le menu modal est ouvert
          if (isDrawerOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  ref.read(mobileDrawerOpenProvider.notifier).close();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 240),
                  color: Colors.black.withValues(alpha: 0.65),
                ),
              ),
            ),

          // Tiroir de menu latéral coulissant pour mobile
          AnimatedPositioned(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeInOut,
            left: isDrawerOpen ? 0 : -290,
            top: 0,
            bottom: 0,
            width: 280,
            child: EskoliaSidebar(
              onNavItemTapped: () {
                ref.read(mobileDrawerOpenProvider.notifier).close();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class EskoliaSidebar extends ConsumerWidget {
  const EskoliaSidebar({
    super.key,
    this.onNavItemTapped,
  });

  final VoidCallback? onNavItemTapped;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktopOrTablet = screenWidth >= 700;
    final collapsed = isDesktopOrTablet ? ref.watch(sidebarCollapsedProvider) : false;
    final width = isDesktopOrTablet ? (collapsed ? 72.0 : 250.0) : 280.0;
    final routerState = GoRouterState.of(context);
    final path = routerState.uri.path;

    final userAsyncValue = ref.watch(currentUserStreamProvider);
    final isStaff = userAsyncValue.value?.isStaff ?? false;

    final orderedPaths = ref.watch(sidebarOrderProvider);

    final allItemsMap = {
      '/home': EskoliaBottomNav._accueil,
      '/veille': EskoliaBottomNav._veille,
      '/parcours': EskoliaBottomNav._parcours,
      '/exams': EskoliaBottomNav._exams,
      '/solo': EskoliaBottomNav._solo,
      '/tp': EskoliaBottomNav._tp,
      '/lobbys': EskoliaBottomNav._multijoueur,
      '/ai/setup': EskoliaBottomNav._ai,
      '/notebook': EskoliaBottomNav._notebook,
      '/docs': EskoliaBottomNav._docs,
      '/leaderboard': EskoliaBottomNav._leaderboard,
      '/achievements': EskoliaBottomNav._achievements,
      '/labo': EskoliaBottomNav._labo,
      '/settings': EskoliaBottomNav._settings,
      '/admin': EskoliaBottomNav._admin,
    };

    final List<_NavItem> items = [];
    for (final p in orderedPaths) {
      if (p == '/admin' && !isStaff) continue;
      final item = allItemsMap[p];
      if (item != null) {
        items.add(item);
      }
    }

    int currentIndex = -1;
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      if (path == item.path || path.startsWith('${item.path}/')) {
        currentIndex = i;
        break;
      }
    }

    final palette = ref.watch(themePaletteProvider);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      width: width,
      height: double.infinity,
      decoration: BoxDecoration(
        color: palette.sidebarBg.withValues(alpha: 0.96),
        border: Border(
          right: BorderSide(
            color: palette.sidebarBorder,
            width: 1.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(4, 0),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: collapsed
                  ? Center(
                      child: Icon(
                        Icons.school_rounded,
                        color: palette.primaryAccent,
                        size: 28,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.school_rounded,
                              color: palette.primaryAccent,
                              size: 28,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Eskolia',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 20,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.notifications_none_rounded,
                                color: Colors.white70,
                                size: 22,
                              ),
                              tooltip: 'Notifications',
                              onPressed: () {
                                if (onNavItemTapped != null) onNavItemTapped!();
                                context.push('/notifications');
                              },
                            ),
                            if (!isDesktopOrTablet)
                              IconButton(
                                icon: const Icon(
                                  Icons.close_rounded,
                                  color: Colors.white70,
                                  size: 22,
                                ),
                                tooltip: 'Fermer',
                                onPressed: onNavItemTapped,
                              ),
                          ],
                        ),
                      ],
                    ),
            ),
            const Divider(color: Colors.white12, height: 1),
            const SizedBox(height: 12),
            // Navigation
            Expanded(
              child: ReorderableListView.builder(
                buildDefaultDragHandles: false,
                itemCount: items.length,
                onReorder: (oldIndex, newIndex) {
                  ref.read(sidebarOrderProvider.notifier).reorder(oldIndex, newIndex);
                },
                itemBuilder: (context, index) {
                  final item = items[index];
                  final active = index == currentIndex;
                  return ReorderableDragStartListener(
                    key: ValueKey(item.path),
                    index: index,
                    child: _SidebarCell(
                      item: item,
                      active: active,
                      collapsed: collapsed,
                      onTap: () async {
                        if (onNavItemTapped != null) onNavItemTapped!();

                        final screenWidth = MediaQuery.sizeOf(context).width;
                        if (screenWidth <= 800) {
                          ref.read(sidebarCollapsedProvider.notifier).setCollapsed(true);
                        }

                        final router = GoRouter.of(context);
                        final current = GoRouterState.of(context).uri.path;
                        final target = item.path;
                        final normalizedCurrent =
                            current == '/classement' ? '/leaderboard' : current;
                        final normalizedTarget =
                            target == '/classement' ? '/leaderboard' : target;

                        if (normalizedCurrent != normalizedTarget &&
                            isQuizPlaySessionPath(normalizedCurrent)) {
                          final ok = await confirmNavigateAwayFromQuiz(context);
                          if (!context.mounted || !ok) return;
                        }

                        if (!context.mounted) return;
                        if (target == '/ai/setup') {
                          router.push(target);
                        } else {
                          router.go(target);
                        }
                      },
                    ),
                  );
                },
              ),
            ),
            // Collapse Button
            const Divider(color: Colors.white10, height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: Align(
                alignment: Alignment.center,
                child: IconButton(
                  icon: Icon(
                    collapsed ? Icons.chevron_right_rounded : Icons.chevron_left_rounded,
                    color: EskoliaTokens.cyan.withValues(alpha: 0.7),
                  ),
                  onPressed: () {
                    ref.read(sidebarCollapsedProvider.notifier).toggle();
                  },
                ),
              ),
            ),
            // Sélecteur de Thème de Couleurs
            if (collapsed)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Center(
                  child: PopupMenuButton<EskoliaThemeId>(
                    tooltip: 'Changer d\'ambiance (${ref.watch(themePaletteProvider).label})',
                    padding: EdgeInsets.zero,
                    color: EskoliaTokens.surface1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
                    ),
                    icon: Icon(
                      Icons.palette_outlined,
                      color: ref.watch(themePaletteProvider).primaryAccent,
                      size: 20,
                    ),
                    onSelected: (theme) => ref.read(themePaletteProvider.notifier).setTheme(theme),
                    itemBuilder: (ctx) => EskoliaThemeId.values.map((theme) {
                      final isSelected = ref.watch(themePaletteProvider).themeId == theme;
                      return PopupMenuItem(
                        value: theme,
                        child: Row(
                          children: [
                            Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: theme.accentColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              theme.label,
                              style: TextStyle(
                                color: isSelected ? theme.accentColor : Colors.white,
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.palette_outlined, size: 14, color: ref.watch(themePaletteProvider).primaryAccent),
                          const SizedBox(width: 6),
                          const Text(
                            'AMBIANCE',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: EskoliaThemeId.values.map((theme) {
                          final isSelected = ref.watch(themePaletteProvider).themeId == theme;
                          return Tooltip(
                            message: theme.label,
                            child: InkWell(
                              onTap: () => ref.read(themePaletteProvider.notifier).setTheme(theme),
                              borderRadius: BorderRadius.circular(20),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  color: theme.accentColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected ? Colors.white : Colors.transparent,
                                    width: 2.5,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: theme.accentColor.withValues(alpha: 0.6),
                                            blurRadius: 10,
                                            spreadRadius: 1,
                                          ),
                                        ]
                                      : [],
                                ),
                                child: isSelected
                                    ? const Center(
                                        child: Icon(Icons.check, size: 13, color: Colors.black),
                                      )
                                    : null,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            const Divider(color: Colors.white12, height: 1),
            // Profil Utilisateur
            userAsyncValue.when(
              data: (user) {
                if (user == null) return const SizedBox.shrink();
                final initial = user.username.isNotEmpty
                    ? user.username.substring(0, 1).toUpperCase()
                    : 'U';
                return Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: InkWell(
                    onTap: () {
                      final screenWidth = MediaQuery.sizeOf(context).width;
                      if (screenWidth <= 800) {
                        ref.read(sidebarCollapsedProvider.notifier).setCollapsed(true);
                      }
                      context.push('/profil/${user.uid}');
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                      child: collapsed
                          ? Center(
                              child: Tooltip(
                                message: '${user.username} (${user.streak} J)',
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: palette.primaryAccent.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: palette.primaryAccent.withValues(alpha: 0.5),
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    initial,
                                    style: TextStyle(
                                      color: palette.primaryAccent,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: palette.primaryAccent.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: palette.primaryAccent.withValues(alpha: 0.5),
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    initial,
                                    style: TextStyle(
                                      color: palette.primaryAccent,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  user.username,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.local_fire_department_rounded,
                                      color: EskoliaTokens.orange,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${user.streak} jours',
                                      style: const TextStyle(
                                        color: EskoliaTokens.orange,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                    ),
                  ),
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: EskoliaTokens.cyan,
                    ),
                  ),
                ),
              ),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarCell extends ConsumerStatefulWidget {
  const _SidebarCell({
    required this.item,
    required this.active,
    required this.collapsed,
    required this.onTap,
  });

  final _NavItem item;
  final bool active;
  final bool collapsed;
  final VoidCallback onTap;

  @override
  ConsumerState<_SidebarCell> createState() => _SidebarCellState();
}

class _SidebarCellState extends ConsumerState<_SidebarCell> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final palette = ref.watch(themePaletteProvider);
    final itemCustomColor = widget.item.customColor;
    final activeColor = itemCustomColor ?? palette.primaryAccent;
    final hoverColor = (itemCustomColor ?? palette.primaryAccent).withValues(alpha: 0.14);
    final borderColor = widget.active
        ? activeColor
        : (itemCustomColor != null
            ? itemCustomColor.withValues(alpha: 0.3)
            : (_isHovered ? activeColor.withValues(alpha: 0.4) : Colors.transparent));

    final isAiPath = widget.item.path == '/ai/setup';
    Color? customIconColor;
    if (isAiPath) {
      final aiStateAsync = ref.watch(aiConnectionStateProvider);
      final isAiActive = aiStateAsync.value?.isConnected ?? false;
      customIconColor = isAiActive ? EskoliaTokens.success : EskoliaTokens.error;
    }

    final displayIconColor = customIconColor ?? (widget.active ? activeColor : (itemCustomColor ?? Colors.white70));

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(
              horizontal: widget.collapsed ? 0 : 12,
              vertical: 12,
            ),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: widget.active
                  ? activeColor.withValues(alpha: 0.08)
                  : (_isHovered ? hoverColor : Colors.transparent),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 1.0),
              boxShadow: widget.active
                  ? [
                      BoxShadow(
                        color: activeColor.withValues(alpha: 0.15),
                        blurRadius: 10,
                        spreadRadius: -2,
                      ),
                    ]
                  : (itemCustomColor != null
                      ? [
                          BoxShadow(
                            color: itemCustomColor.withValues(alpha: 0.08),
                            blurRadius: 6,
                          ),
                        ]
                      : null),
            ),
            child: widget.collapsed
                ? Tooltip(
                    message: widget.item.label,
                    child: Icon(
                      getIconDataForEmoji(widget.item.emoji),
                      size: 22,
                      color: displayIconColor,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        getIconDataForEmoji(widget.item.emoji),
                        size: 20,
                        color: displayIconColor,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        widget.item.label,
                        style: TextStyle(
                          color: itemCustomColor != null
                              ? (widget.active ? itemCustomColor : itemCustomColor.withValues(alpha: 0.9))
                              : Colors.white.withValues(alpha: widget.active ? 1.0 : 0.7),
                          fontWeight: (widget.active || itemCustomColor != null) ? FontWeight.bold : FontWeight.normal,
                          fontSize: 14.5,
                          fontFamily: 'Outfit',
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.path,
    required this.emoji,
    required this.label,
    // ignore: unused_element_parameter
    this.iconAsset,
    this.customColor,
  });

  final String path;
  final String emoji;
  final String label;
  final String? iconAsset;
  final Color? customColor;
}

class _NavCell extends StatelessWidget {
  const _NavCell({
    super.key,
    required this.item,
    required this.active,
    required this.neon,
    required this.onTap,
  });

  final _NavItem item;
  final bool active;
  final NeonTheme? neon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? EskoliaTokens.textPrimary : _inactiveGray;
    final intensity = neon?.intensity.clamp(0.0, 1.5) ?? 1.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(26),
          splashColor: EskoliaTokens.violet.withValues(alpha: 0.18),
          highlightColor: EskoliaTokens.violet.withValues(alpha: 0.08),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              gradient: active
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        EskoliaTokens.violet.withValues(alpha: 0.42 * intensity),
                        EskoliaTokens.violet.withValues(alpha: 0.18 * intensity),
                        EskoliaTokens.surface3.withValues(alpha: 0.55),
                      ],
                    )
                  : null,
              border: Border.all(
                color: active
                    ? Color.lerp(
                          EskoliaTokens.violet,
                          _cyanGlow,
                          0.35,
                        )!
                        .withValues(alpha: 0.65)
                    : Colors.transparent,
                width: active ? 1.5 : 1,
              ),
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: EskoliaTokens.violet.withValues(alpha: 0.45 * intensity),
                        blurRadius: 18,
                        spreadRadius: -2,
                      ),
                      BoxShadow(
                        color: _cyanGlow.withValues(alpha: 0.2 * intensity),
                        blurRadius: 14,
                        spreadRadius: -4,
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  getIconDataForEmoji(item.emoji),
                  size: active ? 26 : 24,
                  color: color,
                ),
                const SizedBox(height: 6),
                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: active ? 11.5 : 10.5,
                    fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                    letterSpacing: active ? 0.2 : 0,
                    color: color,
                  ),
                ),
                const SizedBox(height: 5),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 240),
                  width: active ? 26 : 0,
                  height: 3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: active ? _cyanGlow : Colors.transparent,
                    boxShadow: active
                        ? [
                            BoxShadow(
                              color: _cyanGlow.withValues(alpha: 0.85),
                              blurRadius: 8,
                            ),
                          ]
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
