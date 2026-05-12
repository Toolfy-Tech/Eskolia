import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/preferences/onboarding_prefs.dart';
import '../../../core/utils/eskolia_snackbar.dart';
import '../../../core/theme/eskolia_layout.dart';
import '../../../core/theme/eskolia_visual.dart';
import '../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../shared/widgets/eskolia_button.dart';
import '../../../shared/widgets/gradient_border_card.dart';
import '../../../shared/widgets/user_status_pill.dart';
import '../../auth/data/user_model.dart';
import '../../economy/data/achievement_triggers.dart';
import '../../parcours/data/parcours_repository.dart';
import '../data/daily_quests_repository.dart';
import '../data/home_repository.dart';
import 'widgets/tech_news_section.dart';

const Color _cyan = Color(0xFF00BCD4);
const Color _slateLight = Color(0xFF94A3B8);
const Color _violetBrand = Color(0xFF6C63FF);
const Color _surfaceBar = Color(0xFF1E293B);
const Color _redStreak = Color(0xFFEF4444);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeRepository _repo = HomeRepository();
  final DailyQuestsRepository _questsRepo = DailyQuestsRepository();

  UserModel? _user;
  DailyQuestsSnapshot? _quests;
  bool _isLoading = true;
  String? _errorMessage;
  final List<bool> _sectionVisible = List.filled(2, false);

  StreamSubscription<UserModel?>? _userSub;
  bool _questsLoaded = false;

  @override
  void initState() {
    super.initState();
    _subscribeToUser();
    WidgetsBinding.instance.addPostFrameCallback((_) => _guardOnboarding());
  }

  @override
  void dispose() {
    _userSub?.cancel();
    super.dispose();
  }

  Future<void> _guardOnboarding() async {
    final done = await OnboardingPrefs.isCompleted();
    if (!mounted || done) return;
    context.go('/onboarding');
  }

  // Retry entry point — cancels any stale sub before re-subscribing.
  Future<void> _loadData() async {
    _userSub?.cancel();
    _questsLoaded = false;
    _subscribeToUser();
  }

  void _subscribeToUser() {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    _userSub = _repo.watchCurrentUser().listen(
      (user) async {
        if (!mounted) return;

        if (user == null) {
          setState(() => _isLoading = false);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) context.go('/login');
          });
          return;
        }

        // Subsequent emissions: username/XP updates — refresh UI without re-loading quests.
        if (_questsLoaded) {
          setState(() => _user = user);
          return;
        }

        // First emission: load quests + achievements.
        try {
          await AchievementTriggers(
            onUnlocked: (emoji, title) {
              if (mounted) showAchievementSnackBar(context, emoji, title);
            },
          ).syncFromUserSnapshot(user);
          await _questsRepo.ensureToday();
          final quests = await _questsRepo.snapshot();
          if (!mounted) return;
          _questsLoaded = true;
          setState(() {
            _user = user;
            _quests = quests;
            _isLoading = false;
          });
          _triggerSectionAnimations();
          _maybeShowStreakBanner(user.streak);
        } catch (e) {
          if (!mounted) return;
          setState(() {
            _errorMessage = e.toString();
            _isLoading = false;
          });
        }
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

  Future<void> _maybeShowStreakBanner(int streak) async {
    if (streak <= 0) return;
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final key = 'streak_banner_${now.year}_${now.month}_${now.day}';
    if (prefs.getBool(key) == true) return;
    await prefs.setBool(key, true);
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) showStreakBanner(context, streak);
    });
  }

  void _triggerSectionAnimations() {
    for (var i = 0; i < 2; i++) {
      Future.delayed(Duration(milliseconds: i * 80), () {
        if (!mounted) return;
        setState(() => _sectionVisible[i] = true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EskoliaVisual.bgDeep,
      body: Stack(
        children: [
          const EskoliaAmbientBackground(),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: EskoliaLayout.shellContentMaxWidth,
                ),
                child: _isLoading
                    ? _buildSkeleton()
                    : _errorMessage != null
                        ? _buildError(context)
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
          // Top actions
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _skeletonBox(36, 36, radius: 18),
              const SizedBox(width: 8),
              _skeletonBox(36, 36, radius: 18),
            ],
          ),
          const SizedBox(height: 12),
          // Greeting
          _skeletonBox(16, 200, radius: 8),
          const SizedBox(height: 20),
          // UserStatusPill
          _skeletonBox(72, double.infinity, radius: 28),
          const SizedBox(height: 24),
          // Quests header
          _skeletonBox(11, 120, radius: 6),
          const SizedBox(height: 12),
          _skeletonBox(64, double.infinity, radius: 14),
          const SizedBox(height: 8),
          _skeletonBox(64, double.infinity, radius: 14),
          const SizedBox(height: 8),
          _skeletonBox(64, double.infinity, radius: 14),
          const SizedBox(height: 24),
          // Hero card
          _skeletonBox(110, double.infinity, radius: 20),
          const SizedBox(height: 24),
          // Quick access
          Row(
            children: [
              Expanded(child: _skeletonBox(56, double.infinity, radius: 14)),
              const SizedBox(width: 10),
              Expanded(child: _skeletonBox(56, double.infinity, radius: 14)),
              const SizedBox(width: 10),
              Expanded(child: _skeletonBox(56, double.infinity, radius: 14)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _skeletonBox(double height, double width, {double radius = 8}) {
    return Container(
      height: height,
      width: width == double.infinity ? null : width,
      decoration: BoxDecoration(
        color: _surfaceBar,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: _redStreak, size: 48),
          Text(_errorMessage ?? 'Erreur'),
          EskoliaButton(label: 'Réessayer', onPressed: _loadData),
        ],
      ),
    );
  }

  Widget _buildMain(BuildContext context) {
    final user = _user!;

    return StreamBuilder<List<FormationModel>>(
      stream: ParcoursRepository().watchFormations(user.uid),
      builder: (context, snap) {
        FormationModel? tip;
        final list = snap.data;
        if (list != null && list.isNotEmpty) {
          tip = list.firstWhere((f) => f.id == 'tip', orElse: () => list.first);
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _animatedSection(0, _buildHomeContent(context, user, tip)),
              _animatedSection(1, const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: TechNewsSection(),
              )),
            ],
          ),
        );
      },
    );
  }

  Widget _animatedSection(int index, Widget child) {
    final visible = _sectionVisible[index];
    return AnimatedOpacity(
      opacity: visible ? 1 : 0,
      duration: const Duration(milliseconds: 300),
      child: child,
    );
  }

  Widget _buildHomeContent(BuildContext context, UserModel user, FormationModel? tip) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopActions(),
          const SizedBox(height: 12),
          Text(
            user.username.isNotEmpty ? 'Bonjour ${user.username} \u{1F44B}' : 'Bonjour \u{1F44B}',
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          UserStatusPill(
            displayName: user.username,
            level: user.level,
            xp: user.xp,
            streak: user.streak,
          ),
          const SizedBox(height: 24),
          _buildQuestsSection(),
          const SizedBox(height: 24),
          _buildHeroCard(context, tip),
          const SizedBox(height: 24),
          _buildQuickAccessSection(context),
        ],
      ),
    );
  }

  Widget _buildTopActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(onPressed: () => context.push('/notifications'), icon: const Icon(Icons.notifications_outlined, color: Colors.white)),
        IconButton(onPressed: () => context.push('/settings'), icon: const Icon(Icons.settings_outlined, color: Colors.white)),
      ],
    );
  }

  Widget _buildQuestsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'QUÊTES DU JOUR',
          style: TextStyle(
            color: _slateLight,
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        _QuestPill(
          label: 'Faire un quiz rapide',
          isDone: _quests?.quizDone ?? false,
          icon: '⚡',
        ),
        const SizedBox(height: 8),
        _QuestPill(
          label: 'Réviser mes flashcards',
          isDone: _quests?.flashDone ?? false,
          icon: '🃏',
        ),
        const SizedBox(height: 8),
        _QuestPill(
          label: 'Avancer dans le parcours',
          isDone: _quests?.parcoursDone ?? false,
          icon: '📚',
        ),
      ],
    );
  }

  Widget _buildHeroCard(BuildContext context, FormationModel? tip) {
    final total = tip?.totalModules ?? 23; // Valeur par défaut de l'audit
    final done = tip?.completedModules ?? 0;
    final pct = total > 0 ? (done / total).clamp(0.0, 1.0) : 0.0;
    
    return GradientBorderCard(
      gradientColors: EskoliaVisual.borderPrimary,
      glowColor: _violetBrand,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Parcours Optimus', style: TextStyle(color: _slateLight, fontSize: 13, fontWeight: FontWeight.w600)),
              Text('$done / $total', style: const TextStyle(color: _cyan, fontSize: 13, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Continuer ma formation', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct, 
              backgroundColor: Colors.white10, 
              color: _cyan,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessSection(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: EskoliaButton(
            label: 'Quiz',
            icon: Icons.bolt_rounded,
            variant: EskoliaButtonVariant.primary,
            expand: true,
            onPressed: () => context.push('/quiz/quick'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: EskoliaButton(
            label: 'Multi',
            icon: Icons.videogame_asset_rounded,
            variant: EskoliaButtonVariant.primary,
            color: const Color(0xFF43E97B),
            textColor: const Color(0xFF0F0F1A),
            expand: true,
            onPressed: () => context.push('/lobbys'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: EskoliaButton(
            label: 'Cartes',
            icon: Icons.style_rounded,
            variant: EskoliaButtonVariant.primary,
            color: const Color(0xFF22D3EE),
            textColor: const Color(0xFF0F0F1A),
            expand: true,
            onPressed: () => context.push('/flashcards'),
          ),
        ),
      ],
    );
  }
}

class _QuestPill extends StatelessWidget {
  const _QuestPill({
    required this.label,
    required this.isDone,
    required this.icon,
  });

  final String label;
  final bool isDone;
  final String icon;

  static const _kGreen = Color(0xFF43E97B);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDone
            ? _kGreen.withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDone
              ? _kGreen.withValues(alpha: 0.35)
              : Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: isDone
                            ? Colors.white.withValues(alpha: 0.7)
                            : Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      isDone ? '1 / 1' : '0 / 1',
                      style: TextStyle(
                        color: isDone
                            ? _kGreen
                            : _slateLight.withValues(alpha: 0.6),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: isDone ? 1.0 : 0.0,
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                    color: isDone ? _kGreen : _slateLight.withValues(alpha: 0.25),
                    minHeight: 5,
                  ),
                ),
              ],
            ),
          ),
          if (isDone)
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Icon(Icons.check_circle_rounded, color: _kGreen, size: 20),
            ),
        ],
      ),
    );
  }
}
