# Eskolia — Structure Firebase / Firestore

> Dernière mise à jour : 2026-05-07  
> Firebase Project ID : `eskolia`  
> Region base de données : `europe-west1`

---

## Firebase Authentication

- Méthode : **Email/Password**
- Persistence web : restaurée au boot via `AuthRepository.restoreWebAuthPersistenceIfNeeded()`
- Connexion par pseudo : un lookup dans `login_aliases` retourne l'email, puis Firebase Auth connecte par email
- `AuthRefreshNotifier` écoute `authStateChanges()` et déclenche les redirects GoRouter

---

## Collections Firestore

### `login_aliases/{aliasId}`

Mapping pseudo → email pour la connexion par pseudo.

| Champ | Type | Description |
|-------|------|-------------|
| `uid` | String | UID Firebase Auth de l'utilisateur |
| `email` | String | Email du compte |

**Règles :**
- `get` : public (sans auth), si `aliasId` entre 2 et 64 chars
- `list` : interdit
- `create` : utilisateur authentifié, doit être le propriétaire (`uid == auth.uid`)
- `update/delete` : propriétaire seulement

---

### `users/{userId}`

Profil complet d'un utilisateur.

| Champ | Type | Description |
|-------|------|-------------|
| `username` | String | Pseudo affiché |
| `email` | String | Email du compte |
| `interestSections` | Array\<String\> | Sections choisies à l'inscription (ex. `['S01', 'S03']`) |
| `level` | Number | Niveau calculé (XP ~/ 1000 + 1) |
| `xp` | Number | XP total accumulé |
| `xpThisWeek` | Number | XP gagné cette semaine (clé ISO reset chaque lundi) |
| `streak` | Number | Nombre de jours consécutifs de connexion |
| `currentChapter` | Number | Index du chapitre en cours |
| `currentModule` | Number | Index du module en cours |
| `totalQuizzesPlayed` | Number | Nombre total de sessions quiz terminées |
| `totalWins` | Number | Nombre de sessions avec score ≥ 60 % |
| `battleWins` | Number | Victoires en bataille multijoueur |
| `badges` | Array\<String\> | IDs des badges débloqués (ex. `['badge_daily_triple', 'super_badge_tip_diploma']`) |
| `lastLogin` | Timestamp | Dernière connexion (pour calcul streak) |
| `createdAt` | Timestamp | Date de création du compte |
| `role` | String | `'user'` \| `'moderator'` \| `'admin'` |

**Règles :**
- `read` : tout utilisateur authentifié (nécessaire pour le leaderboard et les profils publics)
- `create/update` : propriétaire seulement (`isSelf(userId)`)
- `delete` : interdit

#### `users/{userId}/quizResults/{resultId}`

Historique des résultats de quiz (append-only).

| Champ | Type | Description |
|-------|------|-------------|
| `sessionId` | String | ID de la session |
| `score` | Number | Score global (0.0–1.0) |
| `totalQuestions` | Number | Nombre de questions |
| `completedAt` | Timestamp | Date de complétion |
| `mode` | String | Mode de jeu (standard, survival…) |

**Règles :** `read/create` propriétaire seulement, `update/delete` interdits.

#### `users/{userId}/settings/{docId}`

Paramètres utilisateur (thème, notifications, préférences).

**Règles :** `read/write` propriétaire seulement.

#### `users/{userId}/notifications/{docId}`

Notifications in-app (achievements débloqués, messages système).

| Champ | Type | Description |
|-------|------|-------------|
| `title` | String | Titre de la notification |
| `body` | String | Corps du message |
| `type` | String | Type (achievement, system, battle…) |
| `read` | Boolean | Lu ou non |
| `createdAt` | Timestamp | Date de création |

**Règles :** `read/write` propriétaire seulement.

---

### `formations/{docId}`

Métadonnées légères des formations disponibles. Le contenu réel est dans les assets.

| Champ | Type | Description |
|-------|------|-------------|
| `title` | String | Titre de la formation |
| `slug` | String | Identifiant (ex. `optimus`) |
| `sections` | Number | Nombre de sections |
| `updatedAt` | Timestamp | Dernière mise à jour |

**Règles :**
- `read` : tout utilisateur authentifié
- `write` : staff seulement

---

### `sessions/{sessionId}`

Sessions de quiz solo (créées avant le lancement, lues pendant la partie).

| Champ | Type | Description |
|-------|------|-------------|
| `userId` | String | UID du propriétaire |
| `title` | String | Titre de la session |
| `questions` | Array\<Map\> | Liste des questions (format QuizQuestion serialisé) |
| `currentIndex` | Number | Index courant |
| `userScores` | Array\<Number?\> | Scores par question (null = non répondu) |
| `startTime` | Timestamp | Heure de début |
| `runMode` | String | `'standard'` \| `'survival'` |
| `timed` | Boolean | Chrono activé |
| `createdAt` | Timestamp | Date de création |

**Règles :**
- `create` : utilisateur authentifié + `userId == auth.uid`
- `read/update` : propriétaire seulement
- `delete` : interdit

---

### `battles/{battleId}`

Duels 1v1 (ancien système, potentiellement remplacé par le sous-document `battle` dans `lobbies`).

| Champ | Type | Description |
|-------|------|-------------|
| `player1Id` | String | UID joueur 1 |
| `player2Id` | String | UID joueur 2 |
| `player1Name` | String | Pseudo joueur 1 |
| `player2Name` | String | Pseudo joueur 2 |
| `player1Score` | Number | Score joueur 1 |
| `player2Score` | Number | Score joueur 2 |
| `questions` | Array\<Map\> | Questions serialisées |
| `currentQuestionIndex` | Number | Index courant |
| `status` | String | `'waiting'` \| `'in_progress'` \| `'finished'` |
| `winnerId` | String? | UID du vainqueur |
| `moduleId` | String | Module/thème source des questions |
| `createdAt` | Timestamp | Date de création |

**Règles :** `read/write` tout utilisateur authentifié.

---

### `lobbies/{lobbyId}`

Salle multijoueur avec état de la bataille imbriqué.

#### Document principal

| Champ | Type | Description |
|-------|------|-------------|
| `title` | String | Nom du lobby |
| `subject` | String | Sujet (ex. `tip`, `optimus`, `arena`) |
| `hostName` | String | Pseudo du créateur |
| `hostAvatar` | String | Emoji avatar host |
| `hostId` | String | UID du créateur |
| `currentPlayers` | Number | Nombre de joueurs actuellement dans le lobby |
| `maxPlayers` | Number | Max joueurs (défaut 30) |
| `status` | String | `'waiting'` \| `'in_progress'` \| `'finished'` |
| `difficulty` | String | `'facile'` \| `'moyen'` \| `'difficile'` |
| `quizId` | String | Source des questions (`tip`, `arena`, ID de module) |
| `gameMode` | String | `'mastery'` \| `'survival'` |
| `questionCount` | Number | Nombre de questions (5–50) |
| `joinCode` | String | Code 6 chars pour rejoindre (ex. `AB3XY7`) |
| `isPrivate` | Boolean | Lobby visible dans la liste publique |
| `timed` | Boolean | Chrono activé |
| `difficultyFilters` | Array\<String\> | Filtres appliqués au tirage |
| `questionAssetPaths` | Array\<String\> | Paths des assets quiz source |
| `playerIds` | Array\<String\> | UIDs des joueurs présents |
| `playerMeta` | Array\<Map\> | `[{userId, displayName, avatar}]` |
| `createdAt` | Timestamp | Date de création |

#### Sous-document `battle` (imbriqué dans le document lobby)

Présent quand `status == 'in_progress'`. Mis à jour en temps réel par le host.

| Champ | Type | Description |
|-------|------|-------------|
| `phase` | String | `'countdown'` \| `'question'` \| `'judgment'` \| `'result'` \| `'finished'` |
| `currentQuestion` | Number | Index de la question courante |
| `totalQuestions` | Number | Nombre total de questions |
| `questions` | Array\<Map\> | Questions serialisées (BattleQuestion) |
| `players` | Array\<Map\> | État de chaque joueur (voir ci-dessous) |
| `timed` | Boolean | Chrono activé |
| `gameMode` | String | Mode de jeu |
| `revealedIndices` | Number | Nombre d'indices révélés (type `diagnostic_indices`) |

#### Sous-document `battle.players[i]`

| Champ | Type | Description |
|-------|------|-------------|
| `userId` | String | UID du joueur |
| `displayName` | String | Pseudo |
| `avatar` | String | Emoji avatar |
| `score` | Number | Score cumulé (points flottants) |
| `hasAnswered` | Boolean | Réponse soumise pour la question courante |
| `isConnected` | Boolean | Connexion active |
| `lastAnswerText` | String? | Dernière réponse soumise |
| `lives` | Number | Vies restantes (survival uniquement) |
| `eliminated` | Boolean | Éliminé (survival, 0 vie) |
| `lastJudgment` | Boolean? | `null` = en attente, `true` = validé, `false` = refusé |
| `lastScore` | Number | Points gagnés à la dernière question |

**Règles :** `read/write` tout utilisateur authentifié.

---

### `community_tips/{tipId}`

Astuces créées par la communauté pour les modules du parcours.

| Champ | Type | Description |
|-------|------|-------------|
| `authorId` | String | UID de l'auteur |
| `authorName` | String | Pseudo de l'auteur |
| `moduleId` | String | Module Optimus concerné |
| `body` | String | Contenu de l'astuce (texte/markdown) |
| `kind` | String | Type d'astuce (voir `LaboTipKind`) |
| `status` | String | `'pending'` \| `'approved'` \| `'rejected'` |
| `upCount` | Number | Votes positifs |
| `downCount` | Number | Votes négatifs |
| `voters` | Map\<String, Boolean\> | `{uid: true/false}` votes par utilisateur |
| `createdAt` | Timestamp | Date de création |

**Règles :**
- `read` : tout utilisateur authentifié
- `create` : authentifié + `authorId == auth.uid`
- `update` : staff OU modification de `upCount/downCount/voters` seulement (pas de modification du contenu)
- `delete` : interdit

---

### `labo_question_drafts/{draftId}`

Propositions de questions soumises par la communauté pour revue par le staff.

| Champ | Type | Description |
|-------|------|-------------|
| `authorId` | String | UID de l'auteur |
| `authorName` | String | Pseudo de l'auteur |
| `type` | String | Type de question (`classic`, `sequence`, etc.) |
| `question` | String | Énoncé |
| `answer` | String | Réponse correcte |
| `explanation` | String? | Explication |
| `difficultyBucket` | String | Difficulté estimée |
| `theme` | String? | Thème concerné |
| `status` | String | `'pending'` \| `'approved'` \| `'rejected'` |
| `reviewNote` | String? | Note du modérateur |
| `createdAt` | Timestamp | Date de soumission |

**Règles :**
- `read` : tout utilisateur authentifié
- `create` : authentifié + `authorId == auth.uid`
- `update` : staff seulement
- `delete` : interdit

---

### `signalements/{reportId}`

Signalements de contenu problématique (question mal formulée, réponse incorrecte, etc.).

| Champ | Type | Description |
|-------|------|-------------|
| `userId` | String | UID du signaleur |
| `questionId` | String | ID de la question signalée |
| `questionText` | String | Texte de la question (snapshot) |
| `kind` | String | Type de problème (voir `QuestionReportKind`) |
| `comment` | String? | Commentaire libre |
| `status` | String | `'pending'` \| `'resolved'` \| `'dismissed'` |
| `createdAt` | Timestamp | Date du signalement |

**Règles :**
- `create` : tout utilisateur authentifié
- `read` : staff OU le signaleur lui-même
- `update` : staff seulement
- `delete` : interdit

---

### `leaderboard_daily/{dayKey}/scores/{userId}`

Classement quotidien du quiz du jour. `dayKey` = date YYYYMMDD (ex. `20260507`).

| Champ | Type | Description |
|-------|------|-------------|
| `username` | String | Pseudo (1–64 chars) |
| `score` | Number (int) | Nombre de bonnes réponses |
| `total` | Number (int) | Nombre total de questions (≥ 1) |
| `updatedAt` | Timestamp | Dernière mise à jour |

**Règles strictes :**
- `read` : tout utilisateur authentifié
- `create` : propriétaire seulement, champs validés, `score ≤ total`, `score ≥ 0`
- `update` : propriétaire seulement, `score ≥ score_actuel` (pas de régression), même validation
- `delete` : interdit

---

## Fonctions Firestore Security Rules

```javascript
function signedIn()       // request.auth != null
function isSelf(uid)      // signedIn() && request.auth.uid == uid
function userDocExists()  // exists(/users/{auth.uid})
function userRole()       // get(/users/{auth.uid}).data.role
function isStaff()        // signedIn() && role in ['admin','moderator']
```

---

## Firebase Storage

Utilisé pour les images du curriculum Optimus (section images embarquées) et potentiellement les avatars utilisateurs futurs.

**Bucket :** `eskolia.firebasestorage.app`

---

## Hive (stockage local)

Utilisé pour les données persistantes côté client sans passer par Firestore :

| Repository | Contenu |
|-----------|---------|
| `LacunesRepository` | Questions échouées (pool lacunes) |
| `RevisionPoolRepository` | Questions épinglées (pool 📌) |
| `SurvivalHighScoresRepository` | Meilleurs scores survival |
| `PracticalMissionsProgressRepository` | Progression missions TP |
| `OnboardingPrefs` | Flag onboarding vu |
