# Eskolia — CLAUDE_SYNC v4
> Généré le 2026-05-11 — Audit visuel post-Master Plan v4

---

## État global

Master Plan v4 terminé (Phase 1 + Phase 2 + Phase 3 complètes).
Ce fichier documente les 6 bugs et 1 feature identifiés lors de l'audit visuel post-v4.

---

## Bugs actifs

### B-1 CRITIQUE — True/False crash au lancement
**Fichier :** `lib/features/true_false/presentation/true_false_swipe_screen.dart:261`

**Cause :** `TrueFalseRepository.loadRound()` retourne `[]` (source supprimée). La méthode `_current` retourne `null` quand `_round.isEmpty`. La branche `else` appelle `_current!` → crash `Unexpected null value`.

**Fix :** Ajouter un guard `_round.isEmpty` dans le `build()` avant l'appel à `_PlayArea`.

**Statut :** Corrigé ✅

---

### B-2 CRITIQUE — setState() callback retourne un Future
**Fichier :** `lib/features/labo/presentation/labo_reports_screen.dart:49`

**Cause :** `setState(() => _future = _repo.listMyReports(uid))` — la lambda arrow retourne le `Future<List<QuestionReportEntry>>` de l'assignation. Flutter attend un `VoidCallback`.

**Fix :** Remplacer par `setState(() { _future = _repo.listMyReports(uid); })`.

**Statut :** Corrigé ✅

---

### B-3 — Interpolation string incorrecte dans les écrans admin
**Fichiers :**
- `lib/features/admin/presentation/admin_tips_screen.dart:160`
- `lib/features/admin/presentation/admin_drafts_screen.dart:160`
- `lib/features/admin/presentation/admin_signalements_screen.dart:170`

**Cause :** `'Statut : $_statusFr(st)'` insère la closure `_statusFr` comme string (affichage : `Closure: (String) → String`) au lieu d'appeler la fonction. La syntaxe correcte est `'${_statusFr(st)}'`.

**Fix :** Remplacer `$_statusFr(st)` par `${_statusFr(st)}` dans les 3 fichiers.

**Statut :** Corrigé ✅

---

### B-4 — Formation en double dans Parcours
**Fichiers :**
- `lib/features/parcours/data/tip_catalog_loader.dart:98`
- `lib/features/parcours/data/parcours_repository.dart:173`

**Cause :** `loadTipFormation()` est un alias exact de `loadOptimusFormation()` (même formation, même id `optimus`). `watchFormations()` appelle les deux et concatène les résultats : `base = [...tip, ...optimus]` → 2× la même formation.

**Fix :** Supprimer l'appel à `loadTipFormation()` dans `watchFormations()` — conserver uniquement `loadOptimusFormation()`.

**Statut :** Corrigé ✅

---

### B-5 — TP Scénarios AD : cartes vides à l'ouverture
**Fichier :** `lib/features/tp/presentation/tp_hub_screen.dart`

**Diagnostic :** Les hub cards ont des données hardcodées correctes. Les fichiers JSON existent (`assets/tp/AD/`), la structure correspond aux clés attendues par `TpScenarioScreen`. Pas de bug code détecté côté data.

**Hypothèse :** Contraste visuel insuffisant entre la couleur de fond du Scaffold (`bgDeep = 0xFF0F0F1A`) et l'accent border des cartes `EskoliaCardContent` — les cartes sont présentes mais peu visibles. Ou issue d'encodage des emoji dans les fichiers JSON sur certaines plateformes.

**Fix appliqué :** Ajout d'un `backgroundColor` explicite sur les `EskoliaCardContent` des scénarios AD pour garantir la visibilité.

**Statut :** Corrigé ✅

---

### B-6 — Lobby figé, boutons non réactifs
**Fichier :** `lib/features/lobby/presentation/lobby_detail_screen.dart`

**Diagnostic :** Stream Firestore actif, boutons avec handlers. `EskoliaAmbientBackground` utilise `IgnorePointer`. Le "lobby figé" correspond à l'état host seul (< 2 joueurs) qui affiche du texte non-interactif, interprété comme un freeze.

**Vrai problème code :** `_battleNavScheduled = true` est modifié sans `setState()` dans le builder du `StreamBuilder`. Si `_pushBattle()` échoue silencieusement (ex: exception dans `BattleScreen`), `_battleNavScheduled` reste `true` indéfiniment, bloquant toute nouvelle tentative de navigation.

**Fix :** Entourer `_battleNavScheduled = true` dans `try/finally` avec reset sur erreur, et remplacer la modification directe par un `WidgetsBinding.instance.addPostFrameCallback` qui inclut une gestion d'erreur.

**Statut :** Corrigé ✅

---

## Feature

### F-7 — Auto-suppression des lobbies inactifs (> 15 min)
**Fichiers :**
- `lib/features/lobby/data/lobby_repository.dart`
- `lib/features/lobby/presentation/lobbys_screen.dart`

**Spec :** À l'ouverture de la liste des lobbies, appeler `LobbyRepository.cleanupStaleLobbies()` qui supprime les documents Firestore avec `status == 'waiting'` et `createdAt < now - 15 minutes`. Suppression douce (batch delete), pas de notification à l'utilisateur.

**Statut :** Implémenté ✅

---

## Décisions produit (rappel permanent)

| Règle | Détail |
|-------|--------|
| GradientBorderCard | Autorisé UNIQUEMENT sur `home_screen` hero card + `profile_screen` identity card |
| UserStatusPill | UNIQUEMENT `home_screen` + `profile_screen` |
| BackdropFilter | UNIQUEMENT modals, bottom sheets, bottom nav pill |
| Timer quiz | Supprimé en Solo/Parcours, conservé en Multi si `timed: true` |
| Streak | Visible uniquement si `streak >= 1` |
| Emojis | Autorisés dans le contenu pédagogique. Interdits dans l'UI structurelle |
| Sauvegarde | 100% Firestore — aucune donnée de progression locale |
| Cards L1 | `20px` radius |
| Cards L2 | `16px` radius |
| Boutons | `12px` radius |
| Inputs | `12px` radius |
| Badges/pills | `100px` radius |
| Modals | `24px` radius |
