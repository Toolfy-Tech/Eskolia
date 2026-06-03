import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/eskolia_tokens.dart';
import '../../../core/theme/eskolia_layout.dart';
import '../../../core/theme/eskolia_visual.dart';
import '../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../shared/widgets/eskolia_shell_body.dart';
import '../../parcours/data/tip_quiz_catalog.dart';
import '../services/quiz_repository.dart';
import '../services/survival_high_scores_repository.dart';
import '../components/quiz_catalog_track_selector.dart';

/// **Survival solo** — 3 vies, difficulté progressive.
class QuizSurvivalScreen extends StatefulWidget {
  const QuizSurvivalScreen({
    super.key,
    this.initialCatalogTrack = QuizCatalogTrack.optimusOnly,
  });

  final QuizCatalogTrack initialCatalogTrack;

  @override
  State<QuizSurvivalScreen> createState() => _QuizSurvivalScreenState();
}

class _QuizSurvivalScreenState extends State<QuizSurvivalScreen> {
  late QuizCatalogTrack _catalogTrack;
  Object? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _catalogTrack = widget.initialCatalogTrack;
  }

  String _trackLabel(QuizCatalogTrack t) {
    return 'Optimus';
  }

  Future<void> _start() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final session = await QuizRepository().buildSurvivalSession(
        catalogTrack: _catalogTrack,
      );
      if (!mounted) return;
      context.pushReplacement('/quiz/run', extra: session);
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(EskoliaLayout.screenPaddingH),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Survival \u{1F480}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Comme l’Arena : 3 vies, chrono par question. '
                      'Les items vont du facile au difficile. Dure jusqu’à épuisement des vies.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Banque des questions',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.65),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    QuizCatalogTrackSelector(
                      value: _catalogTrack,
                      onChanged: _busy
                          ? (_) {}
                          : (t) => setState(() => _catalogTrack = t),
                    ),
                    const SizedBox(height: 20),
                    FutureBuilder<List<int>>(
                      key: ValueKey<QuizCatalogTrack>(_catalogTrack),
                      future: SurvivalHighScoresRepository()
                          .readTopThree(_catalogTrack),
                      builder: (context, snap) {
                        final top = snap.data ?? const <int>[];
                        if (top.isEmpty) {
                          return Text(
                            'Aucun score enregistré.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.45),
                              fontSize: 11,
                            ),
                          );
                        }
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tes records (${_trackLabel(_catalogTrack)})',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 6),
                              for (var i = 0; i < top.length; i++)
                                Text(
                                  '#${i + 1} — ${top[i]} bonnes réponses',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.75),
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    if (_error != null) ...[
                      Icon(Icons.error_outline,
                          color: Colors.red.shade200, size: 40),
                      const SizedBox(height: 12),
                      Text(
                        '$_error',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.red.shade200,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    FilledButton.icon(
                      onPressed: _busy ? null : _start,
                      style: FilledButton.styleFrom(
                        backgroundColor: EskoliaTokens.error,
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
                          : const Icon(Icons.play_arrow_rounded),
                      label: Text(_busy ? 'Préparation…' : 'Lancer le Survival'),
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
