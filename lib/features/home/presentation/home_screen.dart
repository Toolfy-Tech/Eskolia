import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/preferences/onboarding_prefs.dart';
import '../../../core/utils/eskolia_snackbar.dart';
import '../../../core/theme/eskolia_layout.dart';
import '../../../core/theme/eskolia_visual.dart';
import '../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../shared/widgets/eskolia_button.dart';
import '../../auth/data/user_model.dart';
import '../../economy/data/achievement_triggers.dart';
import '../data/home_repository.dart';
import 'widgets/tech_news_section.dart';

const Color _surfaceBar = Color(0xFF1E293B);
const Color _redStreak = Color(0xFFEF4444);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeRepository _repo = HomeRepository();

  UserModel? _user;
  bool _isLoading = true;
  String? _errorMessage;
  final List<bool> _sectionVisible = List.filled(2, false);

  StreamSubscription<UserModel?>? _userSub;

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

  Future<void> _loadData() async {
    _userSub?.cancel();
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
        try {
          await AchievementTriggers(
            onUnlocked: (emoji, title) {
              if (mounted) showAchievementSnackBar(context, emoji, title);
            },
          ).syncFromUserSnapshot(user);
          if (!mounted) return;
          setState(() {
            _user = user;
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
      backgroundColor: Colors.transparent,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _skeletonBox(36, 36, radius: 18),
              const SizedBox(width: 8),
              _skeletonBox(36, 36, radius: 18),
            ],
          ),
          const SizedBox(height: 12),
          _skeletonBox(16, 200, radius: 8),
          const SizedBox(height: 20),
          _skeletonBox(100, double.infinity, radius: 14),
          const SizedBox(height: 12),
          _skeletonBox(100, double.infinity, radius: 14),
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
          EskoliaButton(label: 'Reessayer', onPressed: _loadData),
        ],
      ),
    );
  }

  Widget _buildMain(BuildContext context) {
    final user = _user!;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _animatedSection(0, _buildWelcomeHeader(user)),
          _animatedSection(
            1,
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: TechNewsSection(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _animatedSection(int index, Widget child) {
    return AnimatedOpacity(
      opacity: _sectionVisible[index] ? 1 : 0,
      duration: const Duration(milliseconds: 300),
      child: child,
    );
  }

  Widget _buildWelcomeHeader(UserModel user) {
    final hour = DateTime.now().hour;
    final greeting =
        hour < 12 ? 'Bonjour' : (hour < 18 ? 'Bon apres-midi' : 'Bonsoir');
    final name = user.username.isNotEmpty ? user.username : '';

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF1A1040), EskoliaVisual.bgDeep],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$greeting\u{1F44B}',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (name.isNotEmpty)
                    Text(
                      name,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                      ),
                    ),
                ],
              ),
              Row(
                children: [
                  _IconAction(
                    icon: Icons.notifications_outlined,
                    onTap: () => context.push('/notifications'),
                  ),
                  const SizedBox(width: 4),
                  _IconAction(
                    icon: Icons.person_outline_rounded,
                    onTap: () => context.push('/profil'),
                  ),
                  const SizedBox(width: 4),
                  _IconAction(
                    icon: Icons.settings_outlined,
                    onTap: () => context.push('/settings'),
                  ),
                ],
              ),
            ],
          ),
          if (user.streak >= 3) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  const Color(0xFFFF6B35).withValues(alpha: 0.2),
                  const Color(0xFFFF9F0A).withValues(alpha: 0.1),
                ]),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFFF9F0A).withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('\u{1F525}', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Text(
                    '${user.streak} jours de serie — continue !',
                    style: GoogleFonts.inter(
                      color: const Color(0xFFFF9F0A),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.07),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: Colors.white.withValues(alpha: 0.8),
            size: 20,
          ),
        ),
      ),
    );
  }
}
