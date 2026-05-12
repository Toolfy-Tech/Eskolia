import 'package:cloud_firestore/cloud_firestore.dart';

class LaboQuestionDraft {
  const LaboQuestionDraft({
    required this.id,
    required this.authorId,
    required this.authorName, // Nouveau champ
    required this.sectionHint,
    required this.statement,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.difficulty,
    required this.status,
    this.reviewNote,
    this.createdAt,
  });

  final String id;
  final String authorId;
  final String authorName; // Nouveau champ
  final String sectionHint;
  final String statement;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final String difficulty;
  final String status;
  final String? reviewNote;
  final DateTime? createdAt;

  factory LaboQuestionDraft.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    final opts = data['options'];
    final list = opts is List
        ? opts.map((e) => e.toString()).toList()
        : <String>[];
    return LaboQuestionDraft(
      id: doc.id,
      authorId: data['authorId'] as String? ?? '',
      authorName: data['authorName'] as String? ?? 'Anonyme',
      sectionHint: data['sectionHint'] as String? ?? '',
      statement: data['statement'] as String? ?? '',
      options: list,
      correctIndex: (data['correctIndex'] as num?)?.toInt() ?? 0,
      explanation: data['explanation'] as String? ?? '',
      difficulty: data['difficulty'] as String? ?? 'medium',
      status: data['status'] as String? ?? 'pending',
      reviewNote: data['reviewNote'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
