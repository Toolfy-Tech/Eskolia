# Eskolia — Master Plan v5
> Créé le 2026-05-11 — Basé sur l'audit visuel complet (20 screenshots) + corrections B1-B6 + F7

---

## État de départ

| Phase | Statut |
|-------|--------|
| Master Plan v4 complet | ✅ |
| Bugs B1-B6 corrigés | ✅ |
| Feature F7 (auto-delete lobbies 15min) | ✅ |

---

## Décisions produit actées (rappel)

- GradientBorderCard : home hero card + profile identity uniquement
- UserStatusPill : home + profil uniquement
- Timer quiz : supprimé Solo/Parcours, conservé Multi
- Streak 🔥 : visible uniquement si streak ≥ 1
- Sauvegarde : 100% Firestore

---

## Phase 1 — Bugs résiduels 🔴

### Tâche 1.1 — TP Hub : cartes AD vides
**Fichier :** `lib/features/tp/presentation/tp_hub_screen.dart`

**Problème :** Les 3 cartes AeroTech, Pixel Academy et Saint-Lazare s'affichent comme des rectangles vides sans titre ni contenu. Claude Code a conclu "pas de bug code" mais visuellement le problème est réel.

**Action :** Lire `tp_hub_screen.dart` en entier. Vérifier le widget qui rend chaque carte de scénario — probablement un `FutureBuilder` ou un chargement async qui échoue silencieusement. Vérifier que les assets `assets/tp/AD/scenario_a_aerotech.json`, `scenario_b_pixel_academy.json` et `scenario_c_saint_lazare.json` sont bien déclarés dans `pubspec.yaml`. Ajouter des logs de debug pour identifier pourquoi les données ne s'affichent pas.

---

### Tâche 1.2 — Username toujours absent sur la HomeScreen
**Fichier :** `lib/features/home/presentation/home_screen.dart`

**Problème :** Le greeting affiche "Bonjour 👋" sans prénom malgré la correction censée être faite.

**Action :** Vérifier que le stream Firestore de l'utilisateur est bien watché AVANT le premier render. Si le `UserModel` n'est pas encore chargé, afficher un skeleton plutôt qu'un greeting vide. S'assurer que `user.username` est bien interpolé une fois le stream reçu.

---

### Tâche 1.3 — Bottom nav : item "Admin" visible pour tous les utilisateurs
**Fichier :** `lib/core/widgets/bottom_nav.dart`

**Problème :** L'item "Admin" avec l'icône bouclier est visible dans la bottom nav sur tous les screenshots. Cet item ne doit être visible que pour les comptes staff.

**Action :** Conditionner l'affichage de l'item Admin au rôle de l'utilisateur connecté. Vérifier `UserModel.isStaff` ou équivalent. Si l'utilisateur n'est pas staff, l'item Admin ne doit pas apparaître dans la bottom nav.

---

### Tâche 1.4 — Erreur Brouillons Admin : message en bas d'écran
**Fichier :** `lib/features/admin/presentation/admin_drafts_screen.dart`

**Problème (image 19) :** Après avoir cliqué "Refuser", un message d'erreur technique apparaît en bas : `Statut : Closure: (String) → String from: (...args) → context[property](...args)(st)`. La correction B-3 a partiellement résolu le crash mais le message reste visible.

**Action :** Vérifier que le callback `onRefuse` dans `admin_drafts_screen.dart` et `admin_tips_screen.dart` est correctement typé et ne laisse plus filtrer de message d'erreur interne à l'écran.

---

## Phase 2 — Améliorations UX prioritaires 🟠

### Tâche 2.1 — Quiz plein écran : trop d'espace vide en haut
**Fichier :** `lib/features/quiz/screens/quiz_screen.dart`

**Problème (image 8) :** Le quiz Parcours Optimus affiche les ~40% supérieurs de l'écran complètement vides au-dessus de la carte question. La carte est trop basse dans le viewport.

**Action :** Vérifier le `MainAxisAlignment` de la Column principale. Le contenu doit être centré verticalement dans le SafeArea, pas poussé vers le bas. Revoir le `SingleChildScrollView` avec `minHeight: constraints.maxHeight`.

---

### Tâche 2.2 — Mode Maîtrise : section "Cybersécurité" manquante dans Ia liste
**Fichier :** Configurateur Solo — `lib/features/quiz/screens/quiz_solo_setup_screen.dart`

**Problème (image 5) :** Le configurateur n'affiche que 4 sections (Cybersécurité, Hardware, Maintenance, Réseaux). La section "IA & Outils" (section 6 du parcours Optimus) n'est pas listée.

**Action :** Vérifier que toutes les sections du catalogue sont bien chargées et affichées dans le configurateur. La section IA doit apparaître dans la liste.

---

### Tâche 2.3 — Lobby detail : informations techniques exposées
**Fichier :** `lib/features/lobby/presentation/lobby_detail_screen.dart`

**Problème (image 16) :** L'écran affiche des données techniques brutes non destinées aux utilisateurs : `Banque (id) : multi_23_131806123`. C'est un identifiant interne.

**Action :** Masquer le champ "Banque (id)" ou le remplacer par un label lisible. Ne jamais exposer d'ID technique interne à l'interface utilisateur.

---

### Tâche 2.4 — Parcours : back arrow redondant
**Fichier :** `lib/features/parcours/presentation/parcours_screen.dart`

**Problème (image 3) :** La back arrow est visible en haut à gauche sur l'écran Parcours qui est un écran shell avec bottom nav. Cette back arrow avait été supprimée dans le v3 mais est réapparue.

**Action :** Vérifier et supprimer à nouveau la back arrow de l'AppBar du ParcoursScreen. La bottom nav suffit pour la navigation.

---

### Tâche 2.5 — Flashcards hub : bouton "Lancer la révision" rose alors qu'il devrait être désactivé
**Fichier :** `lib/features/flashcards/presentation/flashcards_hub_screen.dart`

**Problème (image 7) :** Le bouton "Lancer la révision" est affiché en rose vif (couleur active) alors que `_due == 0` et que le message "à jour" est affiché en dessous. Un bouton désactivé doit être visuellement grisé, pas rouge/rose.

**Action :** Vérifier que `onPressed: null` (ou équivalent) est bien appliqué quand `_due == 0`. Un bouton Flutter avec `onPressed: null` s'affiche automatiquement dans son état désactivé (grisé). Si le bouton reste rose, c'est que le style override l'état désactivé.

---

## Phase 3 — Polish et cohérence 🟡

### Tâche 3.1 — Labo : "Créer une question" — format QCM vs réponse libre
**Fichier :** `lib/features/labo/presentation/labo_create_question_screen.dart`

**Observation (image 11) :** Le formulaire de création de question est un QCM 4 choix (A/B/C/D). Le système de quiz principal d'Eskolia utilise des réponses libres (Active Recall). Il y a une incohérence de format entre les questions du Labo (QCM) et le quiz principal (réponse libre).

**Action :** Ajouter un sélecteur de type de question en haut du formulaire : "Réponse libre" ou "QCM 4 choix". Par défaut : réponse libre pour rester cohérent avec le reste de l'app. Le QCM reste disponible pour les professeurs qui le souhaitent.

---

### Tâche 3.2 — Warnings inutilisés dans bottom_nav.dart
**Fichier :** `lib/core/widgets/bottom_nav.dart`

Les champs `_labo`, `_hautsFaits`, `_docs`, `_settings` (lignes 59-79) sont déclarés mais non utilisés — 4 warnings persistants dans flutter analyze.

**Action :** Soit supprimer ces champs si les routes sont définies ailleurs, soit les utiliser. Nettoyer pour éliminer les warnings du projet.

---

### Tâche 3.3 — Supprimer les imports inutilisés persistants
**Fichiers :**
- `lib/features/home/presentation/widgets/tech_news_section.dart:4` — import `eskolia_visual.dart` inutilisé
- `lib/features/lobby/data/lobby_repository.dart:10` — import `tip_quiz_catalog.dart` inutilisé
- `lib/features/profil/presentation/profile_screen.dart:14` — import `quiz_repository.dart` inutilisé

**Action :** Supprimer ces 3 imports. Vérifier le build après.

---

## Règles permanentes

1. Ne jamais modifier les routes GoRouter sans discussion
2. Ne jamais modifier les modèles Firestore sans migration planifiée
3. GradientBorderCard = 2 endroits max (home hero + profile identity)
4. UserStatusPill = home + profil uniquement
5. Aucun ID technique interne visible dans l'UI utilisateur
6. Item Admin visible uniquement pour les comptes staff
7. Toute progression persistée dans Firestore

---

## Fichiers de référence

| Fichier | Contenu |
|---------|---------|
| `CLAUDE_SYNC.md` | Journal de bord — à mettre à jour après chaque phase |
| `docs/ui-ux-audit.md` | Analyse code source |
| `docs/design-system.md` | Palette, typo, composants |
| `assets/tp/AD/scenario_a_aerotech.json` | TP AD Scénario A |
| `assets/tp/AD/scenario_b_pixel_academy.json` | TP AD Scénario B |
| `assets/tp/AD/scenario_c_saint_lazare.json` | TP AD Scénario C |
| `assets/templates/eskolia_quiz_template.json` | Template import quiz custom |
