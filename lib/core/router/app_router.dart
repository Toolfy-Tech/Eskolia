import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/forgot_password_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/onboarding/presentation/formation_choice_screen.dart';
import '../../features/profil/presentation/certificate_screen.dart';
import '../../features/classement/presentation/leaderboard_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/solo/presentation/practical_missions_screen.dart';
import '../../features/solo/presentation/practical_track_screen.dart';
import '../../features/solo/presentation/solo_revision_menu_screen.dart';
import '../../features/solo/presentation/solo_screen.dart';
import '../../features/lobby/lobby_detail_screen.dart';
import '../../features/lobby/lobby_list_screen.dart';
import '../../features/docs/presentation/docs_screen.dart';
import '../../features/parcours/data/tip_quiz_catalog.dart';
import '../../features/parcours/presentation/chapter_lesson_screen.dart';
import '../../features/parcours/presentation/parcours_screen.dart';
import '../../features/profil/presentation/profile_screen.dart';
import '../../features/notifications/notifications_screen.dart';
// Nouveaux imports Quiz (Architecture Modulaire)
import '../../features/quiz/screens/quiz_solo_setup_screen.dart';
import '../../features/quiz/screens/quiz_screen.dart';
import '../../features/quiz/screens/quiz_setup_screen.dart';
import '../../features/quiz/screens/quiz_quick_screen.dart';
import '../../features/quiz/screens/quiz_survival_screen.dart';
import '../../features/quiz/screens/revision_lacunes_screen.dart';
import '../../features/quiz/screens/revision_pool_screen.dart';
import '../../features/quiz/screens/grand_finale_optimus_screen.dart';
import '../../features/quiz/screens/grand_finale_tip_screen.dart';
import '../../features/quiz/services/quiz_repository.dart';
import '../../features/quiz/models/revision_pool_launch_mode.dart';

import '../../features/flashcards/presentation/flashcard_quick_screen.dart';
import '../../features/flashcards/presentation/flashcard_session_screen.dart';
import '../../features/flashcards/presentation/flashcard_solo_setup_screen.dart';
import '../../features/flashcards/presentation/flashcards_hub_screen.dart';

import '../../features/economy/presentation/achievements_screen.dart';
import '../../features/admin/presentation/admin_class_dashboard_screen.dart';
import '../../features/admin/presentation/admin_drafts_screen.dart';
import '../../features/admin/presentation/admin_feedback_screen.dart';
import '../../features/admin/presentation/admin_home_screen.dart';
import '../../features/admin/presentation/admin_signalements_screen.dart';
import '../../features/admin/presentation/admin_teacher_quiz_detail_screen.dart';
import '../../features/admin/presentation/admin_teacher_quizzes_screen.dart';
import '../../features/admin/presentation/admin_tips_screen.dart';
import '../../features/labo/presentation/labo_create_question_screen.dart';
import '../../features/labo/presentation/labo_create_tip_screen.dart';
import '../../features/labo/presentation/labo_hub_screen.dart';
import '../../features/labo/presentation/labo_reports_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/true_false/presentation/true_false_swipe_screen.dart';
import '../../features/lobby/presentation/battle_screen.dart';
import '../../features/tp/presentation/tp_hub_screen.dart';
import '../../features/tp/presentation/tp_scenario_screen.dart';
import '../../features/tp/reseau/data/network_exercise_engine.dart';
import '../../features/tp/reseau/presentation/reseau_hub_screen.dart';
import '../../features/tp/reseau/presentation/reseau_session_screen.dart';
import '../../features/ai/presentation/ai_setup_screen.dart';
import '../../features/notebook/presentation/notebook_screen.dart';
import '../../features/notebook/presentation/note_editor_screen.dart';
import '../../features/notebook/data/note_model.dart';
import '../widgets/bottom_nav.dart';
import 'eskolia_page_transitions.dart';

final AuthRefreshNotifier _authRefresh = AuthRefreshNotifier();
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  refreshListenable: _authRefresh,
  redirect: (BuildContext context, GoRouterState state) {
    final user = FirebaseAuth.instance.currentUser;
    final loggedIn = user != null;
    final path = state.matchedLocation;

    if (!loggedIn) {
      if (path == '/onboarding') return '/login';
      if (path == '/splash' || path == '/login' || path == '/register' || path == '/login/forgot') return null;
      return '/login';
    }
    if (loggedIn && (path == '/login' || path == '/register' || path == '/login/forgot' || path == '/')) {
      return '/home';
    }
    return null;
  },
  routes: [
    // RACINE
    GoRoute(
      path: '/',
      redirect: (_, __) => '/home',
    ),
    GoRoute(
      path: '/splash',
      pageBuilder: (context, state) => eskoliaTransitionPage(child: const SplashScreen()),
    ),
    GoRoute(
      path: '/login/forgot',
      pageBuilder: (context, state) => eskoliaTransitionPage(child: const ForgotPasswordScreen()),
    ),
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) => eskoliaTransitionPage(child: const LoginScreen()),
    ),
    GoRoute(
      path: '/register',
      pageBuilder: (context, state) => eskoliaTransitionPage(child: const RegisterScreen()),
    ),
    GoRoute(
      path: '/onboarding',
      pageBuilder: (context, state) => eskoliaTransitionPage(child: const OnboardingScreen()),
    ),
    GoRoute(
      path: '/formation-choix',
      pageBuilder: (context, state) => eskoliaTransitionPage(child: const FormationChoiceScreen()),
    ),
    GoRoute(
      path: '/certificate/:formationId',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) {
        final formationId = state.pathParameters['formationId'] ?? 'optimus';
        return eskoliaTransitionPage(child: CertificateScreen(formationId: formationId));
      },
    ),

    // --- ROUTES PLEIN ÉCRAN (HORS SHELL) ---
    GoRoute(
      path: '/quiz/run',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) {
        final extra = state.extra;
        if (extra is! QuizSession) return eskoliaTransitionPage(child: const QuizSetupScreen());
        return eskoliaTransitionPage(
          child: QuizScreen(sessionId: extra.sessionId, initialSession: extra),
        );
      },
    ),
    GoRoute(
      path: '/quiz/:sessionId',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) {
        final sessionId = state.pathParameters['sessionId']!;
        return eskoliaTransitionPage(child: QuizScreen(sessionId: sessionId));
      },
    ),
    GoRoute(
      path: '/cours/:moduleId',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) {
        final moduleId = state.pathParameters['moduleId']!;
        return eskoliaTransitionPage(child: ChapterLessonScreen(moduleId: moduleId));
      },
    ),
    GoRoute(
      path: '/notifications',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => eskoliaTransitionPage(child: const NotificationsScreen()),
    ),
    GoRoute(
      path: '/lobby/:id',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => eskoliaTransitionPage(child: LobbyDetailScreen(lobbyId: state.pathParameters['id']!)),
    ),
    GoRoute(
      path: '/lobby/:id/battle',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => eskoliaTransitionPage(
        child: BattleScreen(lobbyId: state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path: '/tp/reseau',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => eskoliaTransitionPage(child: const ReseauHubScreen()),
    ),
    GoRoute(
      path: '/tp/reseau/:category',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) {
        final slug = state.pathParameters['category']!;
        final cat = _slugToCategory(slug);
        return eskoliaTransitionPage(child: ReseauSessionScreen(category: cat));
      },
    ),
    GoRoute(
      path: '/tp/:trackId',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) {
        final trackId = state.pathParameters['trackId']!;
        if (trackId.startsWith('tp_ad_') || trackId.startsWith('tp_ps_')) {
          return eskoliaTransitionPage(child: TpScenarioScreen(trackId: trackId));
        }
        return eskoliaTransitionPage(child: PracticalTrackScreen(trackId: trackId));
      },
    ),
    GoRoute(
      path: '/tp/:trackId/missions',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) {
        final trackId = state.pathParameters['trackId']!;
        if (trackId.startsWith('tp_ad_')) {
          return eskoliaTransitionPage(child: TpScenarioScreen(trackId: trackId));
        }
        return eskoliaTransitionPage(
          child: PracticalMissionsScreen(trackId: trackId),
        );
      },
    ),
    GoRoute(
      path: '/admin/drafts',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => eskoliaTransitionPage(child: const AdminDraftsScreen()),
    ),
    GoRoute(
      path: '/admin/tips',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => eskoliaTransitionPage(child: const AdminTipsScreen()),
    ),
    GoRoute(
      path: '/admin/signalements',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => eskoliaTransitionPage(child: const AdminSignalementsScreen()),
    ),
    GoRoute(
      path: '/admin/feedback',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => eskoliaTransitionPage(child: const AdminFeedbackScreen()),
    ),
    GoRoute(
      path: '/admin/teacher-quizzes',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => eskoliaTransitionPage(child: const AdminTeacherQuizzesScreen()),
    ),
    GoRoute(
      path: '/admin/classe',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => eskoliaTransitionPage(child: const AdminClassDashboardScreen()),
    ),
    GoRoute(
      path: '/admin/teacher-quizzes/:quizId',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => eskoliaTransitionPage(
        child: AdminTeacherQuizDetailScreen(
          quizId: state.pathParameters['quizId']!,
        ),
      ),
    ),
    GoRoute(
      path: '/labo/create-question',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => eskoliaTransitionPage(child: const LaboCreateQuestionScreen()),
    ),
    GoRoute(
      path: '/labo/create-tip',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => eskoliaTransitionPage(child: const LaboCreateTipScreen()),
    ),
    GoRoute(
      path: '/labo/reports',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => eskoliaTransitionPage(child: const LaboReportsScreen()),
    ),
    GoRoute(
      path: '/flashcards/session',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) {
        final args = state.extra;
        if (args is! FlashcardSessionRouteArgs) {
          return eskoliaTransitionPage(child: const FlashcardsHubScreen());
        }
        return eskoliaTransitionPage(
          child: FlashcardSessionScreen(
            cards: args.cards,
            ephemeral: args.ephemeral,
            timed: args.timed,
            survival: args.survival,
          ),
        );
      },
    ),
    GoRoute(
      path: '/true-false',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => eskoliaTransitionPage(child: const TrueFalseSwipeScreen()),
    ),
    GoRoute(
      path: '/profil/:uid',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => eskoliaTransitionPage(
        child: ProfileScreen(uid: state.pathParameters['uid']!),
      ),
    ),
    GoRoute(
      path: '/ai/setup',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => eskoliaTransitionPage(child: const AiSetupScreen()),
    ),
    GoRoute(
      path: '/notebook/edit',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => eskoliaTransitionPage(
        child: NoteEditorScreen(note: state.extra as NoteModel?),
      ),
    ),

    // --- SHELL ROUTE (AVEC BOTTOM NAV) ---
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/home',
          pageBuilder: (context, state) => eskoliaTransitionPage(child: const HomeScreen()),
        ),
        GoRoute(
          path: '/solo',
          pageBuilder: (context, state) => eskoliaTransitionPage(child: const SoloScreen()),
        ),
        GoRoute(
          path: '/solo/quiz-solo',
          pageBuilder: (context, state) => eskoliaTransitionPage(child: const QuizSoloSetupScreen()),
        ),
        GoRoute(
          path: '/solo/revision',
          pageBuilder: (context, state) => eskoliaTransitionPage(child: const SoloRevisionMenuScreen()),
        ),
        GoRoute(
          path: '/parcours',
          pageBuilder: (context, state) => eskoliaTransitionPage(
            child: ParcoursScreen(expandFormationId: state.uri.queryParameters['focus']),
          ),
        ),
        GoRoute(
          path: '/leaderboard',
          pageBuilder: (context, state) => eskoliaTransitionPage(child: const LeaderboardScreen()),
        ),
        GoRoute(
          path: '/labo',
          pageBuilder: (context, state) => eskoliaTransitionPage(child: const LaboHubScreen()),
        ),
        GoRoute(
          path: '/quiz/setup',
          pageBuilder: (context, state) => eskoliaTransitionPage(child: const QuizSetupScreen()),
        ),
        GoRoute(
          path: '/quiz/quick',
          pageBuilder: (context, state) => eskoliaTransitionPage(
            child: QuizQuickScreen(initialCatalogTrack: TipQuizCatalog.parseTrackQuery(state.uri.queryParameters['track'])),
          ),
        ),
        GoRoute(
          path: '/quiz/survival',
          pageBuilder: (context, state) => eskoliaTransitionPage(
            child: QuizSurvivalScreen(initialCatalogTrack: TipQuizCatalog.parseTrackQuery(state.uri.queryParameters['track'])),
          ),
        ),
        GoRoute(
          path: '/quiz/epreuve-finale-tip',
          pageBuilder: (context, state) => eskoliaTransitionPage(child: const GrandFinaleTipScreen()),
        ),
        GoRoute(
          path: '/quiz/epreuve-finale-optimus',
          pageBuilder: (context, state) => eskoliaTransitionPage(child: const GrandFinaleOptimusScreen()),
        ),
        GoRoute(
          path: '/quiz/revision-lacunes',
          pageBuilder: (context, state) => eskoliaTransitionPage(
            child: RevisionLacunesScreen(initialCatalogTrack: TipQuizCatalog.parseTrackQuery(state.uri.queryParameters['track'])),
          ),
        ),
        GoRoute(
          path: '/revision-pool',
          pageBuilder: (context, state) {
            final mode = state.extra is RevisionPoolLaunchMode ? state.extra as RevisionPoolLaunchMode : RevisionPoolLaunchMode.browse;
            return eskoliaTransitionPage(child: RevisionPoolScreen(launchMode: mode));
          },
        ),
        GoRoute(
          path: '/lobbys',
          pageBuilder: (context, state) => eskoliaTransitionPage(child: const LobbyListScreen()),
        ),
        GoRoute(
          path: '/tp',
          pageBuilder: (context, state) => eskoliaTransitionPage(child: const TpHubScreen()),
        ),
        GoRoute(
          path: '/achievements',
          pageBuilder: (context, state) => eskoliaTransitionPage(child: const AchievementsScreen()),
        ),
        GoRoute(
          path: '/docs',
          pageBuilder: (context, state) => eskoliaTransitionPage(child: const DocsScreen()),
        ),
        GoRoute(
          path: '/notebook',
          pageBuilder: (context, state) => eskoliaTransitionPage(child: const NotebookScreen()),
        ),
        GoRoute(
          path: '/profil',
          pageBuilder: (context, state) => eskoliaTransitionPage(child: const ProfileScreen()),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) => eskoliaTransitionPage(child: const SettingsScreen()),
        ),
        GoRoute(
          path: '/admin',
          pageBuilder: (context, state) => eskoliaTransitionPage(child: const AdminHomeScreen()),
        ),
        GoRoute(
          path: '/flashcards',
          pageBuilder: (context, state) => eskoliaTransitionPage(child: const FlashcardsHubScreen()),
        ),
        GoRoute(
          path: '/flashcards/quick',
          pageBuilder: (context, state) => eskoliaTransitionPage(
            child: FlashcardQuickScreen(
              initialCatalogTrack: TipQuizCatalog.parseTrackQuery(state.uri.queryParameters['track']),
            ),
          ),
        ),
        GoRoute(
          path: '/flashcards/solo-setup',
          pageBuilder: (context, state) => eskoliaTransitionPage(child: const FlashcardSoloSetupScreen()),
        ),
        GoRoute(
          path: '/solo/flashcards-solo',
          pageBuilder: (context, state) => eskoliaTransitionPage(child: const FlashcardSoloSetupScreen()),
        ),
      ],
    ),
  ],
);

NetworkExerciseCategory _slugToCategory(String slug) => switch (slug) {
  'binaryConversion' => NetworkExerciseCategory.binaryConversion,
  'ipClass'          => NetworkExerciseCategory.ipClass,
  'defaultMask'      => NetworkExerciseCategory.defaultMask,
  'cidrNotation'     => NetworkExerciseCategory.cidrNotation,
  _                  => NetworkExerciseCategory.subnetCalc,
};

class AuthRefreshNotifier extends ChangeNotifier {
  AuthRefreshNotifier() {
    _subscription = FirebaseAuth.instance.authStateChanges().listen((_) => notifyListeners());
  }
  late final StreamSubscription<User?> _subscription;
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

