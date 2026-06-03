# Plan de passage Alpha → Bêta

Branche : `claude/beta-ui-refactor`

---

## PHASE 1 — Design Tokens (fondation)

- [ ] 1.1 Créer `lib/core/constants/eskolia_tokens.dart` (couleurs, spacing, radius, shadows)
- [ ] 1.2 Mettre à jour `lib/core/theme/app_theme.dart` (utiliser les tokens)
- [ ] 1.3 Mettre à jour `lib/core/theme/eskolia_visual.dart` (glows, gradients via tokens)

## PHASE 2 — Composants partagés

- [ ] 2.1 `lib/shared/widgets/eskolia_button.dart` — radius 12→token, couleurs via tokens
- [ ] 2.2 `lib/shared/widgets/eskolia_card.dart` — surfaces via tokens
- [ ] 2.3 `lib/shared/widgets/eskolia_text_field.dart` — couleurs via tokens
- [ ] 2.4 `lib/shared/widgets/gradient_border_card.dart` — innerColor via token
- [ ] 2.5 `lib/shared/widgets/question_thumbs_widget.dart` — catch _ → log + feedback

## PHASE 3 — Écrans UI (remplacement couleurs hardcodées)

- [ ] 3.1 `lib/features/home/presentation/home_screen.dart`
- [ ] 3.2 `lib/features/home/presentation/widgets/tech_news_section.dart`
- [ ] 3.3 `lib/features/parcours/presentation/parcours_screen.dart`
- [ ] 3.4 `lib/features/parcours/presentation/chapter_lesson_screen.dart`
- [ ] 3.5 `lib/features/parcours/presentation/widgets/lexique_section.dart`
- [ ] 3.6 `lib/features/parcours/presentation/widgets/mediatheque_section.dart`
- [ ] 3.7 `lib/features/parcours/presentation/widgets/support_section.dart`
- [ ] 3.8 `lib/features/auth/presentation/login_screen.dart`
- [ ] 3.9 `lib/features/settings/presentation/settings_screen.dart`
- [ ] 3.10 `lib/features/quiz/presentation/quiz_screen.dart`
- [ ] 3.11 `lib/features/quiz/presentation/quiz_setup_screen.dart`
- [ ] 3.12 `lib/features/ai/presentation/ai_setup_screen.dart`
- [ ] 3.13 `lib/features/docs/presentation/docs_screen.dart`
- [ ] 3.14 `lib/features/podcasts/presentation/podcasts_screen.dart`

## PHASE 4 — Corrections fonctionnelles (QA)

- [ ] 4.1 `parcours_screen.dart` — extraire post-frame callbacks vers notifier
- [ ] 4.2 `parcours_screen.dart` — distinguer états loading / empty / error
- [ ] 4.3 `chapter_lesson_screen.dart` — Future.wait() pour les 3 inits async
- [ ] 4.4 `quiz_screen.dart` — ajouter loading state pour shuffle séquences
- [ ] 4.5 `tip_progress_repository.dart` — valider moduleId avant markModulePassed
