import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'question_report_entry.dart';
import 'question_report_kind.dart';

/// Signalements question — Firestore `signalements` (blueprint v3 § Labo).
class QuestionReportRepository {
  QuestionReportRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  Future<void> reportQuestion({
    required String assetPath,
    required String questionId,
    String message = '',
    QuestionReportKind kind = QuestionReportKind.other,
    String questionPreview = '',
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    await _db.collection('signalements').add({
      'type': 'question',
      'assetPath': assetPath,
      'questionId': questionId,
      'message': message,
      'kind': kind.firestoreValue,
      if (questionPreview.isNotEmpty) 'questionPreview': questionPreview,
      'status': 'pending',
      'userId': uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Derniers signalements de l’utilisateur (tri local par date).
  Future<List<QuestionReportEntry>> listMyReports(String uid) async {
    if (uid.isEmpty) return [];
    final snap = await _db
        .collection('signalements')
        .where('userId', isEqualTo: uid)
        .limit(50)
        .get();
    final out = snap.docs
        .map(QuestionReportEntry.fromDoc)
        .where((e) => e.reportType == 'question')
        .toList();
    out.sort((a, b) {
      final ta = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final tb = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return tb.compareTo(ta);
    });
    return out;
  }
}
