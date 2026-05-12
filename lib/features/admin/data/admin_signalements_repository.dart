import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../labo/data/question_report_entry.dart';

class AdminSignalementsRepository {
  AdminSignalementsRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  Stream<List<QuestionReportEntry>> watchRecent({int limit = 80}) {
    return _db
        .collection('signalements')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (s) => s.docs.map(QuestionReportEntry.fromDoc).toList(),
        );
  }

  Future<void> updateStatus(String docId, String status) async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    await _db.collection('signalements').doc(docId).update({
      'status': status,
      'reviewedAt': FieldValue.serverTimestamp(),
      'reviewedBy': uid,
    });
  }

  Future<void> deleteSignalement(String docId) async {
    await _db.collection('signalements').doc(docId).delete();
  }
}
