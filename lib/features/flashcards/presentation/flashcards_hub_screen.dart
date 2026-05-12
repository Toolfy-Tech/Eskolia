import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/eskolia_layout.dart';
import '../../../core/theme/eskolia_visual.dart';
import '../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../shared/widgets/eskolia_shell_body.dart';
import '../../../shared/widgets/eskolia_app_bar.dart';
import '../../../shared/widgets/eskolia_card.dart';
import '../data/flashcard_deck_repository.dart';
import 'flashcard_session_screen.dart';

/// Hub flashcards — blueprint v3 § Flashcards + indicateur « à réviser ».
class FlashcardsHubScreen extends StatefulWidget {
  const FlashcardsHubScreen({super.key});

  @override
  State<FlashcardsHubScreen> createState() => _FlashcardsHubScreenState();
}

class _FlashcardsHubScreenState extends State<FlashcardsHubScreen> {
  final _repo = FlashcardDeckRepository();
  int _due = 0;
  int _total = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    setState(() => _loading = true);
    final due = await _repo.countDue();
    final all = await _repo.readAll();
    if (mounted) {
      setState(() {
        _due = due;
        _total = all.length;
        _loading = false;
      });
    }
  }

  void _openSession(List<DeckFlashcard> cards, {bool ephemeral = false}) {
    if (cards.isEmpty) return;
    context.push(
      '/flashcards/session',
      extra: FlashcardSessionRouteArgs(
        cards: cards,
        ephemeral: ephemeral,
        timed: false,
        survival: false,
      ),
    ).then((_) => _reload());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EskoliaVisual.bgDeep,
      appBar: EskoliaAppBar.standard(context, title: 'Flashcards'),
      body: Stack(
        children: [
          const EskoliaAmbientBackground(),
          EskoliaShellBody(
            safeAreaTop: false,
            child: RefreshIndicator(
              color: EskoliaVisual.neonViolet,
              onRefresh: _reload,
              child: ListView(
              padding: const EdgeInsets.fromLTRB(
                EskoliaLayout.screenPaddingH,
                12,
                EskoliaLayout.screenPaddingH,
                EskoliaLayout.screenPaddingBottom,
              ),
              children: [
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: EskoliaVisual.neonViolet,
                      ),
                    ),
                  )
                else ...[
                  EskoliaCardContent(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'À réviser aujourd\'hui',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$_due carte${_due > 1 ? 's' : ''} due${_due != 1 ? 's' : ''} · Paquet : $_total',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: _due == 0
                              ? null
                              : () async {
                                  final list = await _repo.dueCards();
                                  list.shuffle();
                                  _openSession(
                                    list.take(20).toList(),
                                    ephemeral: false,
                                  );
                                },
                          style: FilledButton.styleFrom(
                            backgroundColor: EskoliaVisual.neonViolet,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.white.withValues(alpha: 0.12),
                            disabledForegroundColor: Colors.white.withValues(alpha: 0.38),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Lancer la révision'),
                        ),
                        if (_due == 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'Toutes les cartes sont à jour — reviens demain 🎉',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  EskoliaCardContent(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Flashcards rapides ⚡',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '10 cartes aléatoires TIP + Optimus — ou compose ta série (thèmes, niveaux). '
                          'Sans enregistrer le SRS.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 12,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 14),
                        OutlinedButton(
                          onPressed: () =>
                              context.push('/solo/flashcards-solo'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.35),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Démarrer'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  EskoliaCardContent(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Révision lacunes \u{1F4A1}',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Quiz QCM (max 10) sur tes erreurs — parcours, solo et multijoueur.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 12,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 14),
                        OutlinedButton(
                          onPressed: () =>
                              context.push('/quiz/revision-lacunes'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.35),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Lancer les lacunes'),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          ),
        ],
      ),
    );
  }
}
