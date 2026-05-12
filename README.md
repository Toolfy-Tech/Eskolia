# Eskolia

> Application Flutter d'apprentissage gamifié avec quiz, battles multijoueur et parcours pédagogiques.

## Documentation (prompts & blueprint)

| Fichier | Rôle |
|---------|------|
| `eskolia_blueprint.md` | Vision, stack, architecture — **source unique** |
| `eskolia_cursor_prompts.md` | Prompts Cursor (fusion V2+V3) |
| `eskolia_image_prompts.md` | Prompts images IA (fusion ; bonus réseau) |

## Fonctionnalités

- Parcours modulaire et progression (chapitres / modules)
- Quiz chronométrés et résultats détaillés
- Lobbys multijoueur et battles en temps réel
- Profil, XP, streaks et classement
- Notifications in-app (avec mock invité hors compte)
- Paramètres persistés (local + Firestore si connecté)
- Navigation shell avec barre du bas glassmorphism
- Thème sombre, glassmorphism et animations (`flutter_animate`)

## Architecture

- Découpage par feature : **data** (repositories, modèles), **presentation** (écrans, widgets)
- **GoRouter** pour la navigation déclarative et les transitions personnalisées
- **Firebase** (Auth + Firestore) avec repli mock / données locales selon les dépôts
- **Riverpod** : `ProviderScope` à la racine ; les providers peuvent être ajoutés au fil du projet
- **flutter_animate** pour les micro-interactions sur listes et cartes

## Structure du projet (`lib/`)

| Dossier | Rôle |
|--------|------|
| `lib/core/` | Thème, router, widgets partagés (bottom nav), utilitaires |
| `lib/data/repositories/` | Dépôts transverses (utilisateur, quiz, etc.) |
| `lib/features/auth/` | Connexion, inscription, `AuthRepository` |
| `lib/features/home/` | Accueil, tips, raccourcis modules |
| `lib/features/parcours/` | Parcours / formations |
| `lib/features/quiz/` | Quiz, sessions, résultats |
| `lib/features/lobby/` | Liste lobbys, détail, battle |
| `lib/features/notifications/` | Écran et repository notifications |
| `lib/features/settings/` | Paramètres et persistance |
| `lib/features/profil/` | Profil utilisateur |
| `lib/features/classement/` | Classement / leaderboard |
| `lib/features/splash/` | Écran de démarrage |
| `lib/shared/widgets/` | Boutons, cartes, champs réutilisables |

## Installation

**Prérequis**

- Flutter 3.x (SDK `>=3.5.0`)
- Compte Firebase et CLI si vous régénérez les options (le fichier `lib/firebase_options.dart` est déjà présent)

**Étapes**

```bash
flutter pub get
flutter run
```

La configuration Firebase est fournie via `firebase_options.dart` ; en cas de nouveau projet Firebase, régénérez ce fichier avec FlutterFire CLI.

## Tests

```bash
flutter test
```

| Suite | Contenu |
|--------|---------|
| `test/unit/profile_repository_test.dart` | Notifications mock invité, règles `UserProfile` (niveau / rang), `ProfileRepository` |
| `test/unit/settings_repository_test.dart` | Defaults, sauvegarde / chargement SharedPreferences, reset |
| `test/unit/lobby_model_test.dart` | `LobbyModel`, `canJoin`, enchaînement des phases battle |
| `test/widget/login_screen_test.dart` | Champs, CTA, validation formulaire (thème + GoRouter) |
| `test/widget/lobby_card_test.dart` | Carte lobby : titre, statut, `onTap` |

**Dépendances de test** : `fake_cloud_firestore`, `firebase_auth_mocks` (pas de mockito).

## Design System

| Nom | Hex | Usage |
|-----|-----|--------|
| Fond principal | `#0A0E1A` | Scaffold sombre |
| Violet brand | `#6C3CE1` | Accent, SnackBar, CTA |
| Cyan | `#00BCD4` | Accents secondaires |

**Composants** : cartes glassmorphism (`EskoliaCard`), bottom navigation pill (`EskoliaBottomNav`), SnackBar flottante violette (`showEskoliaSnackBar`), transitions de page fade + slide (`eskoliaTransitionPage`).

## Screens (routes GoRouter)

| Route | Écran |
|-------|--------|
| `/splash` | Splash |
| `/login` | Connexion |
| `/register` | Inscription |
| `/home` | Accueil (shell) |
| `/parcours` | Parcours (shell) |
| `/lobbys` | Liste des lobbys (shell) |
| `/profil` | Profil (shell), query optionnelle `?uid=` |
| `/leaderboard` | Classement (shell) |
| `/classement` | Redirige vers `/leaderboard` |
| `/lobby/:id` | Détail lobby |
| `/quiz/:sessionId` | Quiz (ex. `/quiz/daily`) |
| `/notifications` | Notifications |
| `/settings` | Paramètres |

## Roadmap

- Tuteur IA contextuel sur les erreurs de quiz
- Mode offline (cache Hive + synchro)
- Notifications push réelles (FCM) branchées sur Firestore
- Classement temps réel et ligues saisonnières
- Accessibilité (tailles de police, contrastes, lecteurs d'écran)
- Internationalisation complète (ARB + locales)
