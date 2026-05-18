import 'package:cloud_firestore/cloud_firestore.dart';

class QuestionFeedback {
  const QuestionFeedback({
    required this.userId,
    required this.questionId,
    required this.vote,
    this.quizTitle,
    this.theme,
    required this.difficulty,
    required this.questionType,
    required this.source,
    this.timestamp,
  });

  final String userId;
  final String questionId;
  final int vote; // +1, -1, or 0 (annulé)
  final String? quizTitle;
  final String? theme;
  final String difficulty;
  final String questionType;
  final String source;
  final DateTime? timestamp;

  static QuestionFeedback fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return QuestionFeedback(
      userId: d['userId'] as String? ?? '',
      questionId: d['questionId'] as String? ?? '',
      vote: d['vote'] as int? ?? 0,
      quizTitle: d['quizTitle'] as String?,
      theme: d['theme'] as String?,
      difficulty: d['difficulty'] as String? ?? 'unknown',
      questionType: d['questionType'] as String? ?? 'classic',
      source: d['source'] as String? ?? '',
      timestamp: (d['timestamp'] as Timestamp?)?.toDate(),
    );
  }
}
