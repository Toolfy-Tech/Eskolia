# Eskolia — Audit UI/UX détaillé

> Dernière mise à jour : 2026-05-07  
> Lecture directe du code source — aucune supposition.

---

## 1. Bottom Nav Shell — Structure exacte

### Items dans l'ordre (source : `lib/core/widgets/bottom_nav.dart:91–104`)

| # | Emoji | Label | Route |
|---|-------|-------|-------|
| 1 | 🏠 | Accueil | `/home` |
| 2 | 📚 | Parcours | `/parcours` |
| 3 | 🎯 | Solo | `/solo` |
| 4 | 🛠️ | TP | `/tp` |
| 5 | 🎮 | Multijoueur | `/lobbys` |
| 6 | 🏆 | Classement | `/leaderboard` |
| 7 | 🔬 | Labo | `/labo` |
| 8 | 🏅 | Hauts faits | `/achievements` |
| 9 | 📋 | Docs | `/docs` |
| 10 | 👤 | Profil | `/profil` |
| 11 | ⚙️ | Réglages | `/settings` |
| 12 | 🛡️ | Admin | `/admin` *(affiché seulement si staff)* |

**Total : 11 items publics + 1 staff conditionnel = jusqu'à 12 items.**

### Anatomie visuelle d'un item (`_NavCell`)

```
┌────────────────────────────────┐
│  emoji (26 px inactif / 28 px actif)  │
│  SizedBox(height: 6)                  │
│  label (10.5 px inactif / 11.5 px actif, weight 600→800)  │
│  SizedBox(height: 5)                  │
│  dot cyan (width 26→0, animated 240ms)│
└────────────────────────────────┘
```

- **Item actif :** fond gradient violet tricolore, bordure violet/cyan mixée, `boxShadow` néon violet (blurRadius 18) + cyan (14), emoji 28 px, label gras 11.5 px, dot cyan 26×3 px en bas.
- **Item inactif :** transparent, emoji 26 px, label gris `#64748B` 10.5 px, pas de dot.
- **Transition :** `AnimatedContainer` 240 ms `Curves.easeOutCubic`.
- **Touch feedback :** `InkWell`, `splashColor: primary 18 %`, `highlightColor: primary 8 %`, `borderRadius: 26`.

### Conteneur pill global

```
ClipRRect(radius: 40)
└── BackdropFilter(blur: 22)
    └── Container
        ├── height: 72–110 px (contrainte min/max)
        ├── padding: 10 horizontal + 10 vertical
        ├── gradient: 3 stops (#1E293B 88% → #0F172A 94% → #0B1020 96%)
        ├── border: 1.5 px, violet/glass lerp
        ├── boxShadow:
        │   - primary 32 % blur 28 (glow violet)
        │   - cyan #22D3EE 12 % blur 22
        │   - black 55 % blur 24 (profondeur)
        └── SingleChildScrollView(horizontal)  ← scroll si items > largeur écran
            └── Row des _NavCell
```

**Reserve bottom nav :** `kEskoliaBottomNavReserve = 132 px` — les écrans shell doivent laisser 132 px en bas.

### Comportement navigation

- Tap depuis un écran quiz → dialog de confirmation « Quitter la session ? » avant de naviguer (`isQuizPlaySessionPath()` + `confirmNavigateAwayFromQuiz()`).
- Active index calculé par `_indexForPath()` : match exact ou prefix (`/solo/quiz-solo` → item Solo actif).
- Navigation via `router.go(target)` (pas push — remplace la pile).

---

## 2. TopBar (`EskoliaTopBar`) — Densité info vs lisibilité

Fichier : `lib/core/widgets/top_bar.dart`  
`preferredSize: Size.fromHeight(72)`

### Layout interne (hauteur 72 px)

```
Row(padding: 16 horizontal)
├── _AvatarRing (44×44)                     flex: fixe
│   └── initiale du pseudo, ring gradient bleu→violet
├── SizedBox(width: 10)
├── Expanded(flex: 2) — username              ← ÉCRASE si pseudo long (maxLines:1, ellipsis)
├── Expanded(flex: 4) — _XpSection
│   ├── pill "Niveau N" (11 px bold, border bleu 35%)
│   ├── SizedBox(height: 6)
│   ├── barre XP (height: 6, gradient bleu→violet)
│   └── "X / Y XP" (10 px, blanc 75%)
└── Row — streak
    ├── 🔥 (18 px)
    └── streak count (titleMedium bold orange #F97316)
```

Suivi d'un `_TopBarDivider` — ligne 2 px, gradient bleu→violet→transparent (gauche→droite).

### Observations UI/UX

**Problème densité :** Le flex 2 vs 4 (username vs XP) comprime très vite le pseudo sur mobile. Un pseudo de 10+ chars sera tronqué. Le streak (fire + chiffre) n'a pas de flex, il occupe l'espace résiduel.

**Informations affichées simultanément :** Avatar initiale + pseudo + niveau (pill) + barre XP + XP absolu + streak. **6 éléments d'info dans 72 px de hauteur et 100 % de la largeur.**

**Contraste :** Le "X / Y XP" à blanc 75 % sur fond sombre est lisible mais discret (volontaire — info secondaire).

---

## 3. `UserStatusPill` — Composant alternatif profil

Fichier : `lib/shared/widgets/user_status_pill.dart`

```
ClipRRect(radius: 28)
└── BackdropFilter(blur: 14)
    └── Container(padding: 12H + 10V)
        ├── Stack — avatar 44×44 (gradient violet/cyan)
        │   └── Positioned badge "Niv.X" (9px amber, bottom-right)
        ├── SizedBox(width: 12)
        ├── Expanded — Column
        │   ├── displayName (13 px bold, 1 ligne)
        │   ├── SizedBox(height: 6)
        │   ├── barre XP (7 px, gradient #5B8DEF → #6C63FF → #00BCD4)
        │   └── "inLevel / 1000 XP" (10 px, blanc 55%)
        └── Column — streak
            ├── 🔥 (18 px)
            └── streak (13 px orange, bold 800)
```

**Différence avec TopBar :** Le pill calcule `inLevel = xp % 1000` (XP dans le niveau courant) alors que la TopBar affiche XP total. Le pill est un widget autonome utilisable n'importe où (pas juste dans la barre système).

---

## 4. Écran Home — Hiérarchie visuelle

Fichier : `lib/features/home/presentation/home_screen.dart`

### Structure de page (scroll vertical)

```
Scaffold
└── Stack
    ├── EskoliaAmbientBackground()           ← fond animé derrière tout
    └── SafeArea → ConstrainedBox(max 920px)
        └── SingleChildScrollView
            ├── Section 0 (AnimatedOpacity, delay 0ms)
            │   └── _buildGreetingAndHero
            │       ├── _buildTipsBarAndActions
            │       │   ├── _HomeTipsBanner (expanded)  ← ticker rotatif 9s
            │       │   ├── 🔔 IconButton → /notifications
            │       │   └── ⚙️ IconButton → /settings
            │       ├── SizedBox(height: 12)
            │       ├── Row
            │       │   ├── "Bonjour [username] 👋" (22px bold)
            │       │   └── EskoliaButton "🚀 TEST QUIZ" → /quiz/daily  ⚠️ BOUTON DE TEST TEMP
            │       ├── SizedBox(height: 16)
            │       └── _buildHeroCard (GradientBorderCard)
            │           ├── "Parcours Optimus" (13px slate)
            │           ├── "Continuer ma formation" (18px bold)
            │           └── LinearProgressIndicator (progression tip)
            └── Section 1 (AnimatedOpacity, delay 80ms)
                └── TechNewsSection (flux RSS)
```

### Observations UI/UX

**Ce qui est absent :**
- Les quêtes quotidiennes ne sont PAS affichées sur la HomeScreen. La HomeScreen n'appelle pas `DailyQuestsRepository`. Les quêtes sont accessibles via d'autres routes mais pas mis en avant sur l'accueil.
- Pas de widget XP/niveau sur l'accueil (c'est dans la TopBar ou le UserStatusPill, absents ici aussi).
- Pas d'affichage du streak sur l'accueil.

**Ce qui est présent :**
- `_HomeTipsBanner` : ticker de tips locaux qui rotate toutes les 9 secondes (hauteur 40 px, texte 11 px).
- Hero card progression parcours Optimus (depuis Firestore `formations`).
- `TechNewsSection` : flux RSS en bas de page.
- `EskoliaAmbientBackground` derrière tout le contenu.

**⚠️ Bug UX notable :** Il y a un bouton temporaire "🚀 TEST QUIZ" visible en prod (`context.push('/quiz/daily')`) — la route `/quiz/daily` n'existe pas dans le router, ce qui provoquerait une erreur de navigation.

**Animations :** Deux sections avec `AnimatedOpacity` 300 ms, délai décalé de 80 ms entre elles (stagger léger).

---

## 5. Hub /solo — Launcher fluide ou dead end ?

Fichier : `lib/features/solo/presentation/solo_screen.dart`

### Structure (ListView dans EskoliaShellBody)

```
_SoloTopBar
├── ← IconButton (retour → /home)        ⚠️ LA BARRE NAV EST TOUJOURS VISIBLE
└── titre "Maîtrise Solo"

ListView(padding: hPad horizontal + 24 vertical)
├── _CategoryHeader "CONTENU OFFICIEL" (violet)
├── _SoloMenuCard "Parcours Optimus Mastery" → context.push('/parcours')
├── SizedBox(height: 32)
├── _CategoryHeader "ENTRAÎNEMENT LIBRE" (cyan)
├── _SoloMenuCard "Entraînement Maîtrise" → context.push('/solo/quiz-solo')
├── SizedBox(height: 16)
├── _CategoryHeader "COMMUNAUTÉ" (orange)
├── _SoloMenuCard "Le Labo" → context.push('/labo')
└── mention "Mode Active Recall activé" (11 px, italic, blanc 50%)
```

### Verdict : **Launcher fluide partiel**

Chaque `_SoloMenuCard` est un `GradientBorderCard` cliquable avec `InkWell` — les 3 actions lancent directement vers leurs destinations respectives.

**Mais :** Plusieurs modes accessibles depuis le menu Solo ne sont **pas présents** dans ce hub :
- Flashcards solo (`/solo/flashcards-solo`) — absent de SoloScreen ⚠️
- Révision lacunes (`/quiz/revision-lacunes`) — absent ⚠️
- Pool de révision (`/revision-pool`) — absent ⚠️
- Survival (`/quiz/survival`) — absent ⚠️
- Mode Vrai/Faux (`/true-false`) — absent ⚠️

`_SoloTopBar` a un back arrow qui fait `context.go('/home')` — redondant avec la bottom nav déjà visible. Les routes `/solo/quiz-solo` et `/solo/revision` (menu révisions) ne sont pas non plus exposées dans ce hub.

---

## 6. Hub /flashcards — Launcher fluide ou dead end ?

Fichier : `lib/features/flashcards/presentation/flashcards_hub_screen.dart`

### Structure (ListView)

```
EskoliaAppBar "Flashcards"

ListView(padding: 20H + 12T + 28B)
└── if loading: CircularProgressIndicator
    else:
    ├── GradientBorderCard (vert/violet)
    │   ├── "À réviser aujourd'hui"
    │   ├── "$due carte(s) dues · Paquet : $total"
    │   └── FilledButton "Lancer la révision"     ← désactivé si _due == 0
    │       → FlashcardSessionRouteArgs(timed: false, survival: false)
    │         via context.push('/flashcards/session', extra: args)
    ├── SizedBox(height: 16)
    ├── GradientBorderCard (vert/violet)
    │   ├── "Flashcards rapides ⚡"
    │   ├── description
    │   └── OutlinedButton "Démarrer" → context.push('/solo/flashcards-solo')
    ├── SizedBox(height: 16)
    └── GradientBorderCard (amber/violet)
        ├── "Révision lacunes 💡"
        ├── description
        └── OutlinedButton "Lancer les lacunes" → context.push('/quiz/revision-lacunes')
```

### Verdict : **Launcher fonctionnel, 3 actions claires**

- Révision SRS (cartes dues) : CTA principal, désactivé intelligemment si rien à réviser.
- Flashcards rapides : ouvre le setup (`/solo/flashcards-solo`).
- Lacunes : cross-feature, redirige vers le quiz lacunes (pas les flashcards).

**Pull-to-refresh** pour recharger le compteur de cartes dues.  
**Compteur de cartes dues** chargé au `initState`, ré-actualisé après retour de session (`.then((_) => _reload())`).

---

## 7. Hub /labo — Launcher fluide ou dead end ?

Fichier : `lib/features/labo/presentation/labo_hub_screen.dart`

### Structure (ListView)

```
EskoliaAppBar "Le Labo"

ListView(padding: 20H + 12T + 28B)
├── FutureBuilder<UserModel?> — si staff :
│   └── ListTile "Espace modération" → context.push('/admin')
├── texte d'introduction (13 px slate)
├── SizedBox(height: 20)
├── GradientBorderCard (violet)
│   ├── "🚩 Remonter une erreur"
│   ├── description (signalement depuis fin de quiz)
│   └── FilledButton "Mes signalements" → context.push('/labo/reports')
├── SizedBox(height: 14)
├── GradientBorderCard (violet/rose)
│   ├── "➕ Créer une question"
│   ├── description
│   └── FilledButton "Ouvrir le formulaire" → context.push('/labo/create-question')
├── SizedBox(height: 12)
├── GradientBorderCard (rose/violet)
│   ├── "💡 Proposer un tip"
│   ├── description
│   └── FilledButton "Proposer une astuce" → context.push('/labo/create-tip')
└── _placeholderCard "Stats & défis Labo" (accent vert, badge "Bientôt")
```

### Verdict : **Launcher fonctionnel, avec placeholder honnête**

Les 3 actions fonctionnelles lancent directement leurs formulaires ou listes. Le staff voit un 4e accès vers l'admin. La feature "Stats & défis Labo" est explicitement marquée "Bientôt" dans l'UI.

---

## 8. Écran quiz `/quiz/run` — Anatomie complète

Fichier : `lib/features/quiz/screens/quiz_screen.dart`

### Layout global (Column fixe)

```
Scaffold(backgroundColor: bgDeep)
└── Stack
    ├── EskoliaAmbientBackground()
    └── SafeArea → Column
        ├── _buildTopBar (Row, padding hPad)
        ├── barre de progression (height: 4, gradient violet→cyan)
        └── Expanded → SingleChildScrollView
            └── ConstrainedBox(maxWidth lessonContentMaxWidth)
                ├── _dailyLeaderboardPanel (visible si sessionId.startsWith('daily_'))
                ├── EskoliaFlipCard(front: ..., back: ...)
                ├── SizedBox(height: 24)
                └── _buildActions
```

### `_buildTopBar` (hauteur dynamique)

```
Row
├── IconButton ✕ (close + dialog confirmation)
├── Expanded — titre de session (16 px, 1 ligne, ellipsis)
├── [survival] ❤️ × lives (14 px, une par vie restante)
├── [timed && !isFlipped] timer circulaire
│   ├── CircularProgressIndicator(value: secondsLeft/30, strokeWidth: 3)
│   │   └── couleur: lerp(violet → rouge) quand < 10 s
│   └── Text "$secondsLeft" (11 px, centre)
└── Container "Q N/T" (12 px, fond blanc 10%, radius 12)
```

### Barre de progression

```
ClipRRect(radius: 4) → SizedBox(height: 4) → Stack
├── fond: #1E293B
└── FractionallySizedBox(widthFactor: currentIndex/total)
    └── gradient violet → cyan
```

### Carte question (FACE — `_buildFront`)

```
Column
├── QuizQuestionContextRow         ← contexte, difficulté, auteur (Row horizontal)
├── SizedBox(height: 12)
├── [type='ticket'] badge "TICKET D'INCIDENT" (orange, 10px)
├── question text (20 px bold, height 1.4)
├── [type='diagnostic_indices'] section indices
│   ├── label "INDICES DISPONIBLES" (blanc 54%, 11px)
│   ├── indices révélés (cyan italique, fond blanc 5%)
│   └── TextButton "Révéler l'indice N (-25% points)" (orange)
└── [type='sequence'] ReorderableListView drag&drop
    └── items avec numéros circulaires violet, drag handle
    OU
    EskoliaTextField "Tape ta réponse ici..." (texte libre)
    + hint "Effort de mémoire : écris avant de révéler !" (12px, italic, blanc 40%)
```

### Carte question (DOS — `_buildBack`)

```
Column
├── label "RÉPONSE ATTENDUE" (blanc 70%, 12px, letterSpacing 1.2)
├── SizedBox(height: 12)
├── Container(réponse, fond blanc 10%, radius 16, 18px bold)
├── [type='ticket'] checklist interactive
│   ├── label "CHECKLIST DE RÉSOLUTION" (orange)
│   └── items avec checkbox verte/grise (interactifs si !isValidated)
├── [type='sequence'] _buildSequenceComparison
│   ├── badge score (vert/orange/rouge selon résultat)
│   ├── label "ORDRE CORRECT"
│   └── items avec ✓ vert / ✗ rouge selon chaque position
├── [type='classic'] section explication
│   ├── label "EXPLICATION / ASTUCE" (blanc 60%)
│   └── texte explication (14px, blanc 80%, height 1.5)
└── [!isValidated && type!='sequence'] feedback binaire
    ├── "Étais-tu proche de la réponse ?" (13px)
    ├── EskoliaButton "À revoir" (secondary, ✗ icon)
    └── EskoliaButton "J'avais bon" (primary, ✓ icon)
```

### `_buildActions` (bouton bas d'écran)

| État | Bouton affiché |
|------|----------------|
| `!isFlipped` | "Vérifier la réponse" / "Vérifier l'ordre" (primary) |
| `isFlipped && isValidated` (ou séquence) | "Question suivante" / "Voir les résultats" (primary) |
| `isFlipped && !isValidated` | SizedBox.shrink() ← le feedback binaire est dans le back |

### Timer — comportement exact

- Départ : 30 secondes, `Timer.periodic` 1 s dans `QuizNotifier`.
- Pause : le timer s'arrête dès que `isFlipped || isValidated`.
- Couleur indicateur : `lerp(violet → rouge)` quand `secondsLeft < 10` :  
  `t = (1 - secondsLeft/10).clamp(0,1)` → transition progressive.
- Timeout (`secondsLeft <= 1`) : `onTimeUp()` → `isFlipped = true, isTimedOut = true`.
- Le timer n'est visible que `if timed && !isFlipped`.
- En mode désactivé (`timed: false`) : ni timer affiché, ni timeout.

### Leaderboard panel quiz du jour

Visible uniquement si `sessionId.startsWith('daily_')`. `GradientBorderCard` avec un `StreamBuilder` qui watch `leaderboard_daily/{dayKey}/scores` (top 5 en temps réel pendant la session).

### Scoring détaillé par type

| Type | Condition | Score |
|------|-----------|-------|
| `classic` | wasCorrect = true | 1.0 |
| `classic` | wasCorrect = false | 0.0 |
| `diagnostic_indices` | correct, 0 indice | 1.0 |
| `diagnostic_indices` | correct, 1 indice | 0.75 |
| `diagnostic_indices` | correct, 2 indices | 0.50 |
| `diagnostic_indices` | correct, 3 indices | 0.25 |
| `ticket` | correct, tous cochés | 1.0 |
| `ticket` | correct, N/T cochés | clamp(N/T, 0.5, 1.0) |
| `sequence` | K étapes correctes | K / total |

---

## 9. Écran multijoueur `BattleScreen` — Phases détaillées

Fichier : `lib/features/lobby/presentation/battle_screen.dart`

### Machine d'états (stream Firestore `lobbies/{id}`)

```
phase: 'countdown'  →  'question'  →  'judgment'  →  'result'  →  'finished'
           ↑                ↑               ↑              ↑
      Host: _repo     Timer expire    Tous ont        Host: showRound
      .advanceTo...   → Host: set     répondu OU      Result()
      NextQuestion()  Judgment()      Host: setJudge
```

### Phase `countdown`

```
Center(child: Text(_countLabel, 84 px bold))
```

`_runCountdown()` : séquence `['3', '2', '1', 'GO!']`, délai 650 ms entre chaque. Quand terminé, si host → `advanceToNextQuestion()` → passe à `'question'`.

### Phase `question`

```
Column
├── _buildHeader (topbar)
│   ├── ✕ close
│   ├── _timerBadge (CircularProgress violet/rouge + chiffres)
│   ├── LinearProgressIndicator (Q actuelle / total, violet)
│   └── _indexBadge "Q N/T"
├── _scoreBar (ListView horizontal, avatars + scores)
│   └── Par joueur : avatar 40×40 (fond violet si hasAnswered, sinon blanc 10%)
│                  + score cumulé (cyan, 10px)
└── SingleChildScrollView → Column
    ├── Container(question card)
    │   ├── QuizQuestionContextRow
    │   ├── [type='ticket'] badge TICKET D'INCIDENT
    │   ├── question text (20px bold)
    │   ├── [diagnostic_indices] indices révélés (pilotés par host)
    │   ├── if !answered: EskoliaTextField + EskoliaButton "Envoyer"
    │   └── if answered: CircularProgress + "Réponse envoyée ! En attente..."
    └── if _isHost:
        ├── [diagnostic_indices] "Révéler un indice à la classe" (secondary, expand)
        └── "Passer au jugement" (primary, expand)
```

**Timer question :** `_qSeconds` (défaut `s.secondsPerQuestion = 20`), `Timer.periodic` 1 s. Quand 0 → si host : `setBattlePhaseJudgment()`. Rouge si `_qSeconds < 6`.

**Auto-judgment :** Quand tous les joueurs ont répondu (`allAnswered`), `submitAnswer()` passe automatiquement en `judgment` (Firestore transaction).

### Phase `judgment` (host uniquement)

```
Column
├── Row "CORRECTION COLLECTIVE" (cyan, letterSpacing 1.5) + _poolPin
├── question (18px bold, centré)
├── Container vert — "RÉPONSE ATTENDUE : {answer}" (green, 13px bold)
└── ListView.builder — un Card par joueur
    ├── leading: avatar emoji
    ├── title: displayName
    ├── subtitle: lastAnswerText
    └── trailing: si !judged : Row [✗ IconButton, ✓ IconButton]
                  si judged  : "${points} pts" (vert/rouge)
    + Padding → EskoliaButton "Valider la manche" → showRoundResult()
```

**Joueurs non-host (waiting):**

```
Center → Column
├── Icon gavel (cyan, 64)
├── "Correction en cours..."
├── "Le Host examine les réponses de la classe."
└── _poolPin (large: true) + "Besoin de réviser cette question ?"
```

Le bouton pin 📌 est disponible pour **tous les joueurs** pendant la correction — ils peuvent épingler la question dans leur pool de révision.

### Phase `result`

```
Column
├── "Résultats de la manche" (24px bold)
└── ListView — Card par joueur
    ├── avatar + displayName + lastAnswerText
    └── trailing: Icon (✓ vert / ✗ rouge) + score de la manche
    + if _isHost: EskoliaButton "Question suivante" → advanceToNextQuestion()
```

### Phase `finished` (podium)

```
Column(mainAxisAlignment: center)
├── "PODIUM FINAL" (28px, letterSpacing 2)
├── SizedBox(height: 40)
├── Top 3 joueurs (sorted par score desc) — ListTile(avatar 32, nom 18px, score cyan 20px)
└── EskoliaButton "Quitter le lobby" (secondary) → context.go('/lobbys')
```

**Achievements déclenchés** à `finished` : `onBattleFinished(uid, won: bool)`.

---

## Synthèse des points UX critiques

| Zone | Observation | Sévérité |
|------|-------------|----------|
| Bottom nav | 11 items dans une pill scrollable horizontalement — trop de destinations, discoverability faible | ⚠️ Moyen |
| HomeScreen | Quêtes quotidiennes absentes de l'accueil, bouton TEST QUIZ en prod | ⚠️ Moyen |
| SoloScreen | 3 entrées seulement sur 8+ modes disponibles depuis `/solo/*` | ⚠️ Moyen |
| TopBar | 6 infos dans 72 px, pseudo tronqué sur les noms > 10 chars | ⚠️ Moyen |
| Quiz — bouton actions | Entre `isFlipped && !isValidated && type='sequence'` : bouton disparaît (SizedBox.shrink), le score est calculé à `reveal` automatiquement | ℹ️ Info |
| QuizScreen | Route `/quiz/daily` appelée par le bouton TEST mais absente du router | 🔴 Bug |
| BattleScreen | Phase `judgment` : host doit juger manuellement chaque réponse texte — pas de fuzzy matching, risque d'erreur humaine | ⚠️ Moyen |
| Flashcards hub | CTA "Lancer la révision" désactivé si 0 cartes dues — bon comportement mais pas de message explicatif | ℹ️ Info |
| Labo hub | Feature "Stats & défis Labo" marquée "Bientôt" dans l'UI — honnête mais occupe de l'espace | ℹ️ Info |
