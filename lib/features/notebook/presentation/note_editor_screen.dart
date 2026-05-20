// ignore: avoid_web_libraries_in_flutter
import 'dart:convert';
import 'dart:html' as html show Blob, Url, AnchorElement;
import 'dart:math' show min;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/eskolia_snackbar.dart';
import '../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../shared/widgets/eskolia_app_bar.dart';
import '../../../shared/widgets/eskolia_button.dart';
import '../../ai/data/ai_key_repository.dart';
import '../../quiz/services/quiz_repository.dart';
import '../data/note_ai_generator.dart';
import '../data/note_model.dart';
import '../data/notebook_repository.dart';
import '../data/saved_quiz_repository.dart';

const Color _bg = Color(0xFF0B1120);
const Color _violet = Color(0xFF6C63FF);
const Color _slate = Color(0xFF94A3B8);
const Color _green = Color(0xFF4CAF50);
const Color _amber = Color(0xFFFFC107);

class NoteEditorScreen extends StatefulWidget {
  const NoteEditorScreen({super.key, this.note});

  /// Null = nouvelle note.
  final NoteModel? note;

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final _repo = NotebookRepository();
  final _savedQuizRepo = SavedQuizRepository();
  final _aiKeyRepo = AiKeyRepository();
  final _aiGenerator = NoteAiGenerator();

  late final TextEditingController _titleCtrl;
  late final TextEditingController _contentCtrl;

  String? _noteId;
  bool _generatingCourse = false;
  bool _generatingQuiz = false;
  String _generatedCourse = '';
  String _generatedQuiz = '';
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    _noteId = widget.note?.id;
    _titleCtrl = TextEditingController(text: widget.note?.title ?? '');
    _contentCtrl = TextEditingController(text: widget.note?.content ?? '');
    _titleCtrl.addListener(_markDirty);
    _contentCtrl.addListener(_markDirty);
  }

  void _markDirty() {
    if (!_dirty) setState(() => _dirty = true);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  // ── Sauvegarde ─────────────────────────────────────────────────────────────

  Future<void> _save() async {
    final title = _titleCtrl.text;
    final content = _contentCtrl.text;

    NoteModel note;
    if (_noteId == null) {
      note = NoteModel.create(title: title, content: content);
      _noteId = note.id;
    } else {
      note = (widget.note ?? NoteModel.create(title: title, content: content))
          .copyWith(title: title, content: content);
      // Si la note venait de widget.note, on s'assure d'utiliser le bon id.
      note = NoteModel(
        id: _noteId!,
        title: title,
        content: content,
        createdAt: widget.note?.createdAt ?? note.createdAt,
        updatedAt: DateTime.now(),
      );
    }

    await _repo.save(note);
    if (mounted) {
      setState(() => _dirty = false);
      showEskoliaSnackBar(context, 'Note sauvegardee.');
    }
  }

  // ── Suppression ────────────────────────────────────────────────────────────

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Supprimer la note ?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'Cette action est irreversible.',
          style: TextStyle(color: Color(0xFF94A3B8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler', style: TextStyle(color: Color(0xFF94A3B8))),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Supprimer', style: TextStyle(color: Color(0xFFEF4444))),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    if (_noteId != null) await _repo.delete(_noteId!);
    if (mounted) context.pop();
  }

  // ── Generation IA ──────────────────────────────────────────────────────────

  Future<void> _generateCourse(AiConnectionState aiState) async {
    if (_generatingCourse) return;
    final content = _contentCtrl.text.trim();
    if (content.isEmpty) {
      showEskoliaSnackBar(context, 'Ecris du contenu dans ta note avant de generer un cours.');
      return;
    }
    setState(() {
      _generatingCourse = true;
      _generatedCourse = '';
    });
    try {
      final stream = _aiGenerator.streamMiniCourse(
        apiKey: aiState.apiKey!,
        provider: aiState.provider,
        noteContent: content,
        noteTitle: _titleCtrl.text.trim().isEmpty ? 'Sans titre' : _titleCtrl.text.trim(),
      );
      await for (final token in stream) {
        if (!mounted) return;
        setState(() => _generatedCourse += token);
      }
      if (mounted) {
        setState(() {
          _generatedCourse = NoteAiGenerator.extractMarkdown(_generatedCourse);
        });
      }
    } catch (e) {
      if (mounted) showEskoliaSnackBar(context, 'Erreur lors de la generation : $e');
    } finally {
      if (mounted) setState(() => _generatingCourse = false);
    }
  }

  Future<void> _generateQuiz(AiConnectionState aiState) async {
    if (_generatingQuiz) return;
    final content = _contentCtrl.text.trim();
    if (content.isEmpty) {
      showEskoliaSnackBar(context, 'Ecris du contenu dans ta note avant de generer un quiz.');
      return;
    }
    setState(() {
      _generatingQuiz = true;
      _generatedQuiz = '';
    });
    try {
      final stream = _aiGenerator.streamQuiz(
        apiKey: aiState.apiKey!,
        provider: aiState.provider,
        noteContent: content,
        noteTitle: _titleCtrl.text.trim().isEmpty ? 'Sans titre' : _titleCtrl.text.trim(),
      );
      await for (final token in stream) {
        if (!mounted) return;
        setState(() => _generatedQuiz += token);
      }
      if (mounted) {
        setState(() {
          _generatedQuiz = NoteAiGenerator.extractJson(_generatedQuiz);
        });
      }
    } catch (e) {
      if (mounted) showEskoliaSnackBar(context, 'Erreur lors de la generation : $e');
    } finally {
      if (mounted) setState(() => _generatingQuiz = false);
    }
  }

  // ── Telechargement ─────────────────────────────────────────────────────────

  void _downloadFile(String content, String filename, String mimeType) {
    final bytes = utf8.encode(content);
    final blob = html.Blob([bytes], mimeType);
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  void _downloadCourse() {
    if (_generatedCourse.isEmpty) return;
    final title = _titleCtrl.text.trim().isEmpty ? 'note' : _titleCtrl.text.trim();
    final safeTitle = title.replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(' ', '_');
    _downloadFile(_generatedCourse, 'mini_cours_$safeTitle.md', 'text/markdown');
  }

  void _downloadQuiz() {
    if (_generatedQuiz.isEmpty) return;
    final title = _titleCtrl.text.trim().isEmpty ? 'note' : _titleCtrl.text.trim();
    final safeTitle = title.replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(' ', '_');
    _downloadFile(_generatedQuiz, 'quiz_$safeTitle.json', 'application/json');
  }

  // ── Sauvegarder le quiz ────────────────────────────────────────────────────

  Future<void> _saveQuiz() async {
    if (_generatedQuiz.isEmpty) return;
    try {
      // Validation avant sauvegarde
      await QuizRepository().buildFromNotebookQuizJson(_generatedQuiz, 'check');
    } on FormatException catch (e) {
      if (mounted) showEskoliaSnackBar(context, e.message);
      return;
    }
    final title = _titleCtrl.text.trim().isEmpty ? 'Quiz IA' : _titleCtrl.text.trim();
    final quiz = SavedNotebookQuiz.create(
      title: title,
      rawJson: _generatedQuiz,
      noteTitle: _titleCtrl.text.trim().isEmpty ? null : _titleCtrl.text.trim(),
    );
    await _savedQuizRepo.save(quiz);
    if (mounted) showEskoliaSnackBar(context, 'Quiz sauvegarde dans Mes quiz IA.');
  }

  // ── Jouer le quiz ──────────────────────────────────────────────────────────

  Future<void> _playQuiz() async {
    if (_generatedQuiz.isEmpty) return;
    final title = _titleCtrl.text.trim().isEmpty ? 'Quiz Notebook' : _titleCtrl.text.trim();
    try {
      final session = await QuizRepository().buildFromNotebookQuizJson(
        _generatedQuiz,
        title,
      );
      if (mounted) context.push('/quiz/run', extra: session);
    } on FormatException catch (e) {
      if (mounted) showEskoliaSnackBar(context, e.message);
    } catch (e) {
      if (mounted) showEskoliaSnackBar(context, 'Erreur inattendue — regenere le quiz.');
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isNew = _noteId == null;
    return Scaffold(
      backgroundColor: _bg,
      appBar: EskoliaAppBar.standard(
        context,
        title: isNew ? 'Nouvelle note' : (_titleCtrl.text.trim().isEmpty ? 'Note' : _titleCtrl.text.trim()),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_rounded, color: _violet),
            tooltip: 'Sauvegarder',
            onPressed: _save,
          ),
          if (!isNew)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444)),
              tooltip: 'Supprimer',
              onPressed: _delete,
            ),
          const SizedBox(width: 4),
        ],
      ),
      body: Stack(
        children: [
          const EskoliaAmbientBackground(),
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
            children: [
              // Titre
              TextField(
                controller: _titleCtrl,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
                decoration: const InputDecoration(
                  hintText: 'Titre de la note...',
                  hintStyle: TextStyle(
                    color: Color(0xFF4A5568),
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
              const Divider(color: Color(0xFF1E293B), height: 1),
              const SizedBox(height: 8),
              // Contenu
              TextField(
                controller: _contentCtrl,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  height: 1.6,
                ),
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  hintText: 'Ecris tes notes ici...',
                  hintStyle: TextStyle(
                    color: Color(0xFF4A5568),
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 32),
              // Section IA
              _AiSection(
                aiKeyRepo: _aiKeyRepo,
                onGenerateCourse: _generateCourse,
                onGenerateQuiz: _generateQuiz,
                generatingCourse: _generatingCourse,
                generatingQuiz: _generatingQuiz,
                generatedCourse: _generatedCourse,
                generatedQuiz: _generatedQuiz,
                onDownloadCourse: _downloadCourse,
                onDownloadQuiz: _downloadQuiz,
                onPlayQuiz: _playQuiz,
                onSaveQuiz: _saveQuiz,
              ),
              const SizedBox(height: 120),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Section IA ─────────────────────────────────────────────────────────────

class _AiSection extends StatelessWidget {
  const _AiSection({
    required this.aiKeyRepo,
    required this.onGenerateCourse,
    required this.onGenerateQuiz,
    required this.generatingCourse,
    required this.generatingQuiz,
    required this.generatedCourse,
    required this.generatedQuiz,
    required this.onDownloadCourse,
    required this.onDownloadQuiz,
    required this.onPlayQuiz,
    required this.onSaveQuiz,
  });

  final AiKeyRepository aiKeyRepo;
  final void Function(AiConnectionState) onGenerateCourse;
  final void Function(AiConnectionState) onGenerateQuiz;
  final bool generatingCourse;
  final bool generatingQuiz;
  final String generatedCourse;
  final String generatedQuiz;
  final VoidCallback onDownloadCourse;
  final VoidCallback onDownloadQuiz;
  final VoidCallback onPlayQuiz;
  final VoidCallback onSaveQuiz;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AiConnectionState>(
      stream: aiKeyRepo.watch(),
      builder: (context, snap) {
        final aiState = snap.data ?? const AiConnectionState(isConnected: false);

        if (!aiState.isConnected) {
          return _NotConnectedCard();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Label section IA
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
            // Bouton mini-cours
            EskoliaButton(
              label: 'Generer un mini-cours',
              icon: Icons.auto_stories_rounded,
              variant: EskoliaButtonVariant.secondary,
              expand: true,
              onPressed: generatingCourse ? null : () => onGenerateCourse(aiState),
            ),
            const SizedBox(height: 10),
            // Bouton quiz
            EskoliaButton(
              label: 'Generer un quiz',
              icon: Icons.quiz_rounded,
              variant: EskoliaButtonVariant.secondary,
              expand: true,
              onPressed: generatingQuiz ? null : () => onGenerateQuiz(aiState),
            ),
            // Mini-cours genere
            if (generatingCourse || generatedCourse.isNotEmpty) ...[
              const SizedBox(height: 24),
              _GeneratedCourseSection(
                generating: generatingCourse,
                content: generatedCourse,
                onDownload: onDownloadCourse,
              ),
            ],
            // Quiz genere
            if (generatingQuiz || generatedQuiz.isNotEmpty) ...[
              const SizedBox(height: 24),
              _GeneratedQuizSection(
                generating: generatingQuiz,
                content: generatedQuiz,
                onDownload: onDownloadQuiz,
                onPlay: onPlayQuiz,
                onSave: onSaveQuiz,
              ),
            ],
          ],
        );
      },
    );
  }
}

// ── Not connected card ─────────────────────────────────────────────────────

class _NotConnectedCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          const Icon(Icons.psychology_outlined, color: _slate, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Connecte ton IA dans Profil > Mon IA pour generer des ressources',
              style: TextStyle(
                color: _slate.withValues(alpha: 0.8),
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Mini-cours genere ──────────────────────────────────────────────────────

class _GeneratedCourseSection extends StatelessWidget {
  const _GeneratedCourseSection({
    required this.generating,
    required this.content,
    required this.onDownload,
  });

  final bool generating;
  final String content;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Icon(Icons.auto_stories_rounded, color: _amber, size: 14),
            const SizedBox(width: 6),
            Text(
              'MINI-COURS GENERE',
              style: TextStyle(
                color: _slate.withValues(alpha: 0.7),
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (generating) ...[
          const LinearProgressIndicator(
            color: _violet,
            backgroundColor: Color(0xFF1E293B),
            minHeight: 2,
          ),
          const SizedBox(height: 8),
          Text(
            'Generation en cours...',
            style: TextStyle(
              color: _slate.withValues(alpha: 0.6),
              fontSize: 12,
            ),
          ),
          if (content.isNotEmpty) ...[
            const SizedBox(height: 8),
            _CourseTextArea(content: content),
          ],
        ] else ...[
          _CourseTextArea(content: content),
          const SizedBox(height: 10),
          EskoliaButton(
            label: 'Telecharger .md',
            icon: Icons.download_rounded,
            variant: EskoliaButtonVariant.secondary,
            expand: true,
            color: _amber,
            textColor: _amber,
            onPressed: onDownload,
          ),
        ],
      ],
    );
  }
}

class _CourseTextArea extends StatelessWidget {
  const _CourseTextArea({required this.content});

  final String content;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 320),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: SingleChildScrollView(
        child: SelectableText(
          content,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            height: 1.55,
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }
}

// ── Quiz genere ────────────────────────────────────────────────────────────

class _GeneratedQuizSection extends StatelessWidget {
  const _GeneratedQuizSection({
    required this.generating,
    required this.content,
    required this.onDownload,
    required this.onPlay,
    required this.onSave,
  });

  final bool generating;
  final String content;
  final VoidCallback onDownload;
  final VoidCallback onPlay;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Icon(Icons.quiz_rounded, color: _green, size: 14),
            const SizedBox(width: 6),
            Text(
              'QUIZ GENERE',
              style: TextStyle(
                color: _slate.withValues(alpha: 0.7),
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (generating) ...[
          const LinearProgressIndicator(
            color: _violet,
            backgroundColor: Color(0xFF1E293B),
            minHeight: 2,
          ),
          const SizedBox(height: 8),
          Text(
            'Generation en cours...',
            style: TextStyle(
              color: _slate.withValues(alpha: 0.6),
              fontSize: 12,
            ),
          ),
          if (content.isNotEmpty) ...[
            const SizedBox(height: 8),
            _QuizPreview(content: content),
          ],
        ] else ...[
          _QuizPreview(content: content),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: EskoliaButton(
                  label: 'Telecharger .json',
                  icon: Icons.download_rounded,
                  variant: EskoliaButtonVariant.secondary,
                  expand: true,
                  color: _green,
                  textColor: _green,
                  onPressed: onDownload,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: EskoliaButton(
                  label: 'Jouer ce quiz',
                  icon: Icons.play_arrow_rounded,
                  variant: EskoliaButtonVariant.primary,
                  expand: true,
                  onPressed: onPlay,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          EskoliaButton(
            label: 'Sauvegarder dans Mes quiz IA',
            icon: Icons.bookmark_add_rounded,
            variant: EskoliaButtonVariant.secondary,
            expand: true,
            onPressed: onSave,
          ),
        ],
      ],
    );
  }
}

class _QuizPreview extends StatelessWidget {
  const _QuizPreview({required this.content});

  final String content;

  static const _typeLabels = {
    'classic':           ('Q&R', Color(0xFF6C63FF)),
    'ticket':            ('Ticket', Color(0xFF00BCD4)),
    'diagnostic_indices':('Diagnostic', Color(0xFFFFC107)),
    'sequence':          ('Sequence', Color(0xFF4CAF50)),
  };

  @override
  Widget build(BuildContext context) {
    // Tente de parser pour afficher une preview structuree.
    try {
      final data = jsonDecode(content) as Map<String, dynamic>;
      final quizMeta  = data['quiz']      as Map<String, dynamic>? ?? {};
      final questions = data['questions'] as List<dynamic>?         ?? [];
      final title     = (quizMeta['title'] as String?)?.trim() ?? 'Quiz';
      final desc      = (quizMeta['description'] as String?)?.trim() ?? '';

      // Compte les types
      final typeCounts = <String, int>{};
      for (final q in questions) {
        if (q is! Map) continue;
        final t = (q['type'] as String?)?.trim() ?? 'classic';
        typeCounts[t] = (typeCounts[t] ?? 0) + 1;
      }

      // Premiere question
      final firstQ = questions.isNotEmpty && questions.first is Map
          ? (questions.first as Map)['question'] as String? ?? ''
          : '';

      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _green.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _green.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre + badge nb questions
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
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
                    '${questions.length} question${questions.length > 1 ? 's' : ''}',
                    style: const TextStyle(
                      color: _green,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            if (desc.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(desc, style: TextStyle(color: _slate.withValues(alpha: 0.7), fontSize: 12)),
            ],
            if (typeCounts.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: typeCounts.entries.map((e) {
                  final info = _typeLabels[e.key] ?? ('Autre', _slate);
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: info.$2.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      '${e.value}x ${info.$1}',
                      style: TextStyle(
                        color: info.$2,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
            if (firstQ.isNotEmpty) ...[
              const SizedBox(height: 10),
              const Divider(color: Colors.white10, height: 1),
              const SizedBox(height: 8),
              Text(
                'Ex : ${firstQ.substring(0, min(firstQ.length, 120))}${firstQ.length > 120 ? '...' : ''}',
                style: TextStyle(
                  color: _slate.withValues(alpha: 0.8),
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      );
    } catch (_) {
      // JSON encore en cours de stream — affiche le debut brut
      final preview = content.length > 200
          ? '${content.substring(0, 200)}...'
          : content;
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: SelectableText(
          preview,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            height: 1.55,
            fontFamily: 'monospace',
          ),
        ),
      );
    }
  }
}
