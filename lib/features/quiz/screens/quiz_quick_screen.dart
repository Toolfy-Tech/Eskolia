import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/eskolia_layout.dart';
import '../../../core/theme/eskolia_visual.dart';
import '../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../shared/widgets/eskolia_shell_body.dart';
import '../../parcours/data/tip_quiz_catalog.dart';
import '../services/quiz_repository.dart';
import '../components/quiz_catalog_track_selector.dart';

/// **Quiz rapide** (10 questions) — banque Optimus.
class QuizQuickScreen extends StatefulWidget {
  const QuizQuickScreen({
    super.key,
    this.initialCatalogTrack = QuizCatalogTrack.optimusOnly,
  });

  final QuizCatalogTrack initialCatalogTrack;

  @override
  State<QuizQuickScreen> createState() => _QuizQuickScreenState();
}

class _QuizQuickScreenState extends State<QuizQuickScreen> {
  late QuizCatalogTrack _catalogTrack;
  Object? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _catalogTrack = widget.initialCatalogTrack;
  }

  Future<void> _start() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final session = await QuizRepository().buildQuickRandomSession(
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
      backgroundColor: EskoliaVisual.bgDeep,
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
                    'Quiz rapide ⚡',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'D’où tirer les questions ?',
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
                    onPressed: _busy ? null : _start,
                    style: FilledButton.styleFrom(
                      backgroundColor: EskoliaVisual.neonViolet,
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
                    label: Text(_busy ? 'Préparation…' : 'Lancer (10 questions)'),
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
