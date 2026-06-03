# Plan de passage Alpha → Bêta

Branche : `claude/beta-ui-refactor`

---

## PHASE 1 — Design Tokens (fondation)

- [x] 1.1 Créer `lib/core/constants/eskolia_tokens.dart` (couleurs, spacing, radius, shadows)
- [x] 1.2 Mettre à jour `lib/core/theme/app_theme.dart` (utiliser les tokens)
- [x] 1.3 Mettre à jour `lib/core/theme/eskolia_visual.dart` (glows, gradients via tokens)

## PHASE 2 — Composants partagés

- [x] 2.1 `lib/shared/widgets/eskolia_button.dart` — radius 12→token, couleurs via tokens
- [x] 2.2 `lib/shared/widgets/eskolia_card.dart` — surfaces via tokens
- [x] 2.3 `lib/shared/widgets/eskolia_text_field.dart` — couleurs via tokens
- [x] 2.4 `lib/shared/widgets/gradient_border_card.dart` — innerColor via token
- [x] 2.5 `lib/shared/widgets/question_thumbs_widget.dart` — couleurs via tokens

## PHASE 3 — Écrans UI (remplacement couleurs hardcodées)

- [x] 3.1 `lib/features/home/presentation/home_screen.dart`
- [x] 3.2 `lib/features/home/presentation/widgets/tech_news_section.dart`
- [x] 3.3 `lib/features/parcours/presentation/parcours_screen.dart`
- [x] 3.4 `lib/features/parcours/presentation/chapter_lesson_screen.dart`
- [x] 3.5 `lib/features/parcours/presentation/widgets/lexique_section.dart`
- [x] 3.6 `lib/features/parcours/presentation/widgets/mediatheque_section.dart`
- [x] 3.7 `lib/features/parcours/presentation/widgets/support_section.dart`
- [x] 3.8 `lib/features/auth/presentation/login_screen.dart`
- [x] 3.9 `lib/features/settings/presentation/settings_screen.dart`
- [x] 3.10 `lib/features/quiz/screens/quiz_screen.dart`
- [x] 3.11 `lib/features/quiz/screens/quiz_setup_screen.dart`
- [x] 3.12 `lib/features/ai/presentation/ai_setup_screen.dart`
- [x] 3.13 `lib/features/docs/presentation/docs_screen.dart`
- [x] 3.14 `lib/features/podcasts/presentation/podcasts_screen.dart`

## PHASE 4 — Corrections fonctionnelles (QA)

- [x] 4.1 `parcours_screen.dart` — extraire post-frame callback vers `_onFirstFrame()` avec mounted checks entre chaque await
- [x] 4.2 `parcours_screen.dart` — dédupliquer les branches _SkeletonLoader dans StreamBuilder
- [x] 4.3 `chapter_lesson_screen.dart` — Future.wait() pour les 3 inits async parallèles
- [x] 4.4 `quiz_screen.dart` — spinner de chargement pendant init du shuffle séquence
- [x] 4.5 `tip_progress_repository.dart` — validation déjà en place (isEmpty + préfixe)
