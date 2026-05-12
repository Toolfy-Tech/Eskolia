import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/preferences/onboarding_prefs.dart';
import '../../core/theme/eskolia_visual.dart';
import '../../shared/widgets/eskolia_ambient_background.dart';
import '../../shared/widgets/eskolia_shell_body.dart';

const Color _violet = Color(0xFF6C63FF);
const Color _accent = Color(0xFF43E97B);

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 2), _goNext);
  }

  Future<void> _goNext() async {
    if (!mounted) return;
    final loggedIn = FirebaseAuth.instance.currentUser != null;
    if (!loggedIn) {
      if (mounted) context.go('/login');
      return;
    }
    final onboardingDone = await OnboardingPrefs.isCompleted();
    if (!mounted) return;
    context.go(onboardingDone ? '/home' : '/onboarding');
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EskoliaVisual.bgDeep,
      body: Stack(
        children: [
          const EskoliaAmbientBackground(),
          EskoliaShellBody(
            child: Center(
              child: ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [_violet, _accent],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ).createShader(bounds),
                child: const Text(
                  'ESKOLIA',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 4,
                    color: Colors.white,
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
