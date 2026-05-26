// ignore: avoid_web_libraries_in_flutter
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/eskolia_visual.dart';
import '../../../core/utils/eskolia_snackbar.dart';
import '../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../shared/widgets/eskolia_app_bar.dart';
import '../../../shared/widgets/eskolia_button.dart';
import '../../../shared/widgets/eskolia_card.dart';
import '../../../shared/widgets/eskolia_text_field.dart';
import '../../../core/services/eskolia_folder_service.dart';
import '../../ai/data/ai_key_repository.dart';
import '../../quiz/services/quiz_repository.dart';
import '../data/note_ai_generator.dart';
import '../data/note_model.dart';
import '../data/saved_quiz_repository.dart';

const Color _violet = Color(0xFF6C63FF);
const Color _slate  = Color(0xFF94A3B8);
const Color _green  = Color(0xFF4CAF50);
const Color _amber  = Color(0xFFFFC107);
const Color _red    = Color(0xFFEF4444);

// ── Modèle résultat ────────────────────────────────────────────────────────────

class _SubjectResult {
  const _SubjectResult({
    required this.subject,
    required this.course,
    required this.quizJson,
  });

  final String subject;
  final String course;
  final String quizJson;

  bool get hasCourse => course.isNotEmpty;

  bool get hasQuiz {
    try {
      final data = jsonDecode(quizJson) as Map<String, dynamic>;
      return ((data['questions'] as List?)?.isNotEmpty) ?? false;
    } catch (_) {
      return false;
    }
  }

  int get questionCount {
    try {
      final data = jsonDecode(quizJson) as Map<String, dynamic>;
      return ((data['questions'] as List<dynamic>?)?.length) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  List<(int, String, Color)> get typeSummary {
    const labels = <String, (String, Color)>{
      'classic':            ('Q&R',        Color(0xFF6C63FF)),
      'ticket':             ('Ticket',     Color(0xFF00BCD4)),
      'diagnostic_indices': ('Diagnostic', Color(0xFFFFC107)),
      'sequence':           ('Sequence',   Color(0xFF4CAF50)),
    };
    try {
      final data = jsonDecode(quizJson) as Map<String, dynamic>;
      final questions = data['questions'] as List<dynamic>? ?? [];
      final counts = <String, int>{};
      for (final q in questions) {
        if (q is! Map) continue;
        final t = (q['type'] as String?)?.trim() ?? 'classic';
        counts[t] = (counts[t] ?? 0) + 1;
      }
      return counts.entries.map((e) {
        final info = labels[e.key] ?? ('Autre', _slate);
        return (e.value, info.$1, info.$2);
      }).toList();
    } catch (_) {
      return [];
    }
  }
}

// ── Screen ─────────────────────────────────────────────────────────────────────

class NoteEditorScreen extends StatefulWidget {
  const NoteEditorScreen({super.key, this.note});

  /// Null = nouvelle session. Non-null = pre-peuplee avec le contenu de la note.
  final NoteModel? note;

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final _aiKeyRepo     = AiKeyRepository();
  final _aiGenerator   = NoteAiGenerator();
  final _savedQuizRepo = SavedQuizRepository();

  final List<TextEditingController> _controllers = [];

  bool _wantCours      = true;
  bool _wantQuiz       = true;
  bool _wantFlashcards = false;

  bool   _generating      = false;
  String _generationPhase = '';
  List<_SubjectResult> _results = [];
  String? _errorMessage;
  VoidCallback? _retryAction;
  String? _flashcardJson;

  @override
  void initState() {
    super.initState();
    if (widget.note != null && widget.note!.content.trim().isNotEmpty) {
      _controllers.add(TextEditingController(text: widget.note!.content.trim()));
    } else {
      _controllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  // ── Notes management ────────────────────────────────────────────────────────

  void _addNote() {
    if (_controllers.length >= 10) return;
    setState(() => _controllers.add(TextEditingController()));
  }

  void _removeNote(int index) {
    if (_controllers.length <= 1) return;
    _controllers[index].dispose();
    setState(() => _controllers.removeAt(index));
  }

  String _buildNotesPrompt() {
    final lines = <String>[];
    for (int i = 0; i < _controllers.length; i++) {
      final text = _controllers[i].text.trim();
      if (text.isNotEmpty) lines.add('Note ${i + 1} : $text');
    }
    return lines.join('\n\n');
  }

  // ── Generation IA ───────────────────────────────────────────────────────────

  Future<void> _generate(AiConnectionState aiState) async {
    if (_generating) return;
    if (!_wantCours && !_wantQuiz && !_wantFlashcards) {
      showEskoliaSnackBar(context, 'Coche au moins un type de contenu.');
      return;
    }
    final prompt = _buildNotesPrompt();
    if (prompt.isEmpty) {
      showEskoliaSnackBar(context, 'Ecris au moins une note avant de generer.');
      return;
    }
    setState(() {
      _generating      = true;
      _generationPhase = 'Analyse des notes...';
      _results         = [];
      _flashcardJson   = null;
      _errorMessage    = null;
    });
    _retryAction = () => _generate(aiState);

    try {
      if (_wantCours || _wantQuiz) {
        final label = (_wantCours && _wantQuiz)
            ? 'Generation des cours et quiz...'
            : _wantCours
                ? 'Generation des cours...'
                : 'Generation des quiz...';
        if (mounted) setState(() => _generationPhase = label);

        final buf = StringBuffer();

        if (_wantCours && _wantQuiz) {
          await for (final t in _aiGenerator.streamCombined(
            apiKey: aiState.apiKey!, provider: aiState.provider, allNotesContent: prompt,
          )) {
            if (!mounted) return;
            buf.write(t);
          }
          if (!mounted) return;
          final list = jsonDecode(NoteAiGenerator.extractJson(buf.toString())) as List;
          _results = list.map((e) {
            final m = e as Map<String, dynamic>;
            final subject = (m['subject'] as String?)?.trim() ?? 'Sujet';
            final rawQ    = (m['quiz'] as List?) ?? [];
            return _SubjectResult(
              subject:  subject,
              course:   (m['course'] as String?)?.trim() ?? '',
              quizJson: jsonEncode({'quiz': {'title': subject, 'description': '', 'author': 'IA Notebook'}, 'questions': rawQ}),
            );
          }).toList();
        } else if (_wantCours) {
          await for (final t in _aiGenerator.streamMultiCourse(
            apiKey: aiState.apiKey!, provider: aiState.provider, allNotesContent: prompt,
          )) {
            if (!mounted) return;
            buf.write(t);
          }
          if (!mounted) return;
          final list = jsonDecode(NoteAiGenerator.extractJson(buf.toString())) as List;
          _results = list.map((e) {
            final m = e as Map<String, dynamic>;
            return _SubjectResult(
              subject:  (m['subject'] as String?)?.trim() ?? 'Sujet',
              course:   (m['course'] as String?)?.trim() ?? '',
              quizJson: '{}',
            );
          }).toList();
        } else {
          await for (final t in _aiGenerator.streamMultiQuiz(
            apiKey: aiState.apiKey!, provider: aiState.provider, allNotesContent: prompt,
          )) {
            if (!mounted) return;
            buf.write(t);
          }
          if (!mounted) return;
          final list = jsonDecode(NoteAiGenerator.extractJson(buf.toString())) as List;
          _results = list.map((e) {
            final m = e as Map<String, dynamic>;
            final subject = (m['subject'] as String?)?.trim() ?? 'Sujet';
            final rawQ    = (m['questions'] as List?) ?? [];
            return _SubjectResult(
              subject:  subject,
              course:   '',
              quizJson: jsonEncode({'quiz': {'title': subject, 'description': '', 'author': 'IA Notebook'}, 'questions': rawQ}),
            );
          }).toList();
        }
        if (mounted) setState(() => _errorMessage = null);
      }

      if (_wantFlashcards && mounted) {
        setState(() => _generationPhase = 'Generation des flashcards...');
        final buf = StringBuffer();
        await for (final t in _aiGenerator.streamFlashcards(
          apiKey: aiState.apiKey!, provider: aiState.provider,
          noteContent: prompt, noteTitle: widget.note?.title ?? 'Notes',
        )) {
          if (!mounted) return;
          buf.write(t);
        }
        if (!mounted) return;
        setState(() => _flashcardJson = NoteAiGenerator.extractJson(buf.toString()));
      }
    } catch (e) {
      if (mounted) setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  // ── Download ─────────────────────────────────────────────────────────────────

  final _fs = EskoliaFolderService.instance;

  String _safeName(String subject) =>
      subject.replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(' ', '_').toLowerCase();

  Future<void> _downloadCourse(_SubjectResult item) => _fs.saveFile(
        EskoliaFolder.cours,
        'cours_${_safeName(item.subject)}.md',
        item.course,
        mimeType: 'text/markdown',
      );

  Future<void> _downloadQuiz(_SubjectResult item) => _fs.saveFile(
        EskoliaFolder.quiz,
        'quiz_${_safeName(item.subject)}.json',
        item.quizJson,
        mimeType: 'application/json',
      );

  // ── Quiz play / save ─────────────────────────────────────────────────────────

  Future<void> _playQuiz(_SubjectResult item) async {
    try {
      final session = await QuizRepository().buildFromNotebookQuizJson(
        item.quizJson,
        item.subject,
      );
      if (mounted) context.push('/quiz/run', extra: session);
    } on FormatException catch (e) {
      if (mounted) showEskoliaSnackBar(context, e.message);
    } catch (_) {
      if (mounted) showEskoliaSnackBar(context, 'Erreur inattendue — regenere le quiz.');
    }
  }

  Future<void> _saveQuiz(_SubjectResult item) async {
    try {
      await QuizRepository().buildFromNotebookQuizJson(item.quizJson, 'check');
    } on FormatException catch (e) {
      if (mounted) showEskoliaSnackBar(context, e.message);
      return;
    }
    await _savedQuizRepo.save(SavedNotebookQuiz.create(
      title:   item.subject,
      rawJson: item.quizJson,
    ));
    if (mounted) showEskoliaSnackBar(context, 'Quiz sauvegarde dans Mes quiz IA.');
  }

  // ── Course bottom sheet ───────────────────────────────────────────────────────

  void _openCourseSheet(_SubjectResult item) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CourseSheet(
        result:          item,
        onPlayQuiz:      () { Navigator.of(context).pop(); _playQuiz(item); },
        onDownloadQuiz:  () => _downloadQuiz(item),
        onDownloadCourse: () => _downloadCourse(item),
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: EskoliaVisual.bgDeep,
      appBar: EskoliaAppBar.standard(context, title: 'Assistant IA'),
      body: Stack(
        children: [
          const EskoliaAmbientBackground(),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 60),
                  children: [
                    _buildNotesSection(),
                    const SizedBox(height: 24),
                    _buildAiSection(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Notes section ────────────────────────────────────────────────────────────

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Text('\u{1F4DD}', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Mes notes',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
            if (_controllers.length < 10)
              TextButton.icon(
                onPressed: _addNote,
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Ajouter une note'),
                style: TextButton.styleFrom(foregroundColor: _violet),
              ),
          ],
        ),
        const SizedBox(height: 12),
        for (int i = 0; i < _controllers.length; i++) ...[
          _buildNoteRow(i),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _buildNoteRow(int index) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: _violet.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'Note ${index + 1}',
              style: const TextStyle(
                color: _violet,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: EskoliaTextField(
            controller: _controllers[index],
            hintText: 'Ex: Je galere avec le modele OSI...',
            maxLines: 4,
            minLines: 2,
          ),
        ),
        if (_controllers.length > 1) ...[
          const SizedBox(width: 4),
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: IconButton(
              icon: const Icon(Icons.close_rounded, size: 18, color: _red),
              onPressed: () => _removeNote(index),
              constraints: const BoxConstraints.tightFor(width: 32, height: 32),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ],
    );
  }

  // ── IA section ────────────────────────────────────────────────────────────────

  Widget _buildAiSection() {
    return StreamBuilder<AiConnectionState>(
      stream: _aiKeyRepo.watch(),
      builder: (context, snap) {
        final aiState = snap.data ?? const AiConnectionState(isConnected: false);
        if (!aiState.isConnected) {
          return _buildNotConnectedBanner();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome_rounded, color: _violet, size: 16),
                const SizedBox(width: 6),
                Text(
                  'ASSISTANT IA',
                  style: TextStyle(
                    color: _slate.withValues(alpha: 0.7),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            EskoliaCardContent(
              accentBorderColor: _violet,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Ce que tu veux generer',
                    style: TextStyle(
                      color: _slate.withValues(alpha: 0.8),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      FilterChip(
                        label: const Text('Cours'),
                        selected: _wantCours,
                        onSelected: _generating ? null : (v) => setState(() => _wantCours = v),
                        selectedColor: _violet.withValues(alpha: 0.2),
                        checkmarkColor: _violet,
                        labelStyle: TextStyle(
                          color: _wantCours ? _violet : _slate,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        side: BorderSide(
                          color: _wantCours ? _violet : _slate.withValues(alpha: 0.3),
                        ),
                        backgroundColor: Colors.transparent,
                        avatar: Icon(Icons.menu_book_rounded, size: 14,
                            color: _wantCours ? _violet : _slate),
                        showCheckmark: false,
                      ),
                      FilterChip(
                        label: const Text('Quiz'),
                        selected: _wantQuiz,
                        onSelected: _generating ? null : (v) => setState(() => _wantQuiz = v),
                        selectedColor: _green.withValues(alpha: 0.15),
                        checkmarkColor: _green,
                        labelStyle: TextStyle(
                          color: _wantQuiz ? _green : _slate,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        side: BorderSide(
                          color: _wantQuiz ? _green : _slate.withValues(alpha: 0.3),
                        ),
                        backgroundColor: Colors.transparent,
                        avatar: Icon(Icons.quiz_rounded, size: 14,
                            color: _wantQuiz ? _green : _slate),
                        showCheckmark: false,
                      ),
                      FilterChip(
                        label: const Text('Flashcards'),
                        selected: _wantFlashcards,
                        onSelected: _generating ? null : (v) => setState(() => _wantFlashcards = v),
                        selectedColor: _amber.withValues(alpha: 0.15),
                        checkmarkColor: _amber,
                        labelStyle: TextStyle(
                          color: _wantFlashcards ? _amber : _slate,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        side: BorderSide(
                          color: _wantFlashcards ? _amber : _slate.withValues(alpha: 0.3),
                        ),
                        backgroundColor: Colors.transparent,
                        avatar: Icon(Icons.style_rounded, size: 14,
                            color: _wantFlashcards ? _amber : _slate),
                        showCheckmark: false,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: _generating ? null : () => _generate(aiState),
                    style: FilledButton.styleFrom(
                      backgroundColor: _violet,
                      disabledBackgroundColor: _violet.withValues(alpha: 0.4),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    icon: _generating
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.auto_awesome_rounded, size: 18),
                    label: Text(_generating ? _generationPhase : 'Generer'),
                  ),
                ],
              ),
            ),
            if (_generating) ...[
              const SizedBox(height: 16),
              _buildProgressSection(),
            ],
            if (!_generating && _errorMessage != null) ...[
              const SizedBox(height: 16),
              _buildErrorCard(),
            ],
            if (!_generating && _results.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildResultsSection(),
            ],
            if (_flashcardJson != null) ...[
              const SizedBox(height: 10),
              _buildFlashcardDownloadRow(),
            ],
          ],
        );
      },
    );
  }

  Widget _buildFlashcardDownloadRow() {
    final json = _flashcardJson!;
    int count = 0;
    try {
      final data = jsonDecode(json) as Map<String, dynamic>;
      count = (data['questions'] as List?)?.length ?? 0;
    } catch (_) {}
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _amber.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _amber.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: _amber, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$count flashcards generees',
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          FilledButton.icon(
            onPressed: () => _fs.saveFile(
              EskoliaFolder.flashcards,
              'flashcards_${_safeName(widget.note?.title ?? 'notes')}.json',
              json,
              mimeType: 'application/json',
            ),
            style: FilledButton.styleFrom(
              backgroundColor: _amber,
              foregroundColor: Colors.black87,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            icon: const Icon(Icons.download_rounded, size: 16),
            label: const Text('Telecharger', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildNotConnectedBanner() {
    return EskoliaCardContent(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.psychology_outlined, color: _slate, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'IA non configuree',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Configure ta cle IA dans Reglages pour utiliser l\'assistant.',
                  style: TextStyle(
                    color: _slate.withValues(alpha: 0.8),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
                EskoliaButton(
                  label: 'Configurer l\'IA',
                  icon: Icons.settings_rounded,
                  variant: EskoliaButtonVariant.secondary,
                  onPressed: () => context.go('/settings'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    return EskoliaCardContent(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  color: _violet,
                  strokeWidth: 2,
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _generationPhase,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            color: _violet,
            backgroundColor: Colors.white.withValues(alpha: 0.08),
            minHeight: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard() {
    return EskoliaCardContent(
      accentBorderColor: _red,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: _red, size: 18),
              const SizedBox(width: 8),
              const Text(
                'Erreur de generation',
                style: TextStyle(
                  color: _red,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _errorMessage!,
            style: TextStyle(
              color: _slate.withValues(alpha: 0.85),
              fontSize: 12,
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          EskoliaButton(
            label: 'Reessayer',
            icon: Icons.refresh_rounded,
            variant: EskoliaButtonVariant.secondary,
            color: _red,
            textColor: _red,
            onPressed: _retryAction,
          ),
        ],
      ),
    );
  }

  Widget _buildResultsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 14,
              decoration: BoxDecoration(
                color: _violet,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.auto_awesome_rounded, color: _violet, size: 14),
            const SizedBox(width: 6),
            Text(
              'RESULTATS — ${_results.length} sujet${_results.length > 1 ? 's' : ''} detecte${_results.length > 1 ? 's' : ''}',
              style: TextStyle(
                color: _violet,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (final result in _results) ...[
          _buildSubjectCard(result),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _buildSubjectCard(_SubjectResult result) {
    final types = result.typeSummary;
    return EskoliaCardContent(
      accentBorderColor: _violet,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Text('\u{1F4DA}', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  result.subject,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          if (result.hasCourse) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: EskoliaButton(
                    label: 'Lire le cours',
                    icon: Icons.visibility_rounded,
                    variant: EskoliaButtonVariant.secondary,
                    expand: true,
                    color: _amber,
                    textColor: _amber,
                    onPressed: () => _openCourseSheet(result),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: EskoliaButton(
                    label: 'Telecharger .md',
                    icon: Icons.download_rounded,
                    variant: EskoliaButtonVariant.secondary,
                    expand: true,
                    onPressed: () => _downloadCourse(result),
                  ),
                ),
              ],
            ),
          ],

          if (result.hasQuiz) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Divider(
                    color: Colors.white.withValues(alpha: 0.10),
                    height: 1,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Quiz associe — ${result.questionCount} question${result.questionCount > 1 ? 's' : ''}',
                  style: TextStyle(
                    color: _slate.withValues(alpha: 0.6),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Divider(
                    color: Colors.white.withValues(alpha: 0.10),
                    height: 1,
                  ),
                ),
              ],
            ),
            if (types.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: types.map((t) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: t.$3.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      '${t.$1}x ${t.$2}',
                      style: TextStyle(
                        color: t.$3,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: EskoliaButton(
                    label: 'Faire le quiz',
                    icon: Icons.play_arrow_rounded,
                    variant: EskoliaButtonVariant.primary,
                    expand: true,
                    onPressed: () => _playQuiz(result),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: EskoliaButton(
                    label: 'Telecharger .json',
                    icon: Icons.download_rounded,
                    variant: EskoliaButtonVariant.secondary,
                    expand: true,
                    color: _green,
                    textColor: _green,
                    onPressed: () => _downloadQuiz(result),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ── Bottom sheet cours ─────────────────────────────────────────────────────────

class _CourseSheet extends StatelessWidget {
  const _CourseSheet({
    required this.result,
    required this.onPlayQuiz,
    required this.onDownloadQuiz,
    required this.onDownloadCourse,
  });

  final _SubjectResult result;
  final VoidCallback onPlayQuiz;
  final VoidCallback onDownloadQuiz;
  final VoidCallback onDownloadCourse;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.97,
      builder: (context, scrollCtrl) {
        return Container(
          decoration: const BoxDecoration(
            color: EskoliaVisual.bgElevated,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Drag handle
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Row(
                  children: [
                    const Text('\u{1F4DA}', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        result.subject,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: Colors.white.withValues(alpha: 0.5)),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints.tightFor(width: 32, height: 32),
                    ),
                  ],
                ),
              ),
              Divider(color: Colors.white.withValues(alpha: 0.08), height: 1),
              // Markdown content
              Expanded(
                child: Markdown(
                  controller: scrollCtrl,
                  data: result.course,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  styleSheet: MarkdownStyleSheet(
                    p: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.6),
                    h1: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                    h2: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                    h3: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                    code: TextStyle(
                      color: const Color(0xFF00BCD4),
                      backgroundColor: Colors.white.withValues(alpha: 0.06),
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                    codeblockDecoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    blockquote: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      height: 1.5,
                    ),
                    listBullet: const TextStyle(color: Color(0xFF6C63FF), fontSize: 13),
                    tableBody: const TextStyle(color: Colors.white70, fontSize: 12),
                    tableHead: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
                  ),
                ),
              ),
              // Actions
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                decoration: BoxDecoration(
                  color: EskoliaVisual.bgElevated,
                  border: Border(
                    top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    EskoliaButton(
                      label: 'Faire le quiz associe',
                      icon: Icons.sports_esports_rounded,
                      variant: EskoliaButtonVariant.primary,
                      expand: true,
                      onPressed: onPlayQuiz,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: EskoliaButton(
                            label: 'Telecharger cours .md',
                            icon: Icons.download_rounded,
                            variant: EskoliaButtonVariant.secondary,
                            expand: true,
                            color: _amber,
                            textColor: _amber,
                            onPressed: onDownloadCourse,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: EskoliaButton(
                            label: 'Telecharger quiz .json',
                            icon: Icons.download_rounded,
                            variant: EskoliaButtonVariant.secondary,
                            expand: true,
                            color: _green,
                            textColor: _green,
                            onPressed: onDownloadQuiz,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
