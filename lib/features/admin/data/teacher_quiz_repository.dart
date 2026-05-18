import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/teacher_quiz.dart';

class TeacherQuizRepository {
  final _db = FirebaseFirestore.instance;

  Stream<List<TeacherQuiz>> watchAll() => _db
      .collection('teacher_quizzes')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) => TeacherQuiz.fromDoc(d)).toList());

  Stream<List<TeacherQuiz>> watchPublished() => _db
      .collection('teacher_quizzes')
      .where('isPublished', isEqualTo: true)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) => TeacherQuiz.fromDoc(d)).toList());

  Future<void> create({
    required String authorId,
    required String authorName,
    required String title,
    required String description,
    required List<TeacherQuizQuestion> questions,
  }) async {
    await _db.collection('teacher_quizzes').add({
      'title': title,
      'description': description,
      'authorId': authorId,
      'authorName': authorName,
      'isPublished': false,
      'questions': questions.map((q) => q.toMap()).toList(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateQuestions(
      String quizId, List<TeacherQuizQuestion> questions) async {
    await _db.collection('teacher_quizzes').doc(quizId).update({
      'questions': questions.map((q) => q.toMap()).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> togglePublished(String quizId, bool isPublished) async {
    await _db.collection('teacher_quizzes').doc(quizId).update({
      'isPublished': isPublished,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> delete(String quizId) async {
    await _db.collection('teacher_quizzes').doc(quizId).delete();
  }
}
