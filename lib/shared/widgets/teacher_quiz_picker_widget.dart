import 'package:flutter/material.dart';

import '../../core/constants/eskolia_tokens.dart';
import '../../features/admin/data/models/teacher_quiz.dart';
import '../../features/admin/data/teacher_quiz_repository.dart';

const Color _slate = EskoliaTokens.textSecondary;
const Color _violet = EskoliaTokens.violet;
const Color _cyan = EskoliaTokens.cyan;

/// Sélecteur de quiz du prof (teacher_quizzes publiés depuis Firestore).
/// Retourne un chemin sentinel 'teacher://{quizId}' via [onSelected].
class TeacherQuizPickerWidget extends StatelessWidget {
  const TeacherQuizPickerWidget({
    super.key,
    required this.selectedPath,
    required this.onSelected,
  });

  final String? selectedPath;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<TeacherQuiz>>(
      stream: TeacherQuizRepository().watchPublished(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
            child: SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2, color: _cyan),
            ),
          );
        }
        final quizzes = snap.data ?? [];
        if (quizzes.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'Aucun quiz du prof publié pour l\'instant.\nDemandez à un admin d\'en publier un.',
                textAlign: TextAlign.center,
                style: TextStyle(color: _slate, fontSize: 12, height: 1.4),
              ),
            ),
          );
        }
        return ListView.builder(
          itemCount: quizzes.length,
          itemBuilder: (_, i) {
            final quiz = quizzes[i];
            final path = 'teacher://${quiz.id}';
            final selected = selectedPath == path;
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: _TeacherQuizCard(
                quiz: quiz,
                selected: selected,
                onTap: () => onSelected(path),
              ),
            );
          },
        );
      },
    );
  }
}

class _TeacherQuizCard extends StatelessWidget {
  const _TeacherQuizCard({
    required this.quiz,
    required this.selected,
    required this.onTap,
  });

  final TeacherQuiz quiz;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      decoration: BoxDecoration(
        color: selected
            ? _violet.withValues(alpha: 0.15)
            : Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected
              ? _violet.withValues(alpha: 0.7)
              : Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: selected ? _violet : _slate,
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quiz.title,
                      style: TextStyle(
                        color: selected ? Colors.white : Colors.white.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    if (quiz.description.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        quiz.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: _slate, fontSize: 11),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${quiz.questions.length}Q',
                style: TextStyle(
                  color: _slate,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
