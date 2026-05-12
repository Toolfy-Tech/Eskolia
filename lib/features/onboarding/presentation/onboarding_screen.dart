import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/preferences/onboarding_prefs.dart';
import '../../../core/theme/eskolia_layout.dart';
import '../../../core/theme/eskolia_visual.dart';
import '../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../shared/widgets/eskolia_shell_body.dart';
import '../../../shared/widgets/eskolia_button.dart';

/// Onboarding 3 slides — blueprint v3 § Auth & onboarding.
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
      title: 'Apprends le réseau autrement',
      body:
          'Parcours TIP structurés : sections, chapitres et quiz pour valider tes acquis, au rythme qui t’arrange.',
    ),
    _Slide(
      emoji: '\u{1F3AE}',
      title: 'Gamification sérieuse',
      body:
          'XP, série 🔥, quiz rapides et pool de révision : chaque effort compte vers ton niveau.',
    ),
    _Slide(
      emoji: '\u{2694}\u{FE0F}',
      title: 'Défie la communauté',
      body:
          'Lobbys multijoueur pour t’entraîner ensemble. La progression et le classement arrivent au fil des mises à jour.',
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

  @override
  Widget build(BuildContext context) {
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
                        color: Colors.white.withValues(alpha: 0.65),
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
                    itemBuilder: (context, i) {
                      final s = _slides[i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: EskoliaLayout.screenPaddingH,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              s.emoji,
                              style: const TextStyle(fontSize: 72),
                            ),
                            const SizedBox(height: 28),
                            Text(
                              s.title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              s.body,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.72),
                                fontSize: 16,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Row(
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
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    EskoliaLayout.screenPaddingH,
                    0,
                    EskoliaLayout.screenPaddingH,
                    EskoliaLayout.screenPaddingBottom,
                  ),
                  child: EskoliaButton(
                    label: _index < _slides.length - 1 ? 'Suivant' : 'C’est parti',
                    variant: EskoliaButtonVariant.primary,
                    expand: true,
                    onPressed: () {
                      if (_index < _slides.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 320),
                          curve: Curves.easeOutCubic,
                        );
                      } else {
                        _finish();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
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
  });

  final String emoji;
  final String title;
  final String body;
}
