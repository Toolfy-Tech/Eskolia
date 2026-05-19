import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../config/staff_bootstrap.dart';
import '../constants/colors.dart';
import '../router/quiz_play_session.dart';
import '../theme/app_theme_extensions.dart';
import '../../shared/widgets/eskolia_ambient_background.dart';
import 'eskolia_tips_banner.dart';

const Color _inactiveGray = Color(0xFF64748B);
const Color _cyanGlow = Color(0xFF22D3EE);

/// Espace à laisser sous le contenu du shell pour ne pas passer sous la pill.
/// Augmenté avec la barre redessinée (plus haute).
const double kEskoliaBottomNavReserve = 132;

class EskoliaBottomNav extends StatelessWidget {
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
  static const _NavItem _parcours = _NavItem(
    path: '/parcours',
    emoji: '\u{1F4DA}',
    label: 'Parcours',
  );
  static const _NavItem _solo = _NavItem(
    path: '/solo',
    emoji: '\u{1F3AF}',
    label: 'S\'entraîner',
  );
  static const _NavItem _multijoueur = _NavItem(
    path: '/lobbys',
    emoji: '\u{1F3AE}',
    label: 'Multi',
  );
  static const _NavItem _labo = _NavItem(
    path: '/labo',
    emoji: '\u{1F52C}',
    label: 'Labo',
  );
  static const _NavItem _profil = _NavItem(
    path: '/profil',
    emoji: '\u{1F464}',
    label: 'Moi',
  );
  static const _NavItem _admin = _NavItem(
    path: '/admin',
    emoji: '\u{1F6E1}\u{FE0F}',
    label: 'Admin',
  );

  /// Navigation principale : 6 destinations + Admin si privilégié.
  /// Accueil, S'entraîner, Parcours, Multi, Labo, Moi (+ Admin staff).
  static List<_NavItem> _itemsFor({required bool showAdminNav}) => [
        _accueil,
        _solo,
        _parcours,
        _multijoueur,
        _labo,
        _profil,
        if (showAdminNav) _admin,
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
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassmorphismTheme>();
    final neon = Theme.of(context).extension<NeonTheme>();

    final glassBorder =
        glass?.borderColor.withValues(alpha: 0.5) ?? Colors.white24;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      return _buildBar(
        context,
        items: _itemsFor(showAdminNav: false),
        glassBorder: glassBorder,
        neon: neon,
      );
    }

    return StreamBuilder<({bool showAdmin, bool aiConnected})>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .snapshots()
          .map((snap) {
            final data = snap.data();
            final role = (data?['role'] as String?)?.trim() ?? 'user';
            bool showAdmin = role == 'admin' || role == 'moderator';
            if (!showAdmin) {
              // Fallback bootstrap pour les comptes sans champ role défini.
              final uname = (data?['usernameLower'] as String?)?.trim() ??
                  (data?['username'] as String?)?.trim().toLowerCase() ??
                  '';
              showAdmin = kAdminNavPrivilegedUsernamesLower.contains(uname);
            }
            final aiConnected =
                ((data?['aiApiKey'] as String?) ?? '').isNotEmpty;
            return (showAdmin: showAdmin, aiConnected: aiConnected);
          })
          .distinct(),
      builder: (context, snap) {
        final showAdminNav = snap.data?.showAdmin ?? false;
        final aiConnected = snap.data?.aiConnected ?? false;
        final items = _itemsFor(showAdminNav: showAdminNav);
        return _buildBar(
          context,
          items: items,
          glassBorder: glassBorder,
          neon: neon,
          aiConnected: aiConnected,
        );
      },
    );
  }

  Widget _buildBar(
    BuildContext context, {
    required List<_NavItem> items,
    required Color glassBorder,
    required NeonTheme? neon,
    bool aiConnected = false,
  }) {
    final index = _indexForPath(currentPath, items);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
              child: Container(
                constraints: const BoxConstraints(minHeight: 72, maxHeight: 110),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF1E293B).withValues(alpha: 0.88),
                      const Color(0xFF0F172A).withValues(alpha: 0.94),
                      const Color(0xFF0B1020).withValues(alpha: 0.96),
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                  border: Border.all(
                    width: 1.5,
                    color: Color.lerp(
                          glassBorder,
                          primary.withValues(alpha: 0.75),
                          neon != null
                              ? 0.35 * neon.intensity.clamp(0.0, 1.2)
                              : 0.25,
                        ) ??
                        glassBorder,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primary.withValues(alpha: 0.32),
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
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(items.length, (i) {
                      final item = items[i];
                      final active = i == index;
                      return _NavCell(
                        key: ValueKey(item.path),
                        item: item,
                        active: active,
                        neon: neon,
                        showBadge: item.path == '/profil' && aiConnected,
                        onTap: () async {
                          final router = GoRouter.of(context);
                          final current =
                              GoRouterState.of(context).uri.path;
                          final target = item.path;
                          final normalizedCurrent = current == '/classement'
                              ? '/leaderboard'
                              : current;
                          final normalizedTarget = target == '/classement'
                              ? '/leaderboard'
                              : target;
                          if (normalizedCurrent != normalizedTarget &&
                              isQuizPlaySessionPath(normalizedCurrent)) {
                            final ok =
                                await confirmNavigateAwayFromQuiz(context);
                            if (!context.mounted || !ok) return;
                          }
                          if (!context.mounted) return;
                          router.go(target);
                        },
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final state = GoRouterState.of(context);
    final path = state.uri.path;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true,
      body: Column(
        children: [
          const EskoliaTipsBanner(),
          Expanded(
            child: Stack(
              children: [
                const EskoliaAmbientBackground(),
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      bottom: kEskoliaBottomNavReserve,
                    ),
                    child: child,
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: EskoliaBottomNav(currentPath: path),
                ),
              ],
            ),
          ),
        ],
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
  });

  final String path;
  final String emoji;
  final String label;
  // Chemin vers l'icône PNG custom (activé quand les assets DALL-E sont intégrés).
  final String? iconAsset;
}

class _NavCell extends StatelessWidget {
  const _NavCell({
    super.key,
    required this.item,
    required this.active,
    required this.neon,
    required this.onTap,
    this.showBadge = false,
  });

  final _NavItem item;
  final bool active;
  final NeonTheme? neon;
  final VoidCallback onTap;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    final color = active ? Colors.white : _inactiveGray;
    final intensity = neon?.intensity.clamp(0.0, 1.5) ?? 1.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(26),
          splashColor: primary.withValues(alpha: 0.18),
          highlightColor: primary.withValues(alpha: 0.08),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              gradient: active
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        primary.withValues(alpha: 0.42 * intensity),
                        primary.withValues(alpha: 0.18 * intensity),
                        const Color(0xFF312E81).withValues(alpha: 0.55),
                      ],
                    )
                  : null,
              border: Border.all(
                color: active
                    ? Color.lerp(
                          primary,
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
                        color: primary.withValues(alpha: 0.45 * intensity),
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
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Text(
                      item.emoji,
                      style: TextStyle(
                        fontSize: active ? 28 : 26,
                        height: 1,
                        shadows: active
                            ? [
                                Shadow(
                                  color: primary.withValues(alpha: 0.9),
                                  blurRadius: 14,
                                ),
                                Shadow(
                                  color: _cyanGlow.withValues(alpha: 0.45),
                                  blurRadius: 10,
                                ),
                              ]
                            : null,
                      ),
                    ),
                    if (showBadge)
                      Positioned(
                        top: -2,
                        right: -4,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF0F172A),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                  ],
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
