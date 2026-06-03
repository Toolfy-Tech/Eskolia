import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/preferences/onboarding_prefs.dart';
import '../../core/theme/eskolia_visual.dart';
import '../../shared/widgets/eskolia_ambient_background.dart';
import '../../shared/widgets/eskolia_shell_body.dart';

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
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const EskoliaAmbientBackground(),
          EskoliaShellBody(
            child: Center(
              child: Image.asset(
                'assets/images/logo/eskolia_splash_logo.png',
                width: 440,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
