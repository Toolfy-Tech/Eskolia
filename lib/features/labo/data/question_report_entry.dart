import 'package:cloud_firestore/cloud_firestore.dart';

import 'question_report_kind.dart';

class QuestionReportEntry {
  const QuestionReportEntry({
    required this.id,
    required this.reportType,
    required this.assetPath,
    required this.questionId,
    required this.message,
    required this.kind,
    required this.status,
    this.questionPreview,
    this.createdAt,
    this.reporterId = '',
  });

  final String id;
  final String reportType;
  final String assetPath;
  final String questionId;
  final String message;
  final QuestionReportKind kind;
  /// `pending` | `in_progress` | `resolved` | `rejected` (admin plus tard).
  final String status;
  final String? questionPreview;
  final DateTime? createdAt;
  final String reporterId;

  factory QuestionReportEntry.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return QuestionReportEntry(
      id: doc.id,
      reportType: data['type'] as String? ?? 'question',
      assetPath: data['assetPath'] as String? ?? '',
      questionId: data['questionId'] as String? ?? '',
      message: data['message'] as String? ?? '',
      kind: QuestionReportKind.fromFirestore(data['kind'] as String?),
      status: data['status'] as String? ?? 'pending',
      questionPreview: data['questionPreview'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      reporterId: data['userId'] as String? ?? '',
    );
  }
}
