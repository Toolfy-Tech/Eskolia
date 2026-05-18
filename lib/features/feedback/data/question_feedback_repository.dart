import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/question_feedback.dart';

class QuestionFeedbackRepository {
  final _db = FirebaseFirestore.instance;

  String _docId(String userId, String questionId) {
    final safe = questionId
        .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')
        .substring(0, questionId.length.clamp(0, 80));
    return '${userId}__$safe';
  }

  Future<int?> getMyVote(String userId, String questionId) async {
    try {
      final doc = await _db
          .collection('question_feedback')
          .doc(_docId(userId, questionId))
          .get();
      if (!doc.exists) return null;
      final v = doc.data()?['vote'] as int?;
      return (v == null || v == 0) ? null : v;
    } catch (_) {
      return null;
    }
  }

  Future<void> vote({
    required String userId,
    required String questionId,
    required int vote, // +1, -1, or 0 (annulé)
    String? quizTitle,
    String? theme,
    required String difficulty,
    required String questionType,
    required String source,
  }) async {
    await _db
        .collection('question_feedback')
        .doc(_docId(userId, questionId))
        .set({
      'userId': userId,
      'questionId': questionId,
      'vote': vote,
      'quizTitle': quizTitle,
      'theme': theme,
      'difficulty': difficulty,
      'questionType': questionType,
      'source': source,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<List<QuestionFeedback>> getAllFeedback() async {
    final snap = await _db.collection('question_feedback').get();
    return snap.docs.map((d) => QuestionFeedback.fromDoc(d)).toList();
  }
}
