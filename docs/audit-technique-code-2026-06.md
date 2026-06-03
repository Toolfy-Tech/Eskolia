# Audit technique du code — Eskolia

**Date :** 2026-06-01
**Périmètre :** Code source `lib/` (210 fichiers Dart), configuration, sécurité Firestore, CI, dépendances, tests.
**Méthode :** Analyse statique manuelle + agents d'exploration ciblés. Le toolchain Flutter/Dart n'étant pas disponible dans l'environnement, `flutter analyze` et `flutter test` n'ont pas pu être exécutés — toutes les conclusions reposent sur la lecture du code et des recherches `grep` vérifiées une à une.
**Complément :** Ce document complète l'audit fonctionnel `docs/audit-centre-formation-2026-05.md` (orienté LMS). Ici l'angle est purement technique : qualité de code, sécurité applicative, dette d'architecture.

---

## Verdict global

> Base de code **saine et disciplinée** sur les conventions du projet. Les fondations
> de sécurité (règles Firestore) sont solides. Les points d'amélioration concernent
> surtout la **dette d'architecture** (feature `quiz` hétérogène, code mort) et
> quelques **fragilités côté parsing IA** qui violent une règle explicite de CLAUDE.md.

| Dimension | Note | Commentaire |
|---|---|---|
| Conformité conventions CLAUDE.md | 9/10 | 0 `withOpacity`, 0 guillemets typographiques, 0 `print`, 0 `as dynamic` |
| Sécurité (règles Firestore) | 8/10 | Modèle deny-all, sous-collection privée pour les clés IA |
| Sécurité (manipulation clés IA) | 6/10 | Clé Gemini en paramètre d'URL, clé en clair en mémoire UI |
| Robustesse couche IA (BYOK) | 6/10 | Chaînage `?.` sur `dynamic` sur les providers OpenAI-compatibles/Anthropic |
| Architecture / cohérence | 6/10 | Feature `quiz` non conforme, ~10 fichiers de code mort |
| Gestion d'erreurs | 6/10 | 26 blocs `catch (_) {}` qui avalent les erreurs |
| Hygiène dépendances | 7/10 | 4 dépendances déclarées jamais importées |
| Couverture de tests | 4/10 | 6 fichiers de test pour 210 fichiers `lib/` |
| Documentation / hygiène repo | 6/10 | README obsolète, script orphelin, widget de debug |

---

## 1. Conformité aux conventions CLAUDE.md — ✅ excellent

Vérifié directement, aucune violation :

- `withValues(alpha:)` partout — **0** occurrence de `withOpacity()`.
- **0** guillemet typographique `""` dans les fichiers `.dart`.
- **0** `print()` (8 `debugPrint`, tous dédiés au log d'erreurs `$e`).
- **0** `as dynamic`.

> Les chaînes UI/log contiennent des apostrophes typographiques (`'`) et tirets cadratins (`—`), ce qui est conforme (la règle ne vise que les guillemets doubles `""`).

---

## 2. Sécurité — règles Firestore (`firestore.rules`) — ✅ solide

- Modèle **deny-all** final (`match /{document=**} { allow read, write: if false; }`).
- Clés API IA isolées dans la sous-collection privée `users/{uid}/settings/` accessible au seul propriétaire (`isSelf`).
- Le champ `role` est protégé en update (`!...affectedKeys().hasAny(['role'])`) — pas d'auto-promotion en admin.
- `leaderboard_daily` : validation stricte des types et bornes (`score <= total`, monotonie sur update).
- `login_aliases` : `get` sans auth mais borné (longueur d'id), `list` interdit — bon compromis pour le login par pseudo.

**Recommandation mineure :** la collection `formations` autorise `write: if isStaff()` mais `isStaff()` lit le rôle via `get()` à chaque évaluation — coût en lectures sur les chemins écrits fréquemment. Acceptable au volume actuel.

---

## 3. Sécurité — manipulation des clés API IA — ⚠️ à renforcer

### 3.1 Clé Gemini transmise en paramètre d'URL — `lib/features/ai/data/ai_chat_service.dart:211`
```dart
'https://generativelanguage.googleapis.com/v1beta/models/$geminiModel:generateContent?key=$key'
```
La clé voyage dans la query string. C'est la méthode d'authentification **officielle** de l'API Gemini, mais elle apparaît dans l'historique du navigateur, les logs réseau et DevTools.
**Recommandation :** utiliser l'en-tête `x-goog-api-key: $key` (supporté par l'API) plutôt que `?key=`.

### 3.2 Clé en clair dans l'UI — `lib/features/ai/presentation/ai_setup_screen.dart:320-321` et `416-417`
La clé est rechargée depuis Firestore dans un `TextEditingController` puis réutilisée comme `ValueKey(apiKey)`.
**Gravité réelle : basse** — il s'agit de la propre clé de l'utilisateur dans sa propre session navigateur (modèle BYOK), pas d'un secret partagé.
**Recommandation :** afficher un placeholder masqué (`••••••`) plutôt que la valeur, et utiliser un identifiant dérivé (hash court ou index) comme `ValueKey` au lieu de la clé brute.

---

## 4. Robustesse de la couche IA (BYOK) — ⚠️ violation d'une règle CLAUDE.md

CLAUDE.md : *« dart2js (Flutter Web) : ne jamais chaîner `?.` sur `dynamic` — utiliser `is List` / `is Map` »*.

Le chemin **Gemini** (provider documenté, non-streaming `generateContent`) respecte parfaitement la règle via `_extractGeminiText` (`is List`/`is Map`, `ai_chat_service.dart:240-256`) — ✅.

En revanche, les chemins de **streaming** violent la règle :

| Provider | Fichier:ligne | Code |
|---|---|---|
| OpenAI-compatibles (openai, groq, xai, mistral, perplexity) | `ai_chat_service.dart:119-120` | `(json['choices'] as List?)?.firstOrNull?['delta']?['content'] as String?` |
| Anthropic | `ai_chat_service.dart:175` | `json['delta']?['text'] as String?` |

`firstOrNull` et `json['delta']` retournent `dynamic` ; le chaînage `?.[...]` qui suit est précisément le motif interdit en dart2js. Comme ces lignes sont enveloppées dans des `catch (_) {}` (lignes 122 et 178), une erreur de parsing serait **avalée silencieusement** — token jamais émis, aucune trace.
**Gravité : moyenne-haute** (touche 6 des 8 providers de l'enum `AiProvider`).
**Recommandation :** factoriser une extraction sûre par `is Map`/`is List` comme `_extractGeminiText`, et logger l'exception dans le `catch` au lieu de l'avaler.

### 4.1 `testKey` — message générique au lieu de la cause réelle — `ai_chat_service.dart:273-276`
Quand le stream Gemini se termine vide sans exception, `testKey` renvoie un message générique (« vérifie le modèle ») au lieu de la cause. Le `catch (e) { return e.toString(); }` couvre bien les exceptions levées, donc l'impact est limité aux cas de stream vide silencieux.
**Recommandation :** différencier « clé invalide » de « réponse vide » en propageant la cause du parsing.

### 4.2 Conformité des bodies — ✅
- Gemini : `{"contents":[{"parts":[{"text":"..."}]}]}` conforme au contrat (`ai_chat_service.dart:217-225`).
- OpenAI : header `Authorization: Bearer`. Anthropic : header `x-api-key`. Ollama : sentinel `'ollama'` écrit en Firestore (`ai_key_repository.dart`). Tous conformes.

---

## 5. Architecture — ⚠️ dette à résorber

### 5.1 Feature `quiz` non conforme au pattern `data/ → presentation/`
Contrairement à toutes les autres features, `quiz/` mélange des dossiers ad hoc :
```
features/quiz/
├── components/   (widgets — devraient être en presentation/widgets)
├── data/         ✅
├── models/       (devraient être en data/models)
├── presentation/ ✅
├── screens/      (devraient être en presentation/)
├── services/     (repositories — devraient être en data/)
└── viewmodels/
```
Plusieurs barrels réexportent d'un dossier à l'autre (`components/` ↔ `presentation/widgets/`), ce qui brouille la localisation réelle du code.
**Recommandation :** migration progressive `services/` → `data/`, `screens/` → `presentation/`, `models/` → `data/models/`. Refactor mécanique, à faire couche par couche (cf. règle « découpage des requêtes » de CLAUDE.md).

### 5.2 Couplage du routeur aux couches data/models
`lib/core/router/app_router.dart` importe des repositories et modèles (`quiz_repository.dart`, `revision_pool_launch_mode.dart`, `note_model.dart`, `tip_quiz_catalog.dart`, `tp_binaire_data.dart`). Couplage acceptable pour un GoRouter qui instancie des écrans paramétrés, mais à surveiller.
**Note :** vérification faite — **toutes les routes pointent vers des écrans existants et importés** ✅.

### 5.3 Code mort confirmé (0 référence externe, vérifié par `grep`)

| Fichier | Symbole |
|---|---|
| `lib/core/widgets/debug_page_label.dart` | `DebugPageLabel` (marqué *« TODO: REMOVE AFTER AUDIT »*, `DebugRouteOverlay` introuvable) |
| `lib/core/widgets/top_bar.dart` | widget non utilisé |
| `lib/core/config/staff_bootstrap.dart` | jamais importé |
| `lib/core/constants/spacing.dart` | constantes jamais référencées |
| `lib/shared/widgets/eskolia_gradient_text.dart` | `EskoliaGradientText` |
| `lib/shared/widgets/user_status_pill.dart` | `UserStatusPill` |
| `lib/features/parcours/data/models/chapter_model.dart` | `ChapterModel` |
| `lib/features/parcours/data/models/module_model.dart` | `ModuleModel` |
| `lib/features/parcours/data/models/flashcard_model.dart` | `FlashcardModel` (parcours) |
| `lib/features/solo/presentation/practical_exercises_hub_screen.dart` | `PracticalExercisesHubScreen` (`/tp` route vers `TpHubScreen`) |
| `lib/features/labo/presentation/community_tips_panel.dart` | widget orphelin |

> Vérification : `lobbys_screen.dart` (presentation) **n'est pas** mort — il est exposé via le barrel `lobby/lobby_list_screen.dart` utilisé par le routeur.

**Recommandation :** supprimer ces fichiers (sauf si les 3 modèles `parcours` sont des prévisions assumées — à confirmer).

---

## 6. Gestion d'erreurs — ⚠️ erreurs avalées

- **26** blocs `catch (_) {}` strictement vides, **69** `catch (_)` au total.
- Anodins : parsing SSE ligne par ligne (`ai_chat_service.dart:122,178`), fallbacks UI.
- Problématiques : ceux qui masquent une cause utile, notamment `gemini_model_selector.dart:102-103` (retombe sur la liste par défaut sans signaler pourquoi le fetch a échoué — peut cacher une clé invalide) et `ollama_service.dart:107-109` (cast `as Map`/`as String` non gardé, liste de modèles vide sans diagnostic).
**Recommandation :** dans les `catch` des chemins réseau/parsing, conserver au minimum un `debugPrint` du `$e` (le projet le fait déjà ailleurs).

---

## 7. Dépendances — ⚠️ nettoyage possible

Déclarées dans `pubspec.yaml` mais **jamais importées** dans `lib/` :

| Paquet | Statut |
|---|---|
| `glassmorphism` | Aucun import (le glassmorphism est implémenté à la main via les tokens de thème) |
| `rive` | Aucun import, aucun asset `.riv` |
| `path_provider` | Aucun import |
| `share_plus` | Volontairement non importé (commentaire `custom_quiz_import_widget.dart:65` : usage mobile évité grâce à `kIsWeb`) — inutile pour une app Web |

**Recommandation :** retirer `glassmorphism`, `rive`, `path_provider` (et `share_plus` si la cible reste Web only) pour réduire le temps de résolution et la taille de build.

---

## 8. Tests — ⚠️ couverture faible

- **6** fichiers de test pour **210** fichiers `lib/` (3 unit, 2 widget, 1 smoke).
- Aucun test sur la couche IA (`ai_chat_service`, parsing des réponses) — précisément la zone la plus fragile (cf. §4).
- Aucun test sur les repositories quiz/lobby/économie.
**Recommandation :** prioriser des tests unitaires sur `_extractGeminiText` + extraction streaming OpenAI/Anthropic (cas JSON malformé), et sur les repositories critiques.

---

## 9. Documentation & hygiène du dépôt — ⚠️

- **README obsolète :** référence `eskolia_blueprint.md`, `eskolia_cursor_prompts.md`, `eskolia_image_prompts.md` — **aucun n'existe** dans le dépôt. Le dossier `docs/` réel n'y est pas listé.
- **`convert_pdf.py`** à la racine : script Python one-off (PyMuPDF) pointant vers un PDF absent — sans rapport avec l'app Flutter. À déplacer dans `tool/` ou supprimer.
- **CI (`/.github/workflows/deploy.yml`) :** déploie sur push `main` via `FIREBASE_TOKEN`. Pas d'étape `flutter analyze` ni `flutter test` avant déploiement → aucun garde-fou qualité dans le pipeline.
**Recommandation :** ajouter un job `flutter analyze && flutter test` en gate avant le déploiement ; mettre le README à jour avec le vrai contenu de `docs/`.

---

## 10. Plan d'action priorisé

### 🔴 Prioritaire
1. Sécuriser le parsing IA streaming (OpenAI-compatibles + Anthropic) : remplacer le chaînage `?.` sur `dynamic` par des gardes `is Map`/`is List`, et logger l'erreur au lieu de l'avaler (`ai_chat_service.dart:119-120,175`).
2. Passer la clé Gemini en en-tête `x-goog-api-key` au lieu de `?key=` (`ai_chat_service.dart:211`).
3. Ajouter `flutter analyze` + `flutter test` comme gate CI avant déploiement.

### 🟠 Important
4. Supprimer le code mort listé en §5.3 (à commencer par `debug_page_label.dart`).
5. Retirer les dépendances inutilisées (`glassmorphism`, `rive`, `path_provider`, éventuellement `share_plus`).
6. Mettre le README à jour ; déplacer/supprimer `convert_pdf.py`.

### 🟡 Moyen terme
7. Normaliser l'architecture de la feature `quiz` sur le pattern `data/ → presentation/`.
8. Auditer les `catch (_) {}` des chemins réseau/parsing et y ajouter un `debugPrint`.
9. Augmenter la couverture de tests, en priorité sur la couche IA et les repositories.

---

*Audit réalisé en analyse statique. Une exécution de `flutter analyze`/`flutter test` en local ou en CI reste nécessaire pour détecter les warnings du compilateur (imports inutilisés, etc.) non couverts ici.*
