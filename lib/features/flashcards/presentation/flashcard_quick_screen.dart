import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/eskolia_layout.dart';
import '../../../core/theme/eskolia_visual.dart';
import '../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../shared/widgets/eskolia_shell_body.dart';
import '../../parcours/data/tip_quiz_catalog.dart';
import '../data/flashcard_deck_repository.dart';
import '../../quiz/presentation/widgets/quiz_catalog_track_selector.dart';
import 'flashcard_session_screen.dart';

/// Flashcards rapides — même tirage que le quiz rapide, banque au choix.
class FlashcardQuickScreen extends StatefulWidget {
  const FlashcardQuickScreen({
    super.key,
    this.initialCatalogTrack = QuizCatalogTrack.optimusOnly,
  });

  final QuizCatalogTrack initialCatalogTrack;

  @override
  State<FlashcardQuickScreen> createState() => _FlashcardQuickScreenState();
}

class _FlashcardQuickScreenState extends State<FlashcardQuickScreen> {
  late QuizCatalogTrack _catalogTrack;
  Object? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _catalogTrack = widget.initialCatalogTrack;
  }

  Future<void> _go() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final cards = await FlashcardDeckRepository().buildEphemeralQuickSet(
        count: 10,
        catalogTrack: _catalogTrack,
      );
      if (!mounted) return;
      context.pushReplacement(
        '/flashcards/session',
        extra: FlashcardSessionRouteArgs(
          cards: cards,
          ephemeral: true,
          timed: false,
          survival: false,
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = e;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const EskoliaAmbientBackground(),
          EskoliaShellBody(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(EskoliaLayout.screenPaddingH),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                  const Text(
                    'Flashcards rapides',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Même logique que le quiz rapide — 10 cartes.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.65),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  QuizCatalogTrackSelector(
                    value: _catalogTrack,
                    onChanged: _busy
                        ? (_) {}
                        : (t) => setState(() => _catalogTrack = t),
                  ),
                  const SizedBox(height: 24),
                  if (_error != null) ...[
                    Icon(Icons.error_outline,
                        color: Colors.red.shade200, size: 40),
                    const SizedBox(height: 12),
                    Text(
                      '$_error',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red.shade200, fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                  ],
                  FilledButton.icon(
                    onPressed: _busy ? null : _go,
                    style: FilledButton.styleFrom(
                      backgroundColor: EskoliaVisual.neonGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                    ),
                    icon: _busy
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.style_rounded),
                    label: Text(_busy ? 'Préparation…' : 'Lancer 10 cartes'),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _busy ? null : () => context.pop(),
                    child: const Text('Retour'),
                  ),
                ],
              ),
            ),
            ),
          ),
        ],
      ),
    );
  }
}
