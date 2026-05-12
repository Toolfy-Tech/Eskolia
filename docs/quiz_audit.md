# Quiz Audit — État des lieux

## 🟢 Utilisé (Actif dans AppRouter)
- **Screens Principaux :**
  - `QuizScreen` (lib/features/quiz/presentation/quiz_screen.dart)
  - `QuizSetupScreen` (lib/features/quiz/presentation/quiz_setup_screen.dart)
  - `QuizQuickScreen` (Démarrage rapide)
  - `QuizSurvivalScreen` (Mode survie)
- **Logic & Data :**
  - `QuizRepository` (lib/features/quiz/data/quiz_repository.dart)
  - `QuizSessionModel` & `QuestionModel`

## 🔴 Obsolète / Doublons identifiés
- **Doublon de Repository :**
  - `lib/data/repositories/quiz_repository.dart` (À fusionner ou supprimer au profit de la version dans features/quiz)
- **Anciennes Routes / Exports :**
  - `lib/features/quiz/quiz_screen.dart` (Export inutile)
  - `lib/features/quiz/quiz_setup_screen.dart` (Export inutile)
- **Composants potentiellement redondants :**
  - `QuizSoloSetupScreen` vs `QuizSetupScreen` (Doublon de sélection ?)

## ⚠️ Conflits & Risques
1. **Double Navigation :** Des quiz sont lancés depuis le `ShellRoute` (BottomNav) et d'autres en `rootNavigator`. Risque de perte d'état.
2. **Logique métier éparpillée :** Le calcul du score et la validation des réponses semblent codés en dur dans plusieurs `Screens` au lieu d'un `QuizViewModel` centralisé.
3. **Gestion des assets :** Les JSON de quiz sont éparpillés dans `data/quiz/optimus/`, rendant le debug difficile sans un chargeur (Loader) unique.

## 🎯 Recommandation Refactor (Phase 4-5)
- Centraliser tout dans `lib/features/quiz/viewmodels/quiz_notifier.dart` (Riverpod).
- Unifier les écrans de jeu (`QuizScreen`, `Survival`, `Quick`) en un seul `QuizGameScreen` piloté par une configuration.
