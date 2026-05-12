# Eskolia — État des fonctionnalités

> Dernière mise à jour : 2026-05-07  
> Statuts : ✅ Fonctionnel | ⚠️ Partiel | ❌ Cassé/Absent | 🔧 En cours

---

## Quiz Solo (Maîtrise)

**Statut global : ✅ Fonctionnel**

### Ce qui fonctionne
- Setup quiz solo (`/solo/quiz-solo`) : sélection track Optimus/thème, nombre de questions
- Setup quiz générique (`/quiz/setup`) : sélection par scope (parcours, thèmes, labo)
- Quiz rapide 5 questions (`/quiz/quick`) avec filtre par track
- Écran de jeu principal (`/quiz/run`) avec tous les types de questions :
  - `classic` — Question + réponse texte libre, auto-évaluation
  - `sequence` — Remettre des étapes dans l'ordre
  - `diagnostic_indices` — Indices progressifs (score dégradé selon indices utilisés)
  - `ticket` — Checklist à cocher (score proportionnel)
- Timer 30 secondes par question (désactivable)
- Recap post-question (explication)
- Écran de résultats avec score détaillé
- Sync lacunes automatique (Hive local) : questions échouées → pool lacunes

### Ce qui est partiel
- Score de session non persisté en Firestore dans tous les cas (dépend du mode de lancement)
- `postQuestionRecapEnabled` configurable mais pas toujours exposé dans l'UI de setup

---

## Mode Survival

**Statut global : ✅ Fonctionnel**

### Ce qui fonctionne
- 3 vies par session
- Perte de vie à chaque mauvaise réponse (score < 0.5)
- Game over si 0 vie
- Filtre par track (`?track=`)
- Compatible avec tous les types de questions

---

## Révisions (Lacunes + Pool)

**Statut global : ✅ Fonctionnel**

### Ce qui fonctionne
- **Lacunes** (`/quiz/revision-lacunes`) : questions où l'utilisateur a échoué, stockées localement en Hive via `LacunesRepository`
- **Pool 📌** (`/revision-pool`) : questions épinglées manuellement par l'utilisateur
  - Mode browse : voir et gérer le pool
  - Mode launch : lancer une session directement depuis le pool
- Menu révisions (`/solo/revision`) : accès centralisé lacunes + pool + quiz rapide

---

## Flashcards

**Statut global : ✅ Fonctionnel**

### Ce qui fonctionne
- Hub flashcards avec accès aux decks
- Session flashcards (flip card 3D, swipe ou bouton)
- Mode rapide (5 cartes aléatoires)
- Setup solo avec options timed/survival
- `FlashcardSessionScreen` en plein écran avec `FlashcardSessionRouteArgs`
- Achievement débloqué à la 1ère session (`first_flash`)

### Ce qui est partiel
- Contenu des decks limité aux thèmes disponibles dans assets
- Pas de deck personnalisé créé par l'utilisateur

---

## Multijoueur (Lobbies + Battle)

**Statut global : ✅ Fonctionnel**

### Ce qui fonctionne
- Liste des lobbies publics en temps réel (stream Firestore `lobbies`)
- Création de lobby avec : titre, sujet, mode de jeu, nombre de questions, difficulté, code de jointure (6 chars), mode privé
- Rejoindre un lobby par code ou depuis la liste
- Deux modes de jeu :
  - **Mastery** (`mastery`) : questions libres, correction collective par le host (phase `judgment`)
  - **Arena/Survival** (`survival`) : 3 vies, élimination si 0 vie
- Phases de bataille temps réel : `countdown` → `question` → `judgment` → `result` → `finished`
- Soumission de réponse par joueur, passage auto à `judgment` si tous ont répondu
- Score cumulé, classement en temps réel
- Indices progressifs (type `diagnostic_indices`) gérés en multi
- Reset bataille pour rejeu

### Ce qui est partiel
- Host judge manuel (pas d'auto-correction IA)
- Pas de kick/ban joueur
- Pas de rejointure en cours de partie

### Ce qui est absent
- Chat en jeu
- Notifications push pour "la partie commence"

---

## Parcours Optimus

**Statut global : ✅ Fonctionnel**

### Ce qui fonctionne
- Parcours structuré en 6 sections (hardware, OS, réseau, maintenance, cybersécurité, IA)
- Chaque section contient des chapitres (assets markdown + images embarqués)
- `ParcoursScreen` : liste des formations avec expandable
- `ChapterLessonScreen` : rendu markdown complet avec images, code, liens
- Support `?focus=formationId` pour auto-expand depuis un deep link
- Épreuve finale Optimus (`/quiz/epreuve-finale-optimus`) : exam de fin de parcours avec score 80 % requis
- Récompenses de section badges (`parcours_section_badge_rewards.dart`)

### Ce qui est partiel
- Progression des modules non persistée de façon granulaire dans Firestore (tracking local)
- `formations` Firestore utilisé comme déclencheur léger, pas comme source principale du contenu

---

## Achievements & Badges

**Statut global : ✅ Fonctionnel**

### Catalogue (32 achievements)
- **Quiz Solo** : first_quiz, quiz_10, quiz_50, quiz_100, quiz_wins_10, quiz_wins_50, quiz_flawless_big
- **Révisions** : first_revision_quiz, revision_quiz_10, first_lacunes_quiz, lacunes_grinder
- **Quiz du jour** : first_daily_quiz, daily_quiz_7
- **Pool** : pool_25_pins, pool_75_pins
- **Flashcards** : first_flash, flash_sessions_20, flash_sessions_75
- **Survival** : survival_perfect
- **Multijoueur** : battle_first, battle_win_first, battle_wins_10
- **Labo** : labo_first_report, labo_first_draft, labo_first_tip
- **Quêtes** : daily_trio, first_parcours_day
- **Niveau** : level_15, level_30
- **Streak** : streak_week_fire, streak_month
- **Examens finals** : tip_grand_finale, optimus_grand_finale

### Ce qui fonctionne
- `AchievementsScreen` liste tous les achievements avec état débloqué/non
- Déblocage automatique via `AchievementTriggers` (appelé après les actions clés)
- Badges liés (`linkedBadgeId`) écrits dans `users.badges` Firestore
- Super badges : `super_badge_tip_diploma`, `super_badge_optimus_diploma`, `super_badge_arc_learner`

---

## Leaderboard

**Statut global : ✅ Fonctionnel**

### Ce qui fonctionne
- Classement global par XP (`users` collection)
- Classement quotidien (`leaderboard_daily/{dayKey}/scores/{uid}`)
  - Clé de jour = 8 chars (YYYYMMDD)
  - Score = nombre de bonnes réponses / total
  - Mise à jour seulement si le nouveau score est meilleur
- Règles Firestore strictes (pas de régression de score)

### Ce qui est partiel
- Pas de pagination (charger plus) — limite Firestore par défaut
- Classement temps réel non implémenté (lecture one-shot + refresh manuel)

---

## Labo communautaire

**Statut global : ✅ Fonctionnel**

### Ce qui fonctionne
- Création de questions (`labo_question_drafts`) : formulaire avec type, question, réponse, explication, difficulté
- Création de tips (`community_tips`) : astuces texte/markdown pour un module
- Vote up/down sur les tips (règles Firestore : seul `voters`, `upCount`, `downCount` modifiables)
- Signalement de contenu (`signalements`) depuis les questions de quiz
- Historique des signalements propres (`/labo/reports`)

### Ce qui est absent
- Les questions approuvées du Labo ne s'intègrent pas encore automatiquement dans les quiz (pipeline de review admin → intégration assets)

---

## Profil utilisateur

**Statut global : ✅ Fonctionnel**

### Ce qui fonctionne
- Profil propre et profil public (`/profil/:uid`)
- Affichage : niveau, XP (barre de progression), streak, badges, stats (totalQuizzesPlayed, totalWins, battleWins)
- `UserStatusPill` réutilisable dans TopBar

### Ce qui est partiel
- Pas d'édition de profil (avatar, bio)
- Pas de liste d'amis ou de suivi

---

## Actualités tech (Home)

**Statut global : ✅ Fonctionnel**

### Ce qui fonctionne
- Flux RSS de 6+ sources IT (RDR-IT, SysKB, Tech2Tech, IT-Connect, CERT-FR, etc.) chargés via Dio
- Affichage dans `TechNewsSection` avec tri par date
- Liens ouverts via `url_launcher`
- Config sources dans `data/home/tech_feeds.json`

---

## Quêtes quotidiennes

**Statut global : ✅ Fonctionnel**

### Ce qui fonctionne
- 3 quêtes par jour : Quiz, Parcours, Flashcards
- Récompense XP à la complétion (`DailyQuestRewardService`)
- Achievement `daily_trio` si les 3 sont complétées le même jour

---

## Notifications in-app

**Statut global : ✅ Fonctionnel (in-app seulement)**

### Ce qui fonctionne
- Lecture des notifications depuis `users/{uid}/notifications` (Firestore)
- Affichage dans `NotificationsScreen`

### Ce qui est absent
- Push notifications réelles (FCM non implémenté — roadmap)

---

## Mini-formations réglementaires (Docs)

**Statut global : ✅ Fonctionnel**

### Ce qui fonctionne
- 3 mini-formations embarquées en markdown : RGPD, CNIL, ANSSI
- `DocsScreen` : liste et accès
- `DocsMiniCourseDialog` : lecture interactive avec navigation slides

---

## TP (Travaux Pratiques)

**Statut global : ✅ Fonctionnel**

### Ce qui fonctionne
- Hub TP avec liste des tracks
- Contenu markdown par track
- Missions avec progression locale (Hive)

### Ce qui est partiel
- Contenu TP limité (tracks disponibles dépendent des assets)

---

## Vrai/Faux

**Statut global : ✅ Fonctionnel**

- Mode swipe simple (gauche = faux, droite = vrai)
- Questions issues du catalogue

---

## Paramètres

**Statut global : ⚠️ Partiel**

### Ce qui fonctionne
- Déconnexion
- Accès depuis le profil

### Ce qui est absent
- Changement de thème (roadmap)
- Configuration des notifications
- Langue / i18n

---

## Admin / Modération

**Statut global : ✅ Fonctionnel (staff seulement)**

### Ce qui fonctionne
- `AdminDraftsScreen` : review et approve/reject des questions Labo
- `AdminTipsScreen` : review et approve/reject des community tips
- `AdminSignalementsScreen` : traitement des signalements
- Accès conditionné par `isStaff` (role = 'admin' | 'moderator')
- Bootstrap staff : `staff_bootstrap.dart` pour assigner le rôle via email
- `StaffGateScaffold` : wrapper qui cache l'UI aux non-staff
