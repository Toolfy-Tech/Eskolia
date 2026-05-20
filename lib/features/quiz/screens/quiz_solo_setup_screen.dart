import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/eskolia_layout.dart';
import '../../../core/theme/eskolia_visual.dart';
import '../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../shared/widgets/eskolia_app_bar.dart';
import '../../../shared/widgets/eskolia_button.dart';
import '../../../shared/widgets/eskolia_shell_body.dart';
import '../../../shared/widgets/teacher_quiz_picker_widget.dart';
import '../../notebook/data/saved_quiz_repository.dart';
import '../../parcours/data/tip_quiz_catalog.dart';
import '../services/quiz_repository.dart';
import '../components/quiz_catalog_track_selector.dart';
import '../components/quiz_scope_picker.dart';

const Color _violet = Color(0xFF6C63FF);
const Color _green = Color(0xFF4CAF50);
const Color _slate = Color(0xFF94A3B8);

/// Compose un quiz solo (Mode Maîtrise).
class QuizSoloSetupScreen extends StatefulWidget {
  const QuizSoloSetupScreen({super.key});

  @override
  State<QuizSoloSetupScreen> createState() => _QuizSoloSetupScreenState();
}

class _QuizSoloSetupScreenState extends State<QuizSoloSetupScreen> {
  List<TipQuizChapterRef>? _chapters;
  Object? _error;
  Set<String> _selectedPaths = {};
  int _questionCount = 15;
  bool _busy = false;
  QuizCatalogTrack _catalogTrack = QuizCatalogTrack.optimusOnly;
  List<SavedNotebookQuiz> _savedQuizzes = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        TipQuizCatalog.loadChaptersWithQuiz(),
        SavedQuizRepository().loadAll(),
      ]);
      if (!mounted) return;
      setState(() {
        _chapters = results[0] as List<TipQuizChapterRef>;
        _savedQuizzes = results[1] as List<SavedNotebookQuiz>;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    }
  }

  Future<void> _playSavedQuiz(SavedNotebookQuiz quiz) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final session = await QuizRepository().buildFromNotebookQuizJson(
        quiz.rawJson,
        quiz.title,
      );
      if (!mounted) return;
      context.push('/quiz/run', extra: session);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quiz invalide — regenere-le depuis tes notes.')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _deleteSavedQuiz(SavedNotebookQuiz quiz) async {
    await SavedQuizRepository().delete(quiz.id);
    if (!mounted) return;
    setState(() => _savedQuizzes.removeWhere((q) => q.id == quiz.id));
  }

  Future<void> _startQuickRandom() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final session = await QuizRepository().buildQuickRandomSession(
        questionCount: 10,
        catalogTrack: QuizCatalogTrack.optimusOnly,
        timed: false,
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
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _start() async {
    if (_busy || _selectedPaths.isEmpty) {
      if (_selectedPaths.isEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sélectionne au moins un chapitre.'),
          ),
        );
      }
      return;
    }
    setState(() => _busy = true);
    try {
      final session = await QuizRepository().buildSoloComposeSession(
        quizAssetPaths: _selectedPaths.toList(),
        difficultyFilters: const {}, // Toutes les difficultés
        maxQuestions: _questionCount,
        timed: false,
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
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EskoliaVisual.bgDeep,
      appBar: EskoliaAppBar.standard(context, title: 'Mode Maîtrise'),
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
    final filtered = TipQuizCatalog.filterByTrack(all, _catalogTrack);

    return ListView(
      padding: EdgeInsets.fromLTRB(
        EskoliaLayout.screenPaddingH,
        12,
        EskoliaLayout.screenPaddingH,
        120,
      ),
      children: [
        // Quick Start Card
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _busy ? null : _startQuickRandom,
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
                          _busy ? 'Préparation…' : 'Maîtrise rapide — 10 questions',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tirage aléatoire dans tout le catalogue Optimus.',
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
                  const Icon(
                    Icons.play_circle_fill_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_savedQuizzes.isNotEmpty) ...[
          const SizedBox(height: 24),
          _buildSectionHeader('Mes quiz IA'),
          const SizedBox(height: 10),
          ..._savedQuizzes.map((q) => _SavedQuizCard(
                quiz: q,
                busy: _busy,
                onPlay: () => _playSavedQuiz(q),
                onDelete: () => _deleteSavedQuiz(q),
              )),
        ],

        const SizedBox(height: 24),

        const Text(
          'Entraînement personnalisé',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 16),

        // Settings Section
        _buildSectionHeader('Options'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nombre de questions : $_questionCount',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  Slider(
                    value: _questionCount.toDouble(),
                    min: 5,
                    max: 30,
                    divisions: 25,
                    label: '$_questionCount',
                    activeColor: EskoliaVisual.neonCyan,
                    onChanged: (v) => setState(() => _questionCount = v.round()),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Sources Section
        _buildSectionHeader('Sources des questions'),
        const SizedBox(height: 8),
        QuizCatalogTrackSelector(
          value: _catalogTrack,
          dense: true,
          onChanged: (t) {
            setState(() {
              _catalogTrack = t;
              if (t == QuizCatalogTrack.teacher) {
                _selectedPaths.removeWhere((p) => !p.startsWith(TipQuizCatalog.teacherSentinelPrefix));
              } else {
                final allowed = TipQuizCatalog.filterByTrack(all, t)
                    .map((e) => e.quizAssetPath)
                    .toSet();
                _selectedPaths.removeWhere((p) => !allowed.contains(p));
              }
            });
          },
        ),
        const SizedBox(height: 12),
        if (_catalogTrack == QuizCatalogTrack.teacher) ...[
          SizedBox(
            height: 260,
            child: TeacherQuizPickerWidget(
              selectedPath: _selectedPaths.firstOrNull,
              onSelected: (path) => setState(() => _selectedPaths = {path}),
            ),
          ),
        ] else ...[
          QuizScopePicker(
            entries: filtered,
            selectedPaths: _selectedPaths,
            onSelectionChanged: (s) => setState(() => _selectedPaths = {...s}),
          ),
        ],
        const SizedBox(height: 24),

        EskoliaButton(
          label: _busy ? 'Préparation…' : 'Lancer la Maîtrise',
          variant: EskoliaButtonVariant.primary,
          expand: true,
          onPressed: _busy ? null : _start,
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.9),
        fontWeight: FontWeight.w700,
        fontSize: 13,
      ),
    );
  }
}

class _SavedQuizCard extends StatelessWidget {
  const _SavedQuizCard({
    required this.quiz,
    required this.busy,
    required this.onPlay,
    required this.onDelete,
  });

  final SavedNotebookQuiz quiz;
  final bool busy;
  final VoidCallback onPlay;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border(
          left: BorderSide(color: _green, width: 3),
          top: BorderSide(color: Colors.white.withValues(alpha: 0.07)),
          right: BorderSide(color: Colors.white.withValues(alpha: 0.07)),
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.07)),
        ),
      ),
      child: Row(
        children: [
          const Text('\u{1F4DD}', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quiz.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (quiz.noteTitle != null && quiz.noteTitle != quiz.title)
                  Text(
                    'Note : ${quiz.noteTitle}',
                    style: TextStyle(
                      color: _slate.withValues(alpha: 0.7),
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.play_arrow_rounded, color: _green, size: 22),
            onPressed: busy ? null : onPlay,
            tooltip: 'Jouer',
            constraints: const BoxConstraints.tightFor(width: 36, height: 36),
            padding: EdgeInsets.zero,
          ),
          IconButton(
            icon: Icon(Icons.delete_outline_rounded,
                color: _slate.withValues(alpha: 0.5), size: 18),
            onPressed: onDelete,
            tooltip: 'Supprimer',
            constraints: const BoxConstraints.tightFor(width: 32, height: 32),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}
