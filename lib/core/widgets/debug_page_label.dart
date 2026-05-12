// TODO: REMOVE AFTER AUDIT
import 'dart:math';

import 'package:flutter/material.dart';

/// Overlay de debug affiché dans la marge droite (hors [contentMaxWidth]).
/// Affiche la classe de l'écran courant (ou la route en fallback), rotaté -90°.
///
/// Injecté une seule fois via [DebugRouteOverlay] dans app_router.dart.
/// À supprimer après l'audit UI/UX.
class DebugPageLabel extends StatelessWidget {
  const DebugPageLabel({
    super.key,
    required this.path,
    required this.child,
  });

  final String path;
  final Widget child;

  // ── Mapping route → classe Dart ──────────────────────────────────────────
  static const _exact = <String, String>{
    '/splash': 'SplashScreen',
    '/login': 'LoginScreen',
    '/login/forgot': 'ForgotPasswordScreen',
    '/register': 'RegisterScreen',
    '/onboarding': 'OnboardingScreen',
    '/home': 'HomeScreen',
    '/solo': 'SoloScreen',
    '/solo/quiz-solo': 'QuizSoloSetupScreen',
    '/solo/revision': 'SoloRevisionMenuScreen',
    '/solo/flashcards-solo': 'FlashcardSoloSetupScreen',
    '/parcours': 'ParcoursScreen',
    '/leaderboard': 'LeaderboardScreen',
    '/labo': 'LaboHubScreen',
    '/labo/create-question': 'LaboCreateQuestionScreen',
    '/labo/create-tip': 'LaboCreateTipScreen',
    '/labo/reports': 'LaboReportsScreen',
    '/quiz/setup': 'QuizSetupScreen',
    '/quiz/quick': 'QuizQuickScreen',
    '/quiz/survival': 'QuizSurvivalScreen',
    '/quiz/run': 'QuizScreen',
    '/quiz/epreuve-finale-tip': 'GrandFinaleTipScreen',
    '/quiz/epreuve-finale-optimus': 'GrandFinaleOptimusScreen',
    '/quiz/revision-lacunes': 'RevisionLacunesScreen',
    '/revision-pool': 'RevisionPoolScreen',
    '/lobbys': 'LobbyListScreen',
    '/tp': 'PracticalExercisesHubScreen',
    '/achievements': 'AchievementsScreen',
    '/docs': 'DocsScreen',
    '/profil': 'ProfileScreen',
    '/settings': 'SettingsScreen',
    '/admin': 'AdminHomeScreen',
    '/admin/drafts': 'AdminDraftsScreen',
    '/admin/tips': 'AdminTipsScreen',
    '/admin/signalements': 'AdminSignalementsScreen',
    '/flashcards': 'FlashcardsHubScreen',
    '/flashcards/quick': 'FlashcardQuickScreen',
    '/flashcards/solo-setup': 'FlashcardSoloSetupScreen',
    '/flashcards/session': 'FlashcardSessionScreen',
    '/notifications': 'NotificationsScreen',
    '/true-false': 'TrueFalseSwipeScreen',
  };

  static String _classFor(String path) {
    final direct = _exact[path];
    if (direct != null) return direct;

    // Parameterized routes — suffixes checked first for specificity
    if (path.startsWith('/lobby/') && path.endsWith('/battle')) return 'BattleScreen';
    if (path.startsWith('/tp/') && path.endsWith('/missions')) return 'PracticalMissionsScreen';
    if (path.startsWith('/cours/')) return 'ChapterLessonScreen';
    if (path.startsWith('/lobby/')) return 'LobbyDetailScreen';
    if (path.startsWith('/tp/')) return 'PracticalTrackScreen';
    if (path.startsWith('/profil/')) return 'ProfileScreen';
    if (path.startsWith('/quiz/')) return 'QuizScreen'; // /quiz/:sessionId

    return path;
  }

  @override
  Widget build(BuildContext context) {
    final label = _classFor(path);

    return Stack(
      children: [
        child,
        Positioned(
          right: 4,
          width: 24,
          top: 0,
          bottom: 0,
          child: Center(
            child: IgnorePointer(
              child: Transform.rotate(
                angle: -pi / 2,
                child: Text(
                  label,
                  maxLines: 1,
                  softWrap: false,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0x666C63FF), // primary #6C63FF @ 40 %
                    decoration: TextDecoration.none,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
