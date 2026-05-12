# Eskolia — Project Overview

> Dernière mise à jour : 2026-05-07

## Stack technique

| Couche | Technologie | Version |
|--------|-------------|---------|
| Framework | Flutter | SDK ≥ 3.5.0 |
| Backend | Firebase (Auth + Firestore + Storage) | firebase_core ^4.0.0 |
| Auth | firebase_auth | ^6.4.0 |
| Base de données | cloud_firestore | ^6.3.0 |
| Storage | firebase_storage | ^13.3.0 |
| State management | flutter_riverpod | ^3.3.1 |
| Navigation | go_router | ^17.2.3 |
| Polices | google_fonts (Poppins + Inter) | ^8.1.0 |
| Animations | flutter_animate | ^4.5.2 |
| Animations Lottie | lottie | ^3.3.3 |
| Animations Rive | rive | ^0.14.6 |
| Glassmorphism | glassmorphism | ^3.0.0 |
| Cache local | hive + hive_flutter | ^2.2.3 |
| HTTP client | dio | ^5.8.0+1 |
| Images réseau | cached_network_image | ^3.4.1 |
| Markdown | flutter_markdown | ^0.7.7+1 |
| Liens externes | url_launcher | ^6.3.2 |
| Préférences | shared_preferences | ^2.3.5 |
| Tests | fake_cloud_firestore + firebase_auth_mocks | dev |

**Cibles déployées :** Web (path URL strategy), Android, iOS, macOS.  
**Firebase project ID :** `eskolia`

---

## Architecture feature-based

```
lib/
├── core/                      # Transversal — router, thème, services, constantes
│   ├── config/                # Bootstrap staff (rôle admin via email)
│   ├── constants/             # colors.dart, spacing.dart, typography.dart
│   ├── preferences/           # Prefs onboarding (SharedPreferences)
│   ├── router/                # app_router.dart (GoRouter), transitions, QuizSession
│   ├── services/              # FirebaseService, AssetCacheService
│   ├── theme/                 # AppTheme, extensions Glass/Neon, layout, visual
│   ├── time/                  # xp_week_key (clé semaine ISO pour XP hebdo)
│   ├── utils/                 # EskoliaSnackbar
│   └── widgets/               # BottomNav, TopBar
├── data/                      # Repositories partagés (quiz, user, leaderboard, battle)
│   ├── repositories/
│   ├── cache/
│   ├── models/
│   ├── services/
│   └── tip/
├── features/                  # Une feature = un dossier data/ + presentation/
│   ├── admin/                 # Back-office (drafts, tips, signalements)
│   ├── auth/                  # Login, Register, ForgotPassword
│   ├── classement/            # Leaderboard (daily + global)
│   ├── docs/                  # Mini-formations réglementaires (RGPD, CNIL, ANSSI)
│   ├── economy/               # Achievements, badges, daily quests
│   ├── flashcards/            # Hub + session + solo setup + quick
│   ├── home/                  # HomeScreen, flux RSS actualités tech
│   ├── labo/                  # Création de questions/tips communautaires
│   ├── lobby/                 # Lobbies multijoueur + BattleScreen
│   ├── notifications/         # Notifications in-app
│   ├── onboarding/            # Écran de bienvenue post-inscription
│   ├── parcours/              # Parcours Optimus (chapitres + leçons markdown)
│   ├── profil/                # Profil utilisateur public/privé
│   ├── quiz/                  # Quiz (solo, survival, lacunes, revision pool)
│   ├── settings/              # Paramètres utilisateur
│   ├── solo/                  # Menu solo, TP (travaux pratiques)
│   ├── splash/                # Écran de démarrage
│   └── true_false/            # Mode Vrai/Faux swipe
└── shared/                    # Widgets et animations réutilisables
    ├── animations/
    └── widgets/               # EskoliaCard, EskoliaButton, EskoliaAppBar, etc.
```

**Convention dans chaque feature :**
- `data/` → modèles, repositories (Firestore + assets), services
- `presentation/` → screens, dialogs, widgets spécifiques à la feature
- Les screens actifs sont dans `presentation/` ; les anciens doublons à la racine de la feature sont obsolètes.

---

## Routes GoRouter

### Navigation shell (avec barre de navigation bas)

| Route | Écran | Notes |
|-------|-------|-------|
| `/home` | HomeScreen | Accueil, quêtes, actualités RSS |
| `/solo` | SoloScreen | Menu entraînement solo |
| `/solo/quiz-solo` | QuizSoloSetupScreen | Config quiz solo |
| `/solo/revision` | SoloRevisionMenuScreen | Menu révisions |
| `/solo/flashcards-solo` | FlashcardSoloSetupScreen | Setup flashcards solo |
| `/parcours` | ParcoursScreen | Parcours Optimus, `?focus=formationId` |
| `/leaderboard` | LeaderboardScreen | Classement |
| `/labo` | LaboHubScreen | Hub communautaire |
| `/quiz/setup` | QuizSetupScreen | Config quiz |
| `/quiz/quick` | QuizQuickScreen | Quiz rapide, `?track=` |
| `/quiz/survival` | QuizSurvivalScreen | Mode survival, `?track=` |
| `/quiz/epreuve-finale-tip` | GrandFinaleTipScreen | Épreuve finale TIP |
| `/quiz/epreuve-finale-optimus` | GrandFinaleOptimusScreen | Épreuve finale Optimus |
| `/quiz/revision-lacunes` | RevisionLacunesScreen | Révision lacunes, `?track=` |
| `/revision-pool` | RevisionPoolScreen | Pool de révision (📌) |
| `/lobbys` | LobbyListScreen | Liste des lobbies multi |
| `/tp` | PracticalExercisesHubScreen | Hub TP |
| `/achievements` | AchievementsScreen | Succès et badges |
| `/docs` | DocsScreen | Mini-formations réglementaires |
| `/profil` | ProfileScreen | Profil propre |
| `/settings` | SettingsScreen | Paramètres |
| `/admin` | AdminHomeScreen | Back-office (staff only) |
| `/flashcards` | FlashcardsHubScreen | Hub flashcards |
| `/flashcards/quick` | FlashcardQuickScreen | Flashcards rapides |
| `/flashcards/solo-setup` | FlashcardSoloSetupScreen | Setup flashcards |

### Routes plein écran (sans shell, parent: rootNavigatorKey)

| Route | Écran | Notes |
|-------|-------|-------|
| `/quiz/run` | QuizScreen | Requiert `extra: QuizSession` |
| `/quiz/:sessionId` | QuizScreen | Chargement par ID |
| `/cours/:moduleId` | ChapterLessonScreen | Leçon markdown Optimus |
| `/notifications` | NotificationsScreen | Notifications in-app |
| `/lobby/:id` | LobbyDetailScreen | Détail d'un lobby |
| `/lobby/:id/battle` | BattleScreen | Session bataille |
| `/tp/:trackId` | PracticalTrackScreen | TP — contenu |
| `/tp/:trackId/missions` | PracticalMissionsScreen | Missions d'un TP |
| `/admin/drafts` | AdminDraftsScreen | Modération drafts |
| `/admin/tips` | AdminTipsScreen | Modération tips |
| `/admin/signalements` | AdminSignalementsScreen | Modération signalements |
| `/labo/create-question` | LaboCreateQuestionScreen | Créer une question |
| `/labo/create-tip` | LaboCreateTipScreen | Créer un tip |
| `/labo/reports` | LaboReportsScreen | Signalements propres |
| `/flashcards/session` | FlashcardSessionScreen | Requiert `extra: FlashcardSessionRouteArgs` |
| `/true-false` | TrueFalseSwipeScreen | Mode Vrai/Faux |
| `/profil/:uid` | ProfileScreen | Profil public d'un autre joueur |

### Routes auth (sans shell, sans barre nav)

| Route | Écran |
|-------|-------|
| `/splash` | SplashScreen |
| `/login` | LoginScreen |
| `/login/forgot` | ForgotPasswordScreen |
| `/register` | RegisterScreen |
| `/onboarding` | OnboardingScreen |

**Redirect logic :** Non authentifié → `/login`. Authentifié sur route auth → `/home`. `AuthRefreshNotifier` écoute `FirebaseAuth.authStateChanges()`.

---

## Providers Riverpod principaux

### `quizProvider` (NotifierProvider.autoDispose.family<QuizNotifier, QuizState, String>)
Fichier : `lib/features/quiz/viewmodels/quiz_notifier.dart`

Gère toute la session de quiz en cours :
- `initSession(sessionId, {initialSession})` — charge ou injecte la session
- `reveal()` — retourne la carte (révèle la réponse)
- `revealAndScoreSequence(userOrder, correctOrder)` — score pour type `sequence`
- `submitFeedback(wasCorrect)` — enregistre le score, sync lacunes
- `toggleTicketCheck(index)` — pour type `ticket` (checklist)
- `incrementIndices()` — révèle un indice (type `diagnostic_indices`)
- `nextQuestion()` → `bool` — avance ou retourne `false` (fin/game over)
- `onTimeUp()` — timeout automatique (timer 30 s)

**State :** `QuizState` contient `session`, `isFlipped`, `isValidated`, `secondsLeft`, `isTimedOut`, `lives` (survival), `revealedIndicesCount`, `ticketChecks`.

*Note : les autres providers (leaderboard, profil, home, parcours, etc.) sont construits directement dans les screens avec `ref.watch` sur des `FutureProvider` ou `StreamProvider` locaux — pas de fichiers provider centralisés séparés.*

---

## Modèles de données clés

### `UserModel`
Fichier : `lib/features/auth/data/user_model.dart`

```dart
String uid, username, email
List<String> interestSections    // sections choisies à l'inscription (S01, S02…)
int level, xp, xpThisWeek, streak
int currentChapter, currentModule
int totalQuizzesPlayed, totalWins, battleWins
List<String> badges
DateTime? lastLogin
DateTime createdAt
String role                       // 'user' | 'moderator' | 'admin'

// Computed
bool isStaff                      // role in ['admin','moderator']
int levelFromXp                   // xp ~/ 1000 + 1
int xpToNextLevel
double xpProgress                 // 0.0–1.0
bool isStreakActive                // lastLogin = today ou yesterday
```

### `QuizQuestion`
Fichier : `lib/features/quiz/models/quiz_models.dart`

```dart
String id, type, question, answer
List<String>? answerSequence      // pour type='sequence'
List<String>? indices             // pour type='diagnostic_indices'
List<String>? checklist           // pour type='ticket'
List<String>? options             // pour type QCM (legacyOptions)
String? explanation, sourceAssetPath, contextLine
String difficultyBucket           // 'facile' | 'moyen' | 'difficile' | 'unknown'
String? theme, sousTheme
QuestionCategoryGroup categoryGroup  // officialParcours | themes | labo
String authorName
```

**Types de questions :** `classic`, `sequence`, `diagnostic_indices`, `ticket`.

### `QuizSession`
Fichier : `lib/features/quiz/models/quiz_models.dart`

```dart
String sessionId, title
List<QuizQuestion> questions
int currentIndex
List<double?> userScores          // null=non répondu, 0.0/0.25/0.5/0.75/1.0
DateTime startTime
QuizRunMode runMode               // standard | survival
bool timed, postQuestionRecapEnabled
QuizCatalogTrack? survivalCatalogTrack
```

### `BattleSessionModel`
Fichier : `lib/features/quiz/models/battle_session_model.dart`

```dart
String id, player1Id, player2Id, player1Name, player2Name
int player1Score, player2Score
List<QuizQuestion> questions
int currentQuestionIndex
String status                     // 'waiting' | 'in_progress' | 'finished'
String? winnerId
DateTime createdAt
String moduleId
```

### `BattleState` (multijoueur temps réel)
Fichier : `lib/features/lobby/data/lobby_repository.dart`

```dart
String lobbyId
List<PlayerState> players
int currentQuestion, totalQuestions
String phase                      // 'countdown'|'question'|'judgment'|'result'|'finished'
List<BattleQuestion> questions
bool timed
String gameMode                   // 'mastery' | 'survival'
int secondsPerQuestion, revealedIndices
```

### `LobbyModel`
Fichier : `lib/features/lobby/data/lobby_repository.dart`

```dart
String id, title, subject, hostName, hostAvatar, hostId
int currentPlayers, maxPlayers    // max = 30 (kLobbyMaxPlayers)
String status                     // 'waiting' | 'in_progress' | 'finished'
String difficulty, quizId
String gameMode                   // 'mastery' | 'survival'
int questionCount                 // 5–50
String joinCode                   // 6 chars alphanumériques (ABCDEF…)
bool isPrivate, timed
List<String> difficultyFilters    // ['facile','moyen','difficile']
List<PlayerMeta> playerMeta
List<String> questionAssetPaths
```

---

## Assets curriculum

Fichiers JSON + Markdown embarqués dans l'APK/bundle :

```
data/curriculum/optimus/index.json
data/curriculum/optimus/section-01-hardware-architecture/   (ch01–ch06)
data/curriculum/optimus/section-02-systeme-exploitation/    (ch01–ch03)
data/curriculum/optimus/section-03-reseaux-infrastructure/  (ch01–ch05)
data/curriculum/optimus/section-04-maintenance-sauvegarde/  (ch01–ch05)
data/curriculum/optimus/section-05-cybersecurite/
data/curriculum/optimus/section-06-utiliser-ia/

data/quiz/optimus/section-01-hardware/
data/quiz/optimus/section-02-systemes/
data/quiz/optimus/section-03-reseaux/
data/quiz/optimus/section-04-maintenance/
data/quiz/optimus/section-05-securite/
data/quiz/optimus/section-06-ia/
data/quiz/themes/                  # Thèmes transversaux

data/docs/mini_formation_rgpd.md
data/docs/mini_formation_cnil.md
data/docs/mini_formation_anssi.md
data/home/tech_feeds.json          # URLs des flux RSS actualités
```
