import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../home/presentation/providers/home_providers.dart';

import '../../../core/theme/eskolia_layout.dart';
import '../../../core/theme/eskolia_visual.dart';
import '../../../core/time/xp_week_key.dart';
import '../../../core/widgets/bottom_nav.dart';
import '../../../data/repositories/leaderboard_repository.dart';
import '../data/models/daily_leaderboard_entry.dart';
import '../data/models/leaderboard_entry_model.dart';
import '../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../shared/widgets/eskolia_shell_body.dart';
import '../../../shared/widgets/eskolia_app_bar.dart';
import '../../../shared/widgets/gradient_border_card.dart';
import '../../../core/constants/eskolia_tokens.dart';

enum _BoardTab {
  weekXp,
  allXp,
  dailyQuiz,
  arenaWins,
  quizWins,
}

class _TabVisual {
  const _TabVisual({
    required this.tab,
    required this.emoji,
    required this.title,
    required this.pickerSubtitle,
    required this.headline,
    required this.accent,
    required this.borderColors,
  });

  final _BoardTab tab;
  final String emoji;
  final String title;
  final String pickerSubtitle;
  final String headline;
  final Color accent;
  final List<Color> borderColors;
}

const List<_TabVisual> _kTabVisuals = [
  _TabVisual(
    tab: _BoardTab.weekXp,
    emoji: '\u{1F4C5}',
    title: 'XP semaine',
    pickerSubtitle: 'Depuis lundi minuit',
    headline: 'XP de la semaine',
    accent: EskoliaVisual.neonGold,
    borderColors: [Color(0xFFFFE066), Color(0xFFB8860B)],
  ),
  _TabVisual(
    tab: _BoardTab.allXp,
    emoji: '\u{1F31F}',
    title: 'XP totale',
    pickerSubtitle: 'Tous les temps',
    headline: 'XP totale',
    accent: EskoliaVisual.neonViolet,
    borderColors: [Color(0xFF8B7CFF), Color(0xFFFF6584)],
  ),
  _TabVisual(
    tab: _BoardTab.dailyQuiz,
    emoji: '\u{1F319}',
    title: 'Quiz du jour',
    pickerSubtitle: 'Meilleur score du jour',
    headline: 'Quiz du jour',
    accent: EskoliaVisual.neonGreen,
    borderColors: EskoliaVisual.borderLive,
  ),
  _TabVisual(
    tab: _BoardTab.arenaWins,
    emoji: '\u{2694}\u{FE0F}',
    title: 'Duels',
    pickerSubtitle: 'Victoires multijoueur',
    headline: 'Duels remportés',
    accent: EskoliaVisual.neonCyan,
    borderColors: [EskoliaTokens.cyan, EskoliaTokens.cyan],
  ),
  _TabVisual(
    tab: _BoardTab.quizWins,
    emoji: '\u{2705}',
    title: 'Quiz réussis',
    pickerSubtitle: 'Parcours & solo',
    headline: 'Quiz réussis',
    accent: Color(0xFFA78BFA),
    borderColors: const [Color(0xFFC4B5FD), Color(0xFF7C3AED)],
  ),
];

_TabVisual _visualFor(_BoardTab t) =>
    _kTabVisuals.firstWhere((v) => v.tab == t);

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final _repo = LeaderboardRepository();
  _BoardTab _tab = _BoardTab.weekXp;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  String get _todayDayKey => calendarDayKeyYyyyMmDd(DateTime.now());

  String _dayKeyLabel(String key) {
    if (key.length != 8) return key;
    return '${key.substring(6, 8)}/${key.substring(4, 6)}/${key.substring(0, 4)}';
  }

  String _descriptionForTab() {
    switch (_tab) {
      case _BoardTab.weekXp:
        return 'Classement des joueurs les plus actifs cette semaine. Les compteurs '
            'reprennent chaque lundi — idéal pour une compétition fraîche.';
      case _BoardTab.allXp:
        return "Le gratin de l'expérience cumulée : tous les modes confondus, depuis la création du compte.";
      case _BoardTab.dailyQuiz:
        return 'Qui a le meilleur score sur le défi du ${ _dayKeyLabel(_todayDayKey) } ? '
            'Refais le quiz pour grappiller des places.';
      case _BoardTab.arenaWins:
        return 'Nombre de parties multijoueur gagnées (quiz ou Arena). '
            'Montre qui domine en duel.';
      case _BoardTab.quizWins:
        return 'Quiz terminés avec au moins 60 % de bonnes réponses — parcours, révision, lacunes… '
            '(hors simples duels).';
    }
  }

  int _metric(LeaderboardEntryModel e) {
    switch (_tab) {
      case _BoardTab.weekXp:
        return e.xpThisWeek;
      case _BoardTab.allXp:
        return e.xp;
      case _BoardTab.arenaWins:
        return e.battleWins;
      case _BoardTab.quizWins:
        return e.totalWins;
      case _BoardTab.dailyQuiz:
        return e.xp;
    }
  }

  String _metricUnit() {
    switch (_tab) {
      case _BoardTab.weekXp:
      case _BoardTab.allXp:
        return 'XP';
      case _BoardTab.arenaWins:
        return 'vic.';
      case _BoardTab.quizWins:
        return 'réussites';
      case _BoardTab.dailyQuiz:
        return 'XP';
    }
  }

  String _userListSubtitle(LeaderboardEntryModel e) {
    switch (_tab) {
      case _BoardTab.weekXp:
      case _BoardTab.allXp:
        return 'Niv. ${e.level} · ${e.streak}j de suite';
      case _BoardTab.arenaWins:
        return 'Niv. ${e.level} · ${e.xp} XP cumulés · ${e.streak}j';
      case _BoardTab.quizWins:
        return 'Niv. ${e.level} · ${e.xp} XP · ${e.streak}j';
      case _BoardTab.dailyQuiz:
        return '';
    }
  }

  String _trailingValue(LeaderboardEntryModel e) {
    final m = _metric(e);
    final u = _metricUnit();
    return '$m $u';
  }

  List<LeaderboardEntryModel?> _podiumTriplet(List<LeaderboardEntryModel> list) {
    if (list.isEmpty) return [null, null, null];
    if (list.length == 1) return [null, list[0], null];
    if (list.length == 2) return [list[1], list[0], null];
    return [list[1], list[0], list[2]];
  }

  List<DailyLeaderboardEntry?> _podiumTripletDaily(List<DailyLeaderboardEntry> list) {
    if (list.isEmpty) return [null, null, null];
    if (list.length == 1) return [null, list[0], null];
    if (list.length == 2) return [list[1], list[0], null];
    return [list[1], list[0], list[2]];
  }

  Stream<List<LeaderboardEntryModel>>? _userStream() {
    switch (_tab) {
      case _BoardTab.weekXp:
        return _repo.watchWeeklyTop(limit: 100);
      case _BoardTab.allXp:
        return _repo.watchTopUsers(limit: 100);
      case _BoardTab.arenaWins:
        return _repo.watchTopByUserField('battleWins', limit: 100);
      case _BoardTab.quizWins:
        return _repo.watchTopByUserField('totalWins', limit: 100);
      case _BoardTab.dailyQuiz:
        return null;
    }
  }

  Widget _buildError(Object err) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Impossible de charger le classement.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red.shade200),
            ),
            const SizedBox(height: 8),
            Text(
              '$err',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: EskoliaTokens.textSecondary.withValues(alpha: 0.85),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => setState(() {}),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHubHeader() {
    final v = _visualFor(_tab);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        EskoliaLayout.screenPaddingH,
        4,
        EskoliaLayout.screenPaddingH,
        12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 20, top: 8),
            child: Row(
              children: [
                const SizedBox(width: 48),
                Expanded(
                  child: Center(
                    child: Text(
                      '🏆 Classement',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                Consumer(
                  builder: (context, ref, child) {
                    final isPinned = ref.watch(homeCardsOrderProvider).contains('feature:leaderboard_mini');
                    return IconButton(
                      icon: Icon(
                        isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                        color: isPinned ? EskoliaTokens.cyan : Colors.white54,
                      ),
                      onPressed: () {
                        if (isPinned) {
                          ref.read(homeCardsOrderProvider.notifier).removeCard('feature:leaderboard_mini');
                        } else {
                          ref.read(homeCardsOrderProvider.notifier).addCard('feature:leaderboard_mini');
                        }
                      },
                      tooltip: isPinned ? 'Désépingler de l\'accueil' : 'Épingler à l\'accueil',
                    );
                  },
                ),
              ],
            ),
          ),
          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) => LinearGradient(
              colors: [v.accent, Colors.white],
            ).createShader(bounds),
            child: const Text(
              'Arène des champions',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Cinq classements distincts — XP, défi du jour, duels et régularité au quiz.',
            style: TextStyle(
              color: EskoliaTokens.textSecondary.withValues(alpha: 0.92),
              fontSize: 12,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModePickerGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: EskoliaLayout.screenPaddingH),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _ModePickerTile(visual: _kTabVisuals[0], selected: _tab == _kTabVisuals[0].tab, onTap: () => setState(() => _tab = _kTabVisuals[0].tab))),
              const SizedBox(width: 10),
              Expanded(child: _ModePickerTile(visual: _kTabVisuals[1], selected: _tab == _kTabVisuals[1].tab, onTap: () => setState(() => _tab = _kTabVisuals[1].tab))),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _ModePickerTile(visual: _kTabVisuals[2], selected: _tab == _kTabVisuals[2].tab, onTap: () => setState(() => _tab = _kTabVisuals[2].tab))),
              const SizedBox(width: 10),
              Expanded(child: _ModePickerTile(visual: _kTabVisuals[3], selected: _tab == _kTabVisuals[3].tab, onTap: () => setState(() => _tab = _kTabVisuals[3].tab))),
            ],
          ),
          const SizedBox(height: 10),
          _ModePickerTile(
            visual: _kTabVisuals[4],
            selected: _tab == _kTabVisuals[4].tab,
            onTap: () => setState(() => _tab = _kTabVisuals[4].tab),
            fullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _buildActiveBanner() {
    final v = _visualFor(_tab);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        EskoliaLayout.screenPaddingH,
        16,
        EskoliaLayout.screenPaddingH,
        8,
      ),
      child: GradientBorderCard(
        gradientColors: v.borderColors,
        glowColor: v.accent.withValues(alpha: 0.45),
        borderRadius: 20,
        innerBlurSigma: 14,
        innerColor: EskoliaTokens.bgBase,
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(v.emoji, style: const TextStyle(fontSize: 36)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    v.headline,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _descriptionForTab(),
                    style: TextStyle(
                      color: EskoliaTokens.textSecondary.withValues(alpha: 0.95),
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      backgroundColor: Colors.transparent,
      appBar: null,
      body: Stack(
        children: [
          const EskoliaAmbientBackground(),
          EskoliaShellBody(
            showBack: false,
            child: _tab == _BoardTab.dailyQuiz ? _buildDailyBody() : _buildUserBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyBody() {
    return StreamBuilder<List<DailyLeaderboardEntry>>(
      stream: _repo.watchDailyQuizScores(dayKey: _todayDayKey, limit: 100),
      builder: (context, snap) {
        if (snap.hasError) return _buildError(snap.error!);
        if (!snap.hasData) {
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHubHeader()),
              SliverToBoxAdapter(child: _buildModePickerGrid()),
              SliverToBoxAdapter(child: _buildActiveBanner()),
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator(color: EskoliaTokens.cyan)),
              ),
            ],
          );
        }
        final entries = snap.data!;
        if (entries.isEmpty) {
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHubHeader()),
              SliverToBoxAdapter(child: _buildModePickerGrid()),
              SliverToBoxAdapter(child: _buildActiveBanner()),
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('\u{1F319}', style: TextStyle(fontSize: 52)),
                        const SizedBox(height: 16),
                        const Text(
                          'Personne n\'a encore joué aujourd\'hui',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Lance le quiz du jour et décroche la première place !',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: EskoliaTokens.textSecondary.withValues(alpha: 0.85),
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }
        final podium = _podiumTripletDaily(entries);
        final rest = entries.length > 3 ? entries.sublist(3) : <DailyLeaderboardEntry>[];

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHubHeader()),
            SliverToBoxAdapter(child: _buildModePickerGrid()),
            SliverToBoxAdapter(child: _buildActiveBanner()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: EskoliaLayout.screenPaddingH),
                child: SizedBox(
                  height: 220,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: _DailyPodiumSlot(
                          entry: podium[0],
                          heightFrac: 0.72,
                          medal: '\u{1F948}',
                          rankNumber: '2',
                          accentColor: const Color(0xFFC0C0C0),
                          borderColors: const [Color(0xFFC0C0C0), EskoliaTokens.textSecondary],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _DailyPodiumSlot(
                          entry: podium[1],
                          heightFrac: 1.0,
                          medal: '\u{1F451}',
                          rankNumber: '1',
                          accentColor: EskoliaVisual.neonGold,
                          borderColors: EskoliaVisual.borderGold,
                          glow: EskoliaVisual.neonGold,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _DailyPodiumSlot(
                          entry: podium[2],
                          heightFrac: 0.65,
                          medal: '\u{1F949}',
                          rankNumber: '3',
                          accentColor: const Color(0xFFCD7F32),
                          borderColors: const [Color(0xFFCD7F32), Color(0xFF8B4513)],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                EskoliaLayout.screenPaddingH,
                20,
                EskoliaLayout.screenPaddingH,
                kEskoliaBottomNavReserve,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final e = rest[i];
                    final isSelf = _uid != null && e.uid == _uid;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _DailyListRow(entry: e, isSelf: isSelf),
                    )
                        .animate()
                        .fadeIn(duration: 240.ms, delay: (i * 40).ms)
                        .slideY(begin: 0.04, duration: 240.ms, delay: (i * 40).ms);
                  },
                  childCount: rest.length,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildUserBody() {
    final stream = _userStream();
    return StreamBuilder<List<LeaderboardEntryModel>>(
      stream: stream,
      builder: (context, snap) {
        if (snap.hasError) return _buildError(snap.error!);
        if (!snap.hasData) {
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHubHeader()),
              SliverToBoxAdapter(child: _buildModePickerGrid()),
              SliverToBoxAdapter(child: _buildActiveBanner()),
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator(color: EskoliaTokens.cyan)),
              ),
            ],
          );
        }
        final entries = snap.data!;
        if (entries.isEmpty) {
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHubHeader()),
              SliverToBoxAdapter(child: _buildModePickerGrid()),
              SliverToBoxAdapter(child: _buildActiveBanner()),
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('\u{1F3C6}', style: TextStyle(fontSize: 52)),
                        const SizedBox(height: 16),
                        const Text(
                          'Le classement est vide',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sois le premier à gagner de l\'XP\net à apparaître ici !',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: EskoliaTokens.textSecondary.withValues(alpha: 0.85),
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }
        final podium = _podiumTriplet(entries);
        final rest = entries.length > 3 ? entries.sublist(3) : <LeaderboardEntryModel>[];

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHubHeader()),
            SliverToBoxAdapter(child: _buildModePickerGrid()),
            SliverToBoxAdapter(child: _buildActiveBanner()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: EskoliaLayout.screenPaddingH),
                child: SizedBox(
                  height: 220,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: _PodiumSlot(
                          entry: podium[0],
                          metric: _metric,
                          metricUnit: _metricUnit(),
                          heightFrac: 0.72,
                          medal: '\u{1F948}',
                          rankNumber: '2',
                          accentColor: const Color(0xFFC0C0C0),
                          borderColors: const [Color(0xFFC0C0C0), EskoliaTokens.textSecondary],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _PodiumSlot(
                          entry: podium[1],
                          metric: _metric,
                          metricUnit: _metricUnit(),
                          heightFrac: 1.0,
                          medal: '\u{1F451}',
                          rankNumber: '1',
                          accentColor: EskoliaVisual.neonGold,
                          borderColors: EskoliaVisual.borderGold,
                          glow: EskoliaVisual.neonGold,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _PodiumSlot(
                          entry: podium[2],
                          metric: _metric,
                          metricUnit: _metricUnit(),
                          heightFrac: 0.65,
                          medal: '\u{1F949}',
                          rankNumber: '3',
                          accentColor: const Color(0xFFCD7F32),
                          borderColors: const [Color(0xFFCD7F32), Color(0xFF8B4513)],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                EskoliaLayout.screenPaddingH,
                20,
                EskoliaLayout.screenPaddingH,
                kEskoliaBottomNavReserve,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final e = rest[i];
                    final isSelf = _uid != null && e.uid == _uid;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _ListRow(
                        entry: e,
                        subtitleLine: _userListSubtitle(e),
                        trailingValue: _trailingValue(e),
                        isSelf: isSelf,
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 240.ms, delay: (i * 40).ms)
                        .slideY(begin: 0.04, duration: 240.ms, delay: (i * 40).ms);
                  },
                  childCount: rest.length,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ModePickerTile extends StatelessWidget {
  const _ModePickerTile({
    required this.visual,
    required this.selected,
    required this.onTap,
    this.fullWidth = false,
  });

  final _TabVisual visual;
  final bool selected;
  final VoidCallback onTap;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final child = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: selected
                  ? [
                      visual.accent.withValues(alpha: 0.22),
                      visual.accent.withValues(alpha: 0.06),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.07),
                      Colors.white.withValues(alpha: 0.02),
                    ],
            ),
            border: Border.all(
              width: selected ? 1.8 : 1,
              color: selected
                  ? visual.accent.withValues(alpha: 0.85)
                  : Colors.white.withValues(alpha: 0.1),
            ),
            boxShadow: selected
                ? EskoliaVisual.glow(visual.accent, blur: 18, alpha: 0.28)
                : null,
          ),
          child: Row(
            children: [
              Text(visual.emoji, style: const TextStyle(fontSize: 26)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      visual.title,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: selected ? 1 : 0.88),
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      visual.pickerSubtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: EskoliaTokens.textSecondary.withValues(alpha: selected ? 0.95 : 0.65),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                Icon(Icons.check_circle_rounded, color: visual.accent, size: 22),
            ],
          ),
        ),
      ),
    );
    return child;
  }
}

class _PodiumSlot extends StatelessWidget {
  const _PodiumSlot({
    required this.entry,
    required this.metric,
    required this.metricUnit,
    required this.heightFrac,
    required this.medal,
    required this.rankNumber,
    required this.accentColor,
    required this.borderColors,
    this.glow,
  });

  final LeaderboardEntryModel? entry;
  final int Function(LeaderboardEntryModel) metric;
  final String metricUnit;
  final double heightFrac;
  final String medal;
  final String rankNumber;
  final Color accentColor;
  final List<Color> borderColors;
  final Color? glow;

  @override
  Widget build(BuildContext context) {
    final e = entry;
    final name = e != null ? (e.username.isNotEmpty ? e.username : 'Joueur') : '—';
    final scoreStr = e != null ? '${metric(e)} $metricUnit' : '';

    return FractionallySizedBox(
      heightFactor: heightFrac,
      alignment: Alignment.bottomCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (e != null) ...[
            Text(medal, style: const TextStyle(fontSize: 24))
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .slideY(begin: 0, end: -0.15, duration: 1000.ms, curve: Curves.easeInOut),
            const SizedBox(height: 4),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: accentColor.withValues(alpha: 0.8),
                  width: rankNumber == '1' ? 3.0 : 2.0,
                ),
                boxShadow: glow != null
                    ? [
                        BoxShadow(
                          color: glow!.withValues(alpha: 0.35),
                          blurRadius: 12,
                          spreadRadius: 2,
                        )
                      ]
                    : null,
              ),
              child: CircleAvatar(
                radius: rankNumber == '1' ? 24 : 20,
                backgroundColor: Colors.white12,
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: rankNumber == '1' ? 16 : 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              scoreStr,
              style: GoogleFonts.outfit(
                color: accentColor.withValues(alpha: 0.9),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
          ] else ...[
            const Text('—', style: TextStyle(color: Colors.white24, fontSize: 16)),
            const SizedBox(height: 40),
          ],
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.08),
                    Colors.white.withValues(alpha: 0.01),
                  ],
                ),
                border: Border(
                  top: BorderSide(color: accentColor.withValues(alpha: 0.4), width: 1.5),
                  left: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
                  right: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
                ),
              ),
              child: Center(
                child: Text(
                  '#$rankNumber',
                  style: GoogleFonts.outfit(
                    color: accentColor.withValues(alpha: 0.6),
                    fontSize: rankNumber == '1' ? 36 : 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyPodiumSlot extends StatelessWidget {
  const _DailyPodiumSlot({
    required this.entry,
    required this.heightFrac,
    required this.medal,
    required this.rankNumber,
    required this.accentColor,
    required this.borderColors,
    this.glow,
  });

  final DailyLeaderboardEntry? entry;
  final double heightFrac;
  final String medal;
  final String rankNumber;
  final Color accentColor;
  final List<Color> borderColors;
  final Color? glow;

  @override
  Widget build(BuildContext context) {
    final e = entry;
    final name = e != null ? (e.username.isNotEmpty ? e.username : 'Joueur') : '—';
    final scoreStr = e != null ? '${e.score}/${e.total}' : '';

    return FractionallySizedBox(
      heightFactor: heightFrac,
      alignment: Alignment.bottomCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (e != null) ...[
            Text(medal, style: const TextStyle(fontSize: 24))
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .slideY(begin: 0, end: -0.15, duration: 1000.ms, curve: Curves.easeInOut),
            const SizedBox(height: 4),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: accentColor.withValues(alpha: 0.8),
                  width: rankNumber == '1' ? 3.0 : 2.0,
                ),
                boxShadow: glow != null
                    ? [
                        BoxShadow(
                          color: glow!.withValues(alpha: 0.35),
                          blurRadius: 12,
                          spreadRadius: 2,
                        )
                      ]
                    : null,
              ),
              child: CircleAvatar(
                radius: rankNumber == '1' ? 24 : 20,
                backgroundColor: Colors.white12,
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: rankNumber == '1' ? 16 : 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              scoreStr,
              style: GoogleFonts.outfit(
                color: accentColor.withValues(alpha: 0.9),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
          ] else ...[
            const Text('—', style: TextStyle(color: Colors.white24, fontSize: 16)),
            const SizedBox(height: 40),
          ],
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.08),
                    Colors.white.withValues(alpha: 0.01),
                  ],
                ),
                border: Border(
                  top: BorderSide(color: accentColor.withValues(alpha: 0.4), width: 1.5),
                  left: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
                  right: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
                ),
              ),
              child: Center(
                child: Text(
                  '#$rankNumber',
                  style: GoogleFonts.outfit(
                    color: accentColor.withValues(alpha: 0.6),
                    fontSize: rankNumber == '1' ? 36 : 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ListRow extends StatelessWidget {
  const _ListRow({
    required this.entry,
    required this.subtitleLine,
    required this.trailingValue,
    required this.isSelf,
  });

  final LeaderboardEntryModel entry;
  final String subtitleLine;
  final String trailingValue;
  final bool isSelf;

  @override
  Widget build(BuildContext context) {
    final name = entry.username.isNotEmpty ? entry.username : 'Joueur';
    return GradientBorderCard(
      gradientColors: isSelf
          ? const [EskoliaTokens.cyan, EskoliaTokens.violetSoft]
          : [
              Colors.white.withValues(alpha: 0.12),
              Colors.white.withValues(alpha: 0.04),
            ],
      glowColor: isSelf ? EskoliaTokens.cyan.withValues(alpha: 0.3) : null,
      borderRadius: 16,
      innerBlurSigma: 8,
      innerColor: isSelf ? Colors.white.withValues(alpha: 0.07) : EskoliaTokens.surface1,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isSelf
                  ? EskoliaTokens.cyan.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.06),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${entry.rank}',
                style: GoogleFonts.outfit(
                  color: isSelf ? EskoliaTokens.cyan : Colors.white70,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 18,
            backgroundColor: isSelf
                ? EskoliaTokens.violetSoft.withValues(alpha: 0.35)
                : Colors.white.withValues(alpha: 0.08),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isSelf ? '$name (Toi)' : name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                if (subtitleLine.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      subtitleLine,
                      style: GoogleFonts.plusJakartaSans(
                        color: EskoliaTokens.textSecondary.withValues(alpha: 0.8),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Text(
            trailingValue,
            style: GoogleFonts.outfit(
              color: isSelf ? EskoliaTokens.cyan : Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyListRow extends StatelessWidget {
  const _DailyListRow({
    required this.entry,
    required this.isSelf,
  });

  final DailyLeaderboardEntry entry;
  final bool isSelf;

  @override
  Widget build(BuildContext context) {
    final name = entry.username.isNotEmpty ? entry.username : 'Joueur';
    return GradientBorderCard(
      gradientColors: isSelf
          ? const [EskoliaTokens.cyan, EskoliaTokens.violetSoft]
          : [
              Colors.white.withValues(alpha: 0.12),
              Colors.white.withValues(alpha: 0.04),
            ],
      glowColor: isSelf ? EskoliaTokens.cyan.withValues(alpha: 0.3) : null,
      borderRadius: 16,
      innerBlurSigma: 8,
      innerColor: isSelf ? Colors.white.withValues(alpha: 0.07) : EskoliaTokens.surface1,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isSelf
                  ? EskoliaTokens.cyan.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.06),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${entry.rank}',
                style: GoogleFonts.outfit(
                  color: isSelf ? EskoliaTokens.cyan : Colors.white70,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 18,
            backgroundColor: isSelf
                ? EskoliaTokens.violetSoft.withValues(alpha: 0.35)
                : Colors.white.withValues(alpha: 0.08),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isSelf ? '$name (Toi)' : name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            '${entry.score}/${entry.total}',
            style: GoogleFonts.outfit(
              color: isSelf ? EskoliaTokens.cyan : Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
