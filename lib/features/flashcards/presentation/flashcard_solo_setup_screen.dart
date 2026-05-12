import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/eskolia_layout.dart';
import '../../../core/theme/eskolia_visual.dart';
import '../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../shared/widgets/eskolia_app_bar.dart';
import '../../../shared/widgets/eskolia_button.dart';
import '../../../shared/widgets/eskolia_shell_body.dart';
import '../../parcours/data/tip_quiz_catalog.dart';
import '../../quiz/presentation/widgets/quiz_catalog_track_selector.dart';
import '../../quiz/presentation/widgets/quiz_scope_picker.dart';
import '../data/flashcard_deck_repository.dart';
import 'flashcard_session_screen.dart';

const Color _slate = Color(0xFF94A3B8);
const Color _violet = Color(0xFF6C63FF);

/// Flashcards solo : série rapide 10 cartes ou composition (mêmes choix que quiz solo + survival optionnel).
class FlashcardSoloSetupScreen extends StatefulWidget {
  const FlashcardSoloSetupScreen({super.key});

  @override
  State<FlashcardSoloSetupScreen> createState() =>
      _FlashcardSoloSetupScreenState();
}

class _FlashcardSoloSetupScreenState extends State<FlashcardSoloSetupScreen> {
  final _deckRepo = FlashcardDeckRepository();
  List<TipQuizChapterRef>? _chapters;
  Object? _error;
  Set<String> _selectedPaths = {};
  final Set<String> _difficulties = {
    'facile',
    'moyen',
    'difficile',
  };
  int _cardCount = 15;
  bool _timed = true;
  bool _survival = false;
  bool _busy = false;
  QuizCatalogTrack _catalogTrack = QuizCatalogTrack.both;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final list = await TipQuizCatalog.loadChaptersWithQuiz();
      if (!mounted) return;
      setState(() {
        _chapters = list;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    }
  }

  Future<void> _startQuickRandomAllPools() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final cards = await _deckRepo.buildEphemeralQuickSet(
        count: 10,
        catalogTrack: QuizCatalogTrack.both,
      );
      if (!mounted) return;
      context.push(
        '/flashcards/session',
        extra: FlashcardSessionRouteArgs(
          cards: cards,
          ephemeral: true,
          timed: _timed,
          survival: _survival,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _start() async {
    if (_busy || _selectedPaths.isEmpty) {
      if (_selectedPaths.isEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sélectionne au moins un chapitre avec QCM.'),
          ),
        );
      }
      return;
    }
    if (_difficulties.isEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Coche au moins un niveau de difficulté.'),
        ),
      );
      return;
    }
    setState(() => _busy = true);
    try {
      final cards = await _deckRepo.buildEphemeralSoloComposeSet(
        quizAssetPaths: _selectedPaths.toList(),
        difficultyFilters: Set<String>.from(_difficulties),
        maxCards: _cardCount,
      );
      if (!mounted) return;
      context.push(
        '/flashcards/session',
        extra: FlashcardSessionRouteArgs(
          cards: cards,
          ephemeral: true,
          timed: _timed,
          survival: _survival,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
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
            child: _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        '$_error',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.red.shade200),
                      ),
                    ),
                  )
                : _chapters == null
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: EskoliaVisual.neonCyan,
                        ),
                      )
                    : _buildForm(context),
          ),
          if (_busy)
            ModalBarrier(
              color: Colors.black.withValues(alpha: 0.45),
              dismissible: false,
            ),
          if (_busy)
            const Center(
              child: CircularProgressIndicator(color: EskoliaVisual.neonCyan),
            ),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    final all = _chapters!;

    return ListView(
      padding: EdgeInsets.fromLTRB(
        EskoliaLayout.screenPaddingH,
        12,
        EskoliaLayout.screenPaddingH,
        120,
      ),
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _busy ? null : _startQuickRandomAllPools,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    _violet.withValues(alpha: 0.85),
                    EskoliaVisual.neonCyan.withValues(alpha: 0.65),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: _violet.withValues(alpha: 0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Text('\u{26A1}', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _busy ? 'Préparation…' : 'Flashcards rapides — 10 cartes',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tirage aléatoire dans tout le catalogue TIP + Optimus.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.92),
                            fontSize: 12,
                            height: 1.3,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.play_circle_fill_rounded,
                    color: Colors.white.withValues(alpha: 0.95),
                    size: 36,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Options de partie',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilterChip(
              label: const Text('Chrono'),
              selected: _timed,
              onSelected: (v) => setState(() => _timed = v),
            ),
            FilterChip(
              label: const Text('Survival (3 vies)'),
              selected: _survival,
              onSelected: (v) => setState(() => _survival = v),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Difficulté des questions',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilterChip(
              label: const Text('Facile'),
              selected: _difficulties.contains('facile'),
              onSelected: (v) => setState(() {
                if (v) {
                  _difficulties.add('facile');
                } else {
                  _difficulties.remove('facile');
                }
              }),
            ),
            FilterChip(
              label: const Text('Moyen'),
              selected: _difficulties.contains('moyen'),
              onSelected: (v) => setState(() {
                if (v) {
                  _difficulties.add('moyen');
                } else {
                  _difficulties.remove('moyen');
                }
              }),
            ),
            FilterChip(
              label: const Text('Difficile'),
              selected: _difficulties.contains('difficile'),
              onSelected: (v) => setState(() {
                if (v) {
                  _difficulties.add('difficile');
                } else {
                  _difficulties.remove('difficile');
                }
              }),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Les questions sans niveau clair sont traitées comme « moyen » si tu coches Moyen.',
          style: TextStyle(
            color: _slate.withValues(alpha: 0.75),
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Nombre de cartes : $_cardCount',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
        Slider(
          value: _cardCount.toDouble(),
          min: 5,
          max: 30,
          divisions: 25,
          label: '$_cardCount',
          activeColor: EskoliaVisual.neonCyan,
          onChanged: (v) => setState(() => _cardCount = v.round()),
        ),
        const SizedBox(height: 16),
        Text(
          'Sources des questions',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${_selectedPaths.length} fichier(s) QCM · même sélecteur compact qu’en quiz solo',
          style: TextStyle(
            color: EskoliaVisual.neonCyan.withValues(alpha: 0.9),
            fontSize: 11,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Banque',
          style: TextStyle(
            color: _slate.withValues(alpha: 0.95),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        QuizCatalogTrackSelector(
          value: _catalogTrack,
          dense: true,
          onChanged: (t) {
            setState(() {
              _catalogTrack = t;
              final allowed = TipQuizCatalog.filterByTrack(all, t)
                  .map((e) => e.quizAssetPath)
                  .toSet();
              _selectedPaths.removeWhere((p) => !allowed.contains(p));
            });
          },
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 280,
          child: QuizScopePicker(
            entries: TipQuizCatalog.filterByTrack(all, _catalogTrack),
            selectedPaths: _selectedPaths,
            onSelectionChanged: (s) => setState(() => _selectedPaths = {...s}),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '${_selectedPaths.length} chapitre(s) sélectionné(s)',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _slate.withValues(alpha: 0.9),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 12),
        EskoliaButton(
          label: _busy ? 'Préparation…' : 'Lancer la série flashcards',
          variant: EskoliaButtonVariant.primary,
          expand: true,
          onPressed: _busy ? null : _start,
        ),
      ],
    );
  }
}
