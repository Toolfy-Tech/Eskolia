import 'dart:math' show Random, min;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/eskolia_tokens.dart';
import '../../../core/theme/eskolia_layout.dart';
import '../../../core/theme/eskolia_visual.dart';
import '../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../shared/widgets/eskolia_app_bar.dart';
import '../../../shared/widgets/eskolia_shell_body.dart';
import '../../../shared/widgets/gradient_border_card.dart';
import '../../flashcards/data/flashcard_deck_repository.dart';
import '../../flashcards/presentation/flashcard_session_screen.dart';
import '../../quiz/data/quiz_repository.dart';
import '../../quiz/presentation/revision_pool_launch_mode.dart';


/// Hub : pool 📌 épinglé + paquet SRS, chacun en quiz QCM ou flashcards.
class SoloRevisionMenuScreen extends StatefulWidget {
  const SoloRevisionMenuScreen({super.key});

  @override
  State<SoloRevisionMenuScreen> createState() => _SoloRevisionMenuScreenState();
}

class _SoloRevisionMenuScreenState extends State<SoloRevisionMenuScreen> {
  bool _busySrsQuiz = false;

  void _openPoolQuiz() {
    context.push('/revision-pool', extra: RevisionPoolLaunchMode.quizAll);
  }

  void _openPoolFlashcards() {
    context.push('/revision-pool', extra: RevisionPoolLaunchMode.flashcardsAll);
  }

  void _browsePool() {
    context.push('/revision-pool');
  }

  Future<void> _openSrsFlashcards() async {
    final repo = FlashcardDeckRepository();
    final due = await repo.dueCards();
    if (!mounted) return;
    if (due.isEmpty) {
      context.push('/flashcards');
      return;
    }
    final list = List<DeckFlashcard>.from(due)..shuffle(Random());
    await context.push(
      '/flashcards/session',
      extra: FlashcardSessionRouteArgs(
        cards: list.take(20).toList(),
        ephemeral: false,
        timed: false,
        survival: false,
      ),
    );
  }

  Future<void> _openSrsQuiz() async {
    if (_busySrsQuiz) return;
    setState(() => _busySrsQuiz = true);
    try {
      final repo = FlashcardDeckRepository();
      var cards = await repo.dueCards();
      if (cards.isEmpty) {
        cards = await repo.readAll();
      }
      if (cards.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Paquet vide. Ajoute des cartes depuis l’écran de résultats d’un quiz.',
            ),
          ),
        );
        return;
      }
      final n = min(20, cards.length);
      final session = await QuizRepository().buildSrsDeckQuizSession(
        cards: cards,
        maxQuestions: n,
      );
      if (!mounted) return;
      context.push('/quiz/run', extra: session);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busySrsQuiz = false);
    }
  }

  void _openSrsHub() {
    context.push('/flashcards');
  }

  @override
  Widget build(BuildContext context) {
    final busy = _busySrsQuiz;
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: EskoliaAppBar.standard(context, title: 'Révision'),
      body: Stack(
        children: [
          const EskoliaAmbientBackground(),
          EskoliaShellBody(
            safeAreaTop: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                EskoliaLayout.screenPaddingH,
                12,
                EskoliaLayout.screenPaddingH,
                EskoliaLayout.screenPaddingBottom,
              ),
              children: [
                Text(
                  'Choisis d’abord ce que tu veux réviser (épingles ou paquet SRS), '
                  'puis le mode : quiz QCM ou flashcards.',
                  style: TextStyle(
                    color: EskoliaTokens.textSecondary.withValues(alpha: 0.95),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: busy ? null : _browsePool,
                  child: const Text('Ouvrir la liste du pool 📌 (sélection manuelle)'),
                ),
                const SizedBox(height: 12),
                GradientBorderCard(
                  gradientColors: const [EskoliaTokens.success, EskoliaTokens.violetSoft],
                  glowColor: EskoliaTokens.success,
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Row(
                        children: [
                          Text('\u{1F4CC}', style: TextStyle(fontSize: 22)),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Questions épinglées',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Ajoutées depuis les résultats de quiz (bouton pool 📌). '
                        'Session sur ta sélection ou sur tout le pool.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.72),
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: busy ? null : _openPoolQuiz,
                              icon: const Icon(Icons.quiz_outlined, size: 20),
                              label: const Text('Quiz'),
                              style: FilledButton.styleFrom(
                                backgroundColor: EskoliaTokens.violetSoft,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: busy ? null : _openPoolFlashcards,
                              icon: const Icon(Icons.style_outlined, size: 20),
                              label: const Text('Flashcards'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: BorderSide(
                                  color: EskoliaVisual.neonCyan
                                      .withValues(alpha: 0.65),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                GradientBorderCard(
                  gradientColors: const [EskoliaTokens.cyan, EskoliaTokens.violetSoft],
                  glowColor: EskoliaTokens.cyan,
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Row(
                        children: [
                          Text('\u{1F4E6}', style: TextStyle(fontSize: 22)),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Mon paquet SRS',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Cartes ajoutées à la fin d’un quiz. Le QCM pioche les réponses '
                        'dans ton paquet ; les flashcards suivent ton planning SRS.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.72),
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: busy ? null : _openSrsQuiz,
                              icon: busy
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.quiz_outlined, size: 20),
                              label: Text(
                                busy ? 'Préparation…' : 'Quiz',
                              ),
                              style: FilledButton.styleFrom(
                                backgroundColor: EskoliaTokens.violetSoft,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: busy ? null : _openSrsFlashcards,
                              icon: const Icon(Icons.style_outlined, size: 20),
                              label: const Text('Flashcards'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: BorderSide(
                                  color: EskoliaVisual.neonCyan
                                      .withValues(alpha: 0.65),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: busy ? null : _openSrsHub,
                        child: const Text('Gérer le paquet (hub flashcards)'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
