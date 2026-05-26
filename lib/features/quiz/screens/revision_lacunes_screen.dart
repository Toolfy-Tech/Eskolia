import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/eskolia_layout.dart';
import '../../../core/theme/eskolia_visual.dart';
import '../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../shared/widgets/eskolia_app_bar.dart';
import '../../../shared/widgets/eskolia_button.dart';
import '../../../shared/widgets/eskolia_shell_body.dart';
import '../../parcours/data/tip_quiz_catalog.dart';
import '../services/quiz_repository.dart';
import '../components/quiz_catalog_track_selector.dart';

const Color _slate = Color(0xFF94A3B8);

/// Solo : révision lacunes — uniquement un quiz Maîtrise (jusqu’à 10 questions,
/// ou moins s’il y a moins d’erreurs en attente). Pas de flashcards.
class RevisionLacunesScreen extends StatefulWidget {
  const RevisionLacunesScreen({
    super.key,
    this.initialCatalogTrack = QuizCatalogTrack.optimusOnly,
  });

  final QuizCatalogTrack initialCatalogTrack;

  @override
  State<RevisionLacunesScreen> createState() => _RevisionLacunesScreenState();
}

class _RevisionLacunesScreenState extends State<RevisionLacunesScreen> {
  late QuizCatalogTrack _catalogTrack;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _catalogTrack = widget.initialCatalogTrack;
  }

  Future<void> _startQuiz() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final session = await QuizRepository().buildGapReviewSession(
        questionCount: 10,
        catalogTrack: _catalogTrack,
      );
      if (!mounted) return;
      context.pushReplacement('/quiz/run', extra: session);
    } catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: EskoliaVisual.bgDeep,
      appBar: EskoliaAppBar.standard(
        context,
        title: 'Lacunes',
      ),
      body: Stack(
        children: [
          const EskoliaAmbientBackground(),
          EskoliaShellBody(
            safeAreaTop: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                EskoliaLayout.screenPaddingH,
                16,
                EskoliaLayout.screenPaddingH,
                EskoliaLayout.screenPaddingBottom,
              ),
              children: [
                Text(
                  'Les lacunes, ce sont les questions où tu as eu faux '
                  '(parcours, quiz solo ou multijoueur). Elles restent en file '
                  'jusqu’à ce que tu répondes juste ici — en quiz Maîtrise, '
                  'jusqu’à 10 questions par session (moins si tu as moins de lacunes).',
                  style: TextStyle(
                    color: _slate.withValues(alpha: 0.95),
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Banque Maîtrise',
                  style: TextStyle(
                    color: _slate.withValues(alpha: 0.95),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                QuizCatalogTrackSelector(
                  value: _catalogTrack,
                  onChanged: _busy
                      ? (_) {}
                      : (t) => setState(() => _catalogTrack = t),
                ),
                const SizedBox(height: 20),
                if (_error != null) ...[
                  Text(
                    _error!,
                    style: TextStyle(
                      color: Colors.red.shade200,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                EskoliaButton(
                  label: _busy ? 'Préparation…' : 'Lancer le quiz lacunes',
                  variant: EskoliaButtonVariant.primary,
                  expand: true,
                  onPressed: _busy ? null : _startQuiz,
                ),
              ],
            ),
          ),
          if (_busy)
            ModalBarrier(
              color: Colors.black.withValues(alpha: 0.45),
              dismissible: false,
            ),
          if (_busy)
            const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Color(0xFF00BCD4)),
                  SizedBox(height: 16),
                  Text(
                    'Préparation…',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
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
