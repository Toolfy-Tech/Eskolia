# Eskolia — Inventaire des écrans

> Dernière mise à jour : 2026-05-07  
> Statuts : ✅ Fonctionnel | ⚠️ Partiel | ❌ Cassé/Absent

---

## Auth

| Route | Statut | Fichier source | Description |
|-------|--------|---------------|-------------|
| `/splash` | ✅ | `lib/features/splash/splash_screen.dart` | Écran de démarrage avec logo Eskolia. Redirige vers `/home` (auth) ou `/login` (non-auth) après l'init Firebase. |
| `/login` | ✅ | `lib/features/auth/login_screen.dart` | Connexion par email ou pseudo (via `login_aliases`). Gère la persistence web. |
| `/register` | ✅ | `lib/features/auth/register_screen.dart` | Inscription avec email, pseudo unique, mot de passe, et sélection des sections d'intérêt. |
| `/login/forgot` | ✅ | `lib/features/auth/forgot_password_screen.dart` | Envoi d'un email de réinitialisation de mot de passe via Firebase Auth. |
| `/onboarding` | ✅ | `lib/features/onboarding/presentation/onboarding_screen.dart` | Présentation de l'app post-inscription (slides de bienvenue). |

---

## Navigation principale (Shell)

| Route | Statut | Fichier source | Description |
|-------|--------|---------------|-------------|
| `/home` | ✅ | `lib/features/home/home_screen.dart` | Accueil : quêtes quotidiennes, XP/streak, hub rapide vers quiz/parcours/multi. Section actualités tech (flux RSS via Dio). |
| `/solo` | ✅ | `lib/features/solo/presentation/solo_screen.dart` | Hub entraînement solo : accès Quiz solo, Révisions, Flashcards, TP, Vrai/Faux. |
| `/parcours` | ✅ | `lib/features/parcours/presentation/parcours_screen.dart` | Liste les formations disponibles (Optimus). Expandable par formation. Supporte `?focus=formationId` pour auto-expand. |
| `/leaderboard` | ✅ | `lib/features/classement/presentation/leaderboard_screen.dart` | Classement global (XP) + classement quotidien (quiz du jour). Tabs ou scroll. |
| `/labo` | ✅ | `lib/features/labo/presentation/labo_hub_screen.dart` | Hub communautaire : accès création questions/tips, signalements propres, tips approuvés. |
| `/achievements` | ✅ | `lib/features/economy/presentation/achievements_screen.dart` | Liste des 32 succès avec état débloqué/non. Badges associés affichés. |
| `/docs` | ✅ | `lib/features/docs/presentation/docs_screen.dart` | Mini-formations RGPD, CNIL, ANSSI — lecture markdown avec dialog de cours interactif. |
| `/profil` | ✅ | `lib/features/profil/presentation/profile_screen.dart` | Profil propre : niveau, XP, streak, badges, stats quiz, historique. |
| `/settings` | ✅ | `lib/features/settings/presentation/settings_screen.dart` | Paramètres : thème (prévu), notifications, déconnexion. |
| `/admin` | ✅ | `lib/features/admin/presentation/admin_home_screen.dart` | Hub back-office staff : liens vers drafts, tips, signalements. Caché aux non-staff. |

---

## Quiz Solo

| Route | Statut | Fichier source | Description |
|-------|--------|---------------|-------------|
| `/solo/quiz-solo` | ✅ | `lib/features/quiz/screens/quiz_solo_setup_screen.dart` | Setup quiz solo : choix du track/section, nombre de questions, mode timed. Lance `/quiz/run`. |
| `/quiz/setup` | ✅ | `lib/features/quiz/screens/quiz_setup_screen.dart` | Setup quiz générique (depuis menu principal quiz). Sélection scope (parcours/thème/labo). |
| `/quiz/quick` | ✅ | `lib/features/quiz/screens/quiz_quick_screen.dart` | Quiz rapide 5 questions tirées aléatoirement, possibilité de filtrer par track (`?track=`). |
| `/quiz/survival` | ✅ | `lib/features/quiz/screens/quiz_survival_screen.dart` | Mode survival : 3 vies, perte de vie à chaque mauvaise réponse, game over à 0 vie. |
| `/quiz/run` | ✅ | `lib/features/quiz/screens/quiz_screen.dart` | Écran de jeu principal (plein écran). Gère tous les types : classic, sequence, ticket, diagnostic_indices. Timer 30 s. |
| `/quiz/:sessionId` | ✅ | `lib/features/quiz/screens/quiz_screen.dart` | Même écran, chargement de session par ID (depuis Firestore `sessions`). |
| `/quiz/revision-lacunes` | ✅ | `lib/features/quiz/screens/revision_lacunes_screen.dart` | Quiz sur les questions échouées (lacunes stockées en local via Hive). Filtre par track optionnel. |
| `/revision-pool` | ✅ | `lib/features/quiz/screens/revision_pool_screen.dart` | Gestion du pool 📌 (questions épinglées). Mode browse ou lancement direct en session. |
| `/quiz/epreuve-finale-tip` | ✅ | `lib/features/quiz/screens/grand_finale_tip_screen.dart` | Épreuve finale parcours TIP : exam blanc, débloque achievement + super badge. |
| `/quiz/epreuve-finale-optimus` | ✅ | `lib/features/quiz/screens/grand_finale_optimus_screen.dart` | Épreuve finale parcours Optimus (O01–O06 + finale 80 %). Débloque super badge Diplômé. |
| `/solo/revision` | ✅ | `lib/features/solo/presentation/solo_revision_menu_screen.dart` | Menu révisions : accès Lacunes, Pool 📌, Quiz rapide. |

---

## Flashcards

| Route | Statut | Fichier source | Description |
|-------|--------|---------------|-------------|
| `/flashcards` | ✅ | `lib/features/flashcards/presentation/flashcards_hub_screen.dart` | Hub flashcards : accès rapide, solo setup, decks disponibles. |
| `/flashcards/quick` | ✅ | `lib/features/flashcards/presentation/flashcard_quick_screen.dart` | Session flashcards rapide (flip cards, swipe left/right). |
| `/flashcards/solo-setup` | ✅ | `lib/features/flashcards/presentation/flashcard_solo_setup_screen.dart` | Config session flashcards solo : deck, mode timed/survival. |
| `/flashcards/session` | ✅ | `lib/features/flashcards/presentation/flashcard_session_screen.dart` | Session de jeu flashcards (plein écran). Requiert `FlashcardSessionRouteArgs` en extra. |

---

## Multijoueur

| Route | Statut | Fichier source | Description |
|-------|--------|---------------|-------------|
| `/lobbys` | ✅ | `lib/features/lobby/presentation/lobbys_screen.dart` | Liste des lobbies publics (stream Firestore). Filtrage par statut et mode. |
| `/lobby/:id` | ✅ | `lib/features/lobby/lobby_detail_screen.dart` | Salle d'attente d'un lobby. Affiche joueurs connectés, bouton Rejoindre/Démarrer (host). |
| `/lobby/:id/battle` | ✅ | `lib/features/lobby/presentation/battle_screen.dart` | Session bataille temps réel (stream Firestore). Phases : countdown → question → judgment → result → finished. |

---

## Parcours

| Route | Statut | Fichier source | Description |
|-------|--------|---------------|-------------|
| `/cours/:moduleId` | ✅ | `lib/features/parcours/presentation/chapter_lesson_screen.dart` | Leçon d'un module du parcours Optimus : affichage markdown avec `EskoliaLessonMarkdown`. Images embarquées. |

---

## TP (Travaux Pratiques)

| Route | Statut | Fichier source | Description |
|-------|--------|---------------|-------------|
| `/tp` | ✅ | `lib/features/solo/presentation/practical_exercises_hub_screen.dart` | Hub TP : liste des tracks disponibles (ex. Windows, réseau). |
| `/tp/:trackId` | ✅ | `lib/features/solo/presentation/practical_track_screen.dart` | Contenu d'un TP : énoncé markdown + ressources. |
| `/tp/:trackId/missions` | ✅ | `lib/features/solo/presentation/practical_missions_screen.dart` | Missions d'un TP avec progression locale (Hive). |

---

## Labo communautaire

| Route | Statut | Fichier source | Description |
|-------|--------|---------------|-------------|
| `/labo/create-question` | ✅ | `lib/features/labo/presentation/labo_create_question_screen.dart` | Formulaire de soumission d'une nouvelle question au Labo (sauvegardée dans `labo_question_drafts`). |
| `/labo/create-tip` | ✅ | `lib/features/labo/presentation/labo_create_tip_screen.dart` | Formulaire de soumission d'une astuce communautaire (`community_tips`). |
| `/labo/reports` | ✅ | `lib/features/labo/presentation/labo_reports_screen.dart` | Historique des signalements envoyés par l'utilisateur courant. |

---

## Admin (Staff seulement)

| Route | Statut | Fichier source | Description |
|-------|--------|---------------|-------------|
| `/admin` | ✅ | `lib/features/admin/presentation/admin_home_screen.dart` | Hub back-office avec accès aux 3 modules de modération. |
| `/admin/drafts` | ✅ | `lib/features/admin/presentation/admin_drafts_screen.dart` | Liste et modération des questions soumises au Labo (approve/reject). |
| `/admin/tips` | ✅ | `lib/features/admin/presentation/admin_tips_screen.dart` | Liste et modération des astuces communautaires. |
| `/admin/signalements` | ✅ | `lib/features/admin/presentation/admin_signalements_screen.dart` | Gestion des signalements de contenu (questions, tips). |

---

## Profil & Notifications

| Route | Statut | Fichier source | Description |
|-------|--------|---------------|-------------|
| `/profil` | ✅ | `lib/features/profil/presentation/profile_screen.dart` | Profil propre de l'utilisateur connecté. |
| `/profil/:uid` | ✅ | `lib/features/profil/presentation/profile_screen.dart` | Profil public d'un autre joueur (uid passé en path param). |
| `/notifications` | ✅ | `lib/features/notifications/presentation/notifications_screen.dart` | Liste des notifications in-app (stream `users/{uid}/notifications`). |

---

## Modes spéciaux

| Route | Statut | Fichier source | Description |
|-------|--------|---------------|-------------|
| `/true-false` | ✅ | `lib/features/true_false/presentation/true_false_swipe_screen.dart` | Mode Vrai/Faux : swipe left = Faux, swipe right = Vrai. Basé sur les questions du catalogue. |

---

## Fichiers obsolètes (doublons — ne pas modifier)

Ces fichiers existent encore à la racine de leur feature mais ne sont plus importés par le router :

- `lib/features/auth/forgot_password_screen.dart` (remplacé par `auth/presentation/`)
- `lib/features/auth/login_screen.dart`
- `lib/features/auth/register_screen.dart`
- `lib/features/home/home_screen.dart` (remplacé par `home/presentation/home_screen.dart`)
- `lib/features/lobby/lobby_detail_screen.dart` ← **ATTENTION : c'est celui-là qui est dans le router** (pas `lobby/presentation/`)
- `lib/features/lobby/lobby_list_screen.dart` ← **importé dans le router**
- `lib/features/lobby/lobbys_screen.dart`
- `lib/features/notifications/notifications_screen.dart` ← **importé dans le router**
- `lib/features/parcours/parcours_screen.dart`
- `lib/features/profil/profil_screen.dart`
- `lib/features/quiz/quiz_screen.dart`
- `lib/features/quiz/quiz_setup_screen.dart`
- `lib/features/settings/settings_screen.dart` ← **importé dans le router**
