import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/preferences/onboarding_prefs.dart';
import '../../../core/theme/eskolia_layout.dart';
import '../../../core/theme/eskolia_visual.dart';
import '../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../shared/widgets/eskolia_button.dart';
import '../../../shared/widgets/eskolia_shell_body.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _index = 0;

  static const _slides = <_Slide>[
    _Slide(
      emoji: '\u{1F4DA}',
      title: 'Apprends le reseau autrement',
      body: 'Parcours TIP structures : sections, chapitres et quiz pour valider tes acquis, au rythme qui t\'arrange.',
    ),
    _Slide(
      emoji: '\u{1F3AE}',
      title: 'Gamification serieuse',
      body: 'XP, serie \u{1F525}, quiz rapides et pool de revision : chaque effort compte vers ton niveau.',
    ),
    _Slide(
      emoji: '\u{2694}\u{FE0F}',
      title: 'Defie la communaute',
      body: 'Lobbys multijoueur pour t\'entrainer ensemble. Le classement et les duels en temps reel t\'attendent.',
    ),
    _Slide(
      emoji: '\u{1F680}',
      title: 'Rejoins la communaute',
      body: 'Cree ton compte gratuitement pour sauvegarder ta progression, tes XP et tes badges.',
      isAuthSlide: true,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await OnboardingPrefs.markCompleted();
    if (!mounted) return;
    context.go('/home');
  }

  void _next() {
    if (_index < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    } else {
      _finish();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _index == _slides.length - 1;
    return Scaffold(
      backgroundColor: EskoliaVisual.bgDeep,
      body: Stack(
        children: [
          const EskoliaAmbientBackground(),
          EskoliaShellBody(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _finish,
                    child: Text(
                      'Passer',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _slides.length,
                    onPageChanged: (i) => setState(() => _index = i),
                    itemBuilder: (context, i) => _SlideView(
                      slide: _slides[i],
                      key: ValueKey(i),
                    ),
                  ),
                ),
                _buildDots(),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    EskoliaLayout.screenPaddingH,
                    0,
                    EskoliaLayout.screenPaddingH,
                    EskoliaLayout.screenPaddingBottom,
                  ),
                  child: isLast
                      ? _buildAuthButtons()
                      : EskoliaButton(
                          label: 'Suivant',
                          variant: EskoliaButtonVariant.primary,
                          expand: true,
                          onPressed: _next,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _slides.length,
        (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: i == _index ? 22 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: i == _index
                ? EskoliaVisual.neonViolet
                : Colors.white.withValues(alpha: 0.2),
          ),
        ),
      ),
    );
  }

  Widget _buildAuthButtons() {
    return Column(
      children: [
        EskoliaButton(
          label: 'Creer mon compte',
          variant: EskoliaButtonVariant.primary,
          expand: true,
          onPressed: () async {
            await OnboardingPrefs.markCompleted();
            if (!mounted) return;
            context.go('/register');
          },
        ),
        const SizedBox(height: 10),
        EskoliaButton(
          label: "J'ai deja un compte",
          variant: EskoliaButtonVariant.secondary,
          expand: true,
          onPressed: () async {
            await OnboardingPrefs.markCompleted();
            if (!mounted) return;
            context.go('/login');
          },
        ),
      ],
    );
  }
}

class _SlideView extends StatelessWidget {
  const _SlideView({super.key, required this.slide});
  final _Slide slide;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: EskoliaLayout.screenPaddingH),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(slide.emoji, style: const TextStyle(fontSize: 72))
              .animate()
              .fadeIn(duration: 340.ms)
              .scaleXY(begin: 0.7, duration: 340.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 28),
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          )
              .animate()
              .fadeIn(duration: 320.ms, delay: 80.ms)
              .slideY(begin: 0.12, duration: 320.ms, delay: 80.ms),
          const SizedBox(height: 16),
          Text(
            slide.body,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.72),
              fontSize: 16,
              height: 1.45,
            ),
          )
              .animate()
              .fadeIn(duration: 320.ms, delay: 160.ms)
              .slideY(begin: 0.12, duration: 320.ms, delay: 160.ms),
        ],
      ),
    );
  }
}

class _Slide {
  const _Slide({
    required this.emoji,
    required this.title,
    required this.body,
    this.isAuthSlide = false,
  });

  final String emoji;
  final String title;
  final String body;
  final bool isAuthSlide;
}
