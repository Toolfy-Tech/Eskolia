import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/eskolia_layout.dart';
import '../../../core/theme/eskolia_visual.dart';
import '../../../core/utils/eskolia_snackbar.dart';
import '../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../shared/widgets/eskolia_app_bar.dart';
import '../../../shared/widgets/eskolia_card.dart';
import '../../../shared/widgets/eskolia_shell_body.dart';
import '../../lobby/data/models/custom_quiz_data.dart';
import '../data/models/teacher_quiz.dart';
import '../data/teacher_quiz_repository.dart';
import 'staff_gate_scaffold.dart';

const Color _bg = EskoliaVisual.bgDeep;
const Color _slate = Color(0xFF94A3B8);
const Color _violet = Color(0xFF6C63FF);
const Color _green = Color(0xFF43E97B);

class AdminTeacherQuizzesScreen extends StatefulWidget {
  const AdminTeacherQuizzesScreen({super.key});

  @override
  State<AdminTeacherQuizzesScreen> createState() =>
      _AdminTeacherQuizzesScreenState();
}

class _AdminTeacherQuizzesScreenState
    extends State<AdminTeacherQuizzesScreen> {
  final _repo = TeacherQuizRepository();
  bool _importing = false;

  Future<void> _importJson() async {
    if (_importing) return;
    setState(() => _importing = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;
      final bytes = result.files.first.bytes;
      if (bytes == null) {
        if (mounted) showEskoliaSnackBar(context, 'Impossible de lire le fichier.');
        return;
      }

      final jsonStr = utf8.decode(bytes);
      final data = CustomQuizData.fromJsonString(jsonStr);

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await _repo.create(
        authorId: user.uid,
        authorName: user.displayName ?? user.email ?? 'Admin',
        title: data.title,
        description: data.description,
        questions: data.questions
            .map((q) => TeacherQuizQuestion(
                  question: q.question,
                  answer: q.answer,
                  difficulty: q.difficulty,
                  hint: q.hint,
                  type: q.type,
                  contextLine: q.contextLine,
                  indices: q.indices,
                  items: q.items,
                ))
            .toList(),
      );

      if (mounted) {
        showEskoliaSnackBar(
            context, '"${data.title}" importé — ${data.questions.length} questions.');
      }
    } on FormatException catch (e) {
      if (mounted) showEskoliaSnackBar(context, 'Format invalide : ${e.message}');
    } catch (e) {
      if (mounted) showEskoliaSnackBar(context, 'Erreur lors de l\'import.');
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StaffGateScaffold(
      title: 'Quiz du prof',
      child: Scaffold(
        backgroundColor: _bg,
        appBar: EskoliaAppBar.standard(context, title: 'Quiz du prof'),
        body: Stack(
          children: [
            const EskoliaAmbientBackground(),
            EskoliaShellBody(
              safeAreaTop: false,
              child: StreamBuilder<List<TeacherQuiz>>(
                stream: _repo.watchAll(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final quizzes = snap.data ?? [];
                  if (quizzes.isEmpty) {
                    return _empty();
                  }
                  return ListView.builder(
                    padding: EdgeInsets.fromLTRB(
                      EskoliaLayout.screenPaddingH,
                      16,
                      EskoliaLayout.screenPaddingH,
                      EskoliaLayout.screenPaddingBottom + 80,
                    ),
                    itemCount: quizzes.length,
                    itemBuilder: (_, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _QuizCard(
                        quiz: quizzes[i],
                        onTap: () => context.push(
                          '/admin/teacher-quizzes/${quizzes[i].id}',
                        ),
                        onTogglePublish: (val) =>
                            _repo.togglePublished(quizzes[i].id, val),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _importing ? null : _importJson,
          backgroundColor: _violet,
          icon: _importing
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.upload_file_rounded, color: Colors.white),
          label: const Text('Importer JSON',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  Widget _empty() => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('📚', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              const Text(
                'Aucun quiz du prof pour l\'instant.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Importez un fichier .json (format template Eskolia)\npour créer votre premier quiz.',
                textAlign: TextAlign.center,
                style: TextStyle(color: _slate, fontSize: 13, height: 1.4),
              ),
            ],
          ),
        ),
      );
}

class _QuizCard extends StatelessWidget {
  const _QuizCard({
    required this.quiz,
    required this.onTap,
    required this.onTogglePublish,
  });

  final TeacherQuiz quiz;
  final VoidCallback onTap;
  final ValueChanged<bool> onTogglePublish;

  @override
  Widget build(BuildContext context) {
    return EskoliaCardContent(
      padding: const EdgeInsets.all(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quiz.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  if (quiz.description.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      quiz.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: _slate, fontSize: 12),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    '${quiz.questions.length} question${quiz.questions.length > 1 ? 's' : ''} · par ${quiz.authorName}',
                    style: TextStyle(color: _slate, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Switch(
                  value: quiz.isPublished,
                  onChanged: onTogglePublish,
                  activeColor: _green,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                Text(
                  quiz.isPublished ? 'Publié' : 'Brouillon',
                  style: TextStyle(
                    color: quiz.isPublished ? _green : _slate,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: Colors.white38, size: 20),
          ],
        ),
      ),
    );
  }
}
