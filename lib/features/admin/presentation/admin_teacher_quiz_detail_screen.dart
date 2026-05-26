import 'package:flutter/material.dart';

import '../../../core/theme/eskolia_layout.dart';
import '../../../core/theme/eskolia_visual.dart';
import '../../../core/utils/eskolia_snackbar.dart';
import '../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../shared/widgets/eskolia_app_bar.dart';
import '../../../shared/widgets/eskolia_button.dart';
import '../../../shared/widgets/eskolia_card.dart';
import '../../../shared/widgets/eskolia_shell_body.dart';
import '../../../shared/widgets/eskolia_text_field.dart';
import '../data/models/teacher_quiz.dart';
import '../data/teacher_quiz_repository.dart';
import 'staff_gate_scaffold.dart';

const Color _bg = EskoliaVisual.bgDeep;
const Color _slate = Color(0xFF94A3B8);
const Color _violet = Color(0xFF6C63FF);
const Color _green = Color(0xFF43E97B);
const Color _red = Color(0xFFE53935);
const Color _orange = Color(0xFFFF9800);

class AdminTeacherQuizDetailScreen extends StatefulWidget {
  const AdminTeacherQuizDetailScreen({super.key, required this.quizId});
  final String quizId;

  @override
  State<AdminTeacherQuizDetailScreen> createState() =>
      _AdminTeacherQuizDetailScreenState();
}

class _AdminTeacherQuizDetailScreenState
    extends State<AdminTeacherQuizDetailScreen> {
  final _repo = TeacherQuizRepository();

  Future<void> _deleteQuestion(TeacherQuiz quiz, int index) async {
    final confirmed = await _confirmDialog(
      context,
      'Supprimer cette question ?',
      'Cette action est irréversible.',
    );
    if (!confirmed) return;
    final updated = List<TeacherQuizQuestion>.from(quiz.questions)
      ..removeAt(index);
    try {
      await _repo.updateQuestions(quiz.id, updated);
      if (mounted) showEskoliaSnackBar(context, 'Question supprimée.');
    } catch (_) {
      if (mounted) showEskoliaSnackBar(context, 'Erreur lors de la suppression.');
    }
  }

  Future<void> _addQuestion(TeacherQuiz quiz) async {
    final result = await showDialog<TeacherQuizQuestion>(
      context: context,
      builder: (_) => const _AddQuestionDialog(),
    );
    if (result == null) return;
    final updated = [...quiz.questions, result];
    try {
      await _repo.updateQuestions(quiz.id, updated);
      if (mounted) showEskoliaSnackBar(context, 'Question ajoutée.');
    } catch (_) {
      if (mounted) showEskoliaSnackBar(context, 'Erreur lors de l\'ajout.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return StaffGateScaffold(
            title: 'Détail quiz',
      child: StreamBuilder<List<TeacherQuiz>>(
        stream: _repo.watchAll(),
        builder: (context, snap) {
          final quiz = snap.data?.where((q) => q.id == widget.quizId).firstOrNull;

          return Scaffold(
            extendBodyBehindAppBar: true,
            backgroundColor: _bg,
            appBar: EskoliaAppBar.standard(
              context,
              title: quiz?.title ?? 'Quiz du prof',
            ),
            body: Stack(
              children: [
                const EskoliaAmbientBackground(),
                EskoliaShellBody(
                  safeAreaTop: false,
                  child: snap.connectionState == ConnectionState.waiting
                      ? const Center(child: CircularProgressIndicator())
                      : quiz == null
                          ? const Center(
                              child: Text('Quiz introuvable.',
                                  style: TextStyle(color: Colors.white54)))
                          : _buildContent(quiz),
                ),
              ],
            ),
            floatingActionButton: quiz == null
                ? null
                : FloatingActionButton.extended(
                    onPressed: () => _addQuestion(quiz),
                    backgroundColor: _violet,
                    icon: const Icon(Icons.add_rounded, color: Colors.white),
                    label: const Text('Ajouter une question',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildContent(TeacherQuiz quiz) {
    return ListView(
      padding: EdgeInsets.fromLTRB(
        EskoliaLayout.screenPaddingH,
        16,
        EskoliaLayout.screenPaddingH,
        EskoliaLayout.screenPaddingBottom + 80,
      ),
      children: [
        // Infos quiz
        EskoliaCardContent(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          quiz.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        if (quiz.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(quiz.description,
                              style: TextStyle(color: _slate, fontSize: 12)),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          'Par ${quiz.authorName} · ${quiz.questions.length} question${quiz.questions.length > 1 ? "s" : ""}',
                          style: TextStyle(color: _slate, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Switch(
                        value: quiz.isPublished,
                        onChanged: (v) => _repo.togglePublished(quiz.id, v),
                        activeColor: _green,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        quiz.isPublished ? 'Publié' : 'Brouillon',
                        style: TextStyle(
                          color: quiz.isPublished ? _green : _slate,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Questions (${quiz.questions.length})',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 10),
        if (quiz.questions.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'Aucune question — appuyez sur "Ajouter" pour commencer.',
                textAlign: TextAlign.center,
                style: TextStyle(color: _slate, fontSize: 13),
              ),
            ),
          )
        else
          ...quiz.questions.asMap().entries.map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _QuestionTile(
                    question: e.value,
                    index: e.key,
                    onDelete: () => _deleteQuestion(quiz, e.key),
                  ),
                ),
              ),
      ],
    );
  }
}

class _QuestionTile extends StatelessWidget {
  const _QuestionTile({
    required this.question,
    required this.index,
    required this.onDelete,
  });

  final TeacherQuizQuestion question;
  final int index;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return EskoliaCardContent(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _violet.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                color: _violet,
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question.question,
                  style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.35),
                ),
                const SizedBox(height: 4),
                Text(
                  question.answer,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: _green.withValues(alpha: 0.8), fontSize: 11),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  children: [
                    _chip(question.difficulty, _slate),
                    _chip(question.type, _slate),
                    if (question.contextLine != null)
                      _chip(question.contextLine!, _slate),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            color: _red.withValues(alpha: 0.7),
            tooltip: 'Supprimer',
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(label, style: TextStyle(color: color, fontSize: 10)),
      );
}

// — Dialog ajout de question —

class _AddQuestionDialog extends StatefulWidget {
  const _AddQuestionDialog();

  @override
  State<_AddQuestionDialog> createState() => _AddQuestionDialogState();
}

class _AddQuestionDialogState extends State<_AddQuestionDialog> {
  final _questionCtrl = TextEditingController();
  final _answerCtrl = TextEditingController();
  final _hintCtrl = TextEditingController();
  final _contextCtrl = TextEditingController();
  String _difficulty = 'moyen';
  String _type = 'classic';

  @override
  void dispose() {
    _questionCtrl.dispose();
    _answerCtrl.dispose();
    _hintCtrl.dispose();
    _contextCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final q = _questionCtrl.text.trim();
    final a = _answerCtrl.text.trim();
    if (q.isEmpty || a.isEmpty) {
      showEskoliaSnackBar(context, 'La question et la réponse sont obligatoires.');
      return;
    }
    Navigator.of(context).pop(TeacherQuizQuestion(
      question: q,
      answer: a,
      difficulty: _difficulty,
      hint: _hintCtrl.text.trim(),
      type: _type,
      contextLine: _contextCtrl.text.trim().isEmpty ? null : _contextCtrl.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1A1A2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Ajouter une question',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
            ),
            const SizedBox(height: 16),
            EskoliaTextField(
              controller: _questionCtrl,
              hintText: 'Question...',
              minLines: 3,
              maxLines: 6,
            ),
            const SizedBox(height: 10),
            EskoliaTextField(
              controller: _answerCtrl,
              hintText: 'Réponse attendue...',
              minLines: 2,
              maxLines: 5,
            ),
            const SizedBox(height: 10),
            EskoliaTextField(
              controller: _hintCtrl,
              hintText: 'Explication / indice (optionnel)...',
            ),
            const SizedBox(height: 10),
            EskoliaTextField(
              controller: _contextCtrl,
              hintText: 'Contexte, ex: Réseau — OSI (optionnel)',
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _SegmentRow<String>(
                    label: 'Difficulté',
                    value: _difficulty,
                    options: const ['facile', 'moyen', 'difficile'],
                    labels: const ['Facile', 'Moyen', 'Difficile'],
                    onChanged: (v) => setState(() => _difficulty = v),
                    activeColor: _orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _SegmentRow<String>(
              label: 'Type',
              value: _type,
              options: const ['classic', 'ticket', 'diagnostic_indices'],
              labels: const ['Classique', 'Ticket', 'Indices'],
              onChanged: (v) => setState(() => _type = v),
              activeColor: _violet,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: EskoliaButton(
                    label: 'Annuler',
                    variant: EskoliaButtonVariant.ghost,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: EskoliaButton(
                    label: 'Ajouter',
                    icon: Icons.add_rounded,
                    variant: EskoliaButtonVariant.primary,
                    onPressed: _submit,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SegmentRow<T> extends StatelessWidget {
  const _SegmentRow({
    required this.label,
    required this.value,
    required this.options,
    required this.labels,
    required this.onChanged,
    required this.activeColor,
  });

  final String label;
  final T value;
  final List<T> options;
  final List<String> labels;
  final ValueChanged<T> onChanged;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: _slate, fontSize: 11)),
        const SizedBox(height: 6),
        Row(
          children: List.generate(options.length, (i) {
            final active = value == options[i];
            return Padding(
              padding: EdgeInsets.only(right: i < options.length - 1 ? 6 : 0),
              child: GestureDetector(
                onTap: () => onChanged(options[i]),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: active
                        ? activeColor.withValues(alpha: 0.15)
                        : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: active
                          ? activeColor.withValues(alpha: 0.6)
                          : Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Text(
                    labels[i],
                    style: TextStyle(
                      color: active ? activeColor : _slate,
                      fontSize: 11,
                      fontWeight: active ? FontWeight.w700 : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

Future<bool> _confirmDialog(
    BuildContext context, String title, String body) async {
  return await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          title: Text(title,
              style: const TextStyle(color: Colors.white, fontSize: 16)),
          content: Text(body, style: TextStyle(color: _slate)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler', style: TextStyle(color: Colors.white54)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Confirmer',
                  style: TextStyle(color: _red, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ) ??
      false;
}
