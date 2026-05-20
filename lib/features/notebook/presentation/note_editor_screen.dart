// ignore: avoid_web_libraries_in_flutter
import 'dart:convert';
import 'dart:html' as html show Blob, Url, AnchorElement;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/eskolia_visual.dart';
import '../../../core/utils/eskolia_snackbar.dart';
import '../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../shared/widgets/eskolia_app_bar.dart';
import '../../../shared/widgets/eskolia_button.dart';
import '../../../shared/widgets/eskolia_card.dart';
import '../../../shared/widgets/eskolia_text_field.dart';
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

// ── Data classes ───────────────────────────────────────────────────────────────

class _GeneratedCourse {
  const _GeneratedCourse({required this.subject, required this.content});
  final String subject;
  final String content;
}

class _GeneratedQuiz {
  const _GeneratedQuiz({required this.subject, required this.rawJson});
  final String subject;
  final String rawJson; // Full Eskolia-format {quiz: {}, questions: []}

  int get questionCount {
    try {
      final data = jsonDecode(rawJson) as Map<String, dynamic>;
      return ((data['questions'] as List<dynamic>?)?.length) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  List<(int, String, Color)> get typeSummary {
    const labels = <String, (String, Color)>{
      'classic':            ('Q&R', Color(0xFF6C63FF)),
      'ticket':             ('Ticket', Color(0xFF00BCD4)),
      'diagnostic_indices': ('Diagnostic', Color(0xFFFFC107)),
      'sequence':           ('Sequence', Color(0xFF4CAF50)),
    };
    try {
      final data = jsonDecode(rawJson) as Map<String, dynamic>;
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

  bool _generatingCourses = false;
  bool _generatingQuizzes = false;
  List<_GeneratedCourse> _courses = [];
  List<_GeneratedQuiz>   _quizzes = [];

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

  Future<void> _generateCourses(AiConnectionState aiState) async {
    if (_generatingCourses) return;
    final prompt = _buildNotesPrompt();
    if (prompt.isEmpty) {
      showEskoliaSnackBar(context, 'Ecris au moins une note avant de generer.');
      return;
    }
    setState(() {
      _generatingCourses = true;
      _courses = [];
    });
    try {
      final buffer = StringBuffer();
      await for (final token in _aiGenerator.streamMultiCourse(
        apiKey: aiState.apiKey!,
        provider: aiState.provider,
        allNotesContent: prompt,
      )) {
        if (!mounted) return;
        buffer.write(token);
      }
      if (!mounted) return;
      final raw  = NoteAiGenerator.extractJson(buffer.toString());
      final list = jsonDecode(raw) as List<dynamic>;
      setState(() {
        _courses = list.map((e) {
          final m = e as Map<String, dynamic>;
          return _GeneratedCourse(
            subject: (m['subject'] as String?)?.trim() ?? 'Sujet',
            content: (m['course']   as String?)?.trim() ?? '',
          );
        }).toList();
      });
    } catch (e) {
      if (mounted) showEskoliaSnackBar(context, 'Erreur lors de la generation : $e');
    } finally {
      if (mounted) setState(() => _generatingCourses = false);
    }
  }

  Future<void> _generateQuizzes(AiConnectionState aiState) async {
    if (_generatingQuizzes) return;
    final prompt = _buildNotesPrompt();
    if (prompt.isEmpty) {
      showEskoliaSnackBar(context, 'Ecris au moins une note avant de generer.');
      return;
    }
    setState(() {
      _generatingQuizzes = true;
      _quizzes = [];
    });
    try {
      final buffer = StringBuffer();
      await for (final token in _aiGenerator.streamMultiQuiz(
        apiKey: aiState.apiKey!,
        provider: aiState.provider,
        allNotesContent: prompt,
      )) {
        if (!mounted) return;
        buffer.write(token);
      }
      if (!mounted) return;
      final raw  = NoteAiGenerator.extractJson(buffer.toString());
      final list = jsonDecode(raw) as List<dynamic>;
      setState(() {
        _quizzes = list.map((e) {
          final m         = e as Map<String, dynamic>;
          final subject   = (m['subject']   as String?)?.trim() ?? 'Quiz';
          final questions = (m['questions'] as List<dynamic>?) ?? [];
          final eskoliaJson = jsonEncode({
            'quiz': {
              'title': subject,
              'description': 'Quiz genere par l\'IA Notebook',
              'author': 'IA Notebook',
            },
            'questions': questions,
          });
          return _GeneratedQuiz(subject: subject, rawJson: eskoliaJson);
        }).toList();
      });
    } catch (e) {
      if (mounted) showEskoliaSnackBar(context, 'Erreur lors de la generation : $e');
    } finally {
      if (mounted) setState(() => _generatingQuizzes = false);
    }
  }

  // ── Download ─────────────────────────────────────────────────────────────────

  void _downloadFile(String content, String filename, String mimeType) {
    final bytes = utf8.encode(content);
    final blob  = html.Blob([bytes], mimeType);
    final url   = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  void _downloadCourse(_GeneratedCourse item) {
    final safe = item.subject
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(' ', '_')
        .toLowerCase();
    _downloadFile(item.content, 'cours_$safe.md', 'text/markdown');
  }

  void _downloadQuiz(_GeneratedQuiz item) {
    final safe = item.subject
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(' ', '_')
        .toLowerCase();
    _downloadFile(item.rawJson, 'quiz_$safe.json', 'application/json');
  }

  // ── Quiz play / save ─────────────────────────────────────────────────────────

  Future<void> _playQuiz(_GeneratedQuiz item) async {
    try {
      final session = await QuizRepository().buildFromNotebookQuizJson(
        item.rawJson,
        item.subject,
      );
      if (mounted) context.push('/quiz/run', extra: session);
    } on FormatException catch (e) {
      if (mounted) showEskoliaSnackBar(context, e.message);
    } catch (_) {
      if (mounted) showEskoliaSnackBar(context, 'Erreur inattendue — regenere le quiz.');
    }
  }

  Future<void> _saveQuiz(_GeneratedQuiz item) async {
    try {
      await QuizRepository().buildFromNotebookQuizJson(item.rawJson, 'check');
    } on FormatException catch (e) {
      if (mounted) showEskoliaSnackBar(context, e.message);
      return;
    }
    await _savedQuizRepo.save(SavedNotebookQuiz.create(
      title: item.subject,
      rawJson: item.rawJson,
    ));
    if (mounted) showEskoliaSnackBar(context, 'Quiz sauvegarde dans Mes quiz IA.');
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            Row(
              children: [
                Expanded(
                  child: EskoliaButton(
                    label: 'Generer les cours',
                    icon: Icons.auto_stories_rounded,
                    variant: EskoliaButtonVariant.primary,
                    expand: true,
                    onPressed: _generatingCourses ? null : () => _generateCourses(aiState),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: EskoliaButton(
                    label: 'Generer les quiz',
                    icon: Icons.quiz_rounded,
                    variant: EskoliaButtonVariant.secondary,
                    expand: true,
                    onPressed: _generatingQuizzes ? null : () => _generateQuizzes(aiState),
                  ),
                ),
              ],
            ),
            if (_generatingCourses) ...[
              const SizedBox(height: 24),
              _buildGeneratingIndicator('COURS GENERES', _amber, Icons.auto_stories_rounded),
            ] else if (_courses.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildSectionLabel('COURS GENERES', _amber, Icons.auto_stories_rounded),
              const SizedBox(height: 10),
              for (final course in _courses) ...[
                _buildCourseCard(course),
                const SizedBox(height: 10),
              ],
            ],
            if (_generatingQuizzes) ...[
              const SizedBox(height: 24),
              _buildGeneratingIndicator('QUIZ GENERES', _green, Icons.quiz_rounded),
            ] else if (_quizzes.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildSectionLabel('QUIZ GENERES', _green, Icons.quiz_rounded),
              const SizedBox(height: 10),
              for (final quiz in _quizzes) ...[
                _buildQuizCard(quiz),
                const SizedBox(height: 10),
              ],
            ],
          ],
        );
      },
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

  Widget _buildSectionLabel(String label, Color color, IconData icon) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }

  Widget _buildGeneratingIndicator(String label, Color color, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionLabel(label, color, icon),
        const SizedBox(height: 10),
        LinearProgressIndicator(
          color: color,
          backgroundColor: Colors.white.withValues(alpha: 0.08),
          minHeight: 2,
        ),
        const SizedBox(height: 8),
        Text(
          'Generation en cours...',
          style: TextStyle(color: _slate.withValues(alpha: 0.6), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildCourseCard(_GeneratedCourse course) {
    return EskoliaCardContent(
      accentBorderColor: _amber,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('\u{1F4DA}', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  course.subject,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 200),
            child: SingleChildScrollView(
              child: SelectableText(
                course.content,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  height: 1.55,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          EskoliaButton(
            label: 'Telecharger .md',
            icon: Icons.download_rounded,
            variant: EskoliaButtonVariant.secondary,
            expand: true,
            color: _amber,
            textColor: _amber,
            onPressed: () => _downloadCourse(course),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizCard(_GeneratedQuiz quiz) {
    final types = quiz.typeSummary;
    return EskoliaCardContent(
      accentBorderColor: _green,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('\u{1F3AF}', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  quiz.subject,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _green.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${quiz.questionCount} question${quiz.questionCount > 1 ? 's' : ''}',
                  style: const TextStyle(
                    color: _green,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
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
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: EskoliaButton(
                  label: 'Jouer',
                  icon: Icons.play_arrow_rounded,
                  variant: EskoliaButtonVariant.primary,
                  expand: true,
                  onPressed: () => _playQuiz(quiz),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: EskoliaButton(
                  label: 'Sauvegarder',
                  icon: Icons.bookmark_add_rounded,
                  variant: EskoliaButtonVariant.secondary,
                  expand: true,
                  onPressed: () => _saveQuiz(quiz),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          EskoliaButton(
            label: 'Telecharger .json',
            icon: Icons.download_rounded,
            variant: EskoliaButtonVariant.secondary,
            expand: true,
            color: _green,
            textColor: _green,
            onPressed: () => _downloadQuiz(quiz),
          ),
        ],
      ),
    );
  }
}
