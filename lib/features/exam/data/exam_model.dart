import '../../quiz/models/quiz_models.dart';

class ExamQuizItem {
  const ExamQuizItem({
    required this.id,
    required this.title,
    required this.description,
    required this.author,
    required this.category,
    required this.assetPath,
    required this.questions,
    this.bestScore,
    this.isCompleted = false,
  });

  final String id;
  final String title;
  final String description;
  final String author;
  final String category;
  final String assetPath;
  final List<QuizQuestion> questions;
  final double? bestScore;
  final bool isCompleted;

  int get questionCount => questions.length;

  ExamQuizItem copyWith({
    double? bestScore,
    bool? isCompleted,
  }) {
    return ExamQuizItem(
      id: id,
      title: title,
      description: description,
      author: author,
      category: category,
      assetPath: assetPath,
      questions: questions,
      bestScore: bestScore ?? this.bestScore,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
