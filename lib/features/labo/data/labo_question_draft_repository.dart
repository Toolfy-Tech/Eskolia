import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'labo_question_draft.dart';

/// Propositions de questions communautaires — validation admin ultérieure.
class LaboQuestionDraftRepository {
  LaboQuestionDraftRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  Future<void> submitDraft({
    required String sectionHint,
    required String statement,
    required List<String> options,
    required int correctIndex,
    String explanation = '',
    String difficulty = 'medium',
    String authorName = 'Anonyme',
    Map<String, dynamic>? rawMasteryData,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isEmpty) {
      throw StateError('Utilisateur non connecté');
    }

    await _db.collection('labo_question_drafts').add({
      'authorId': uid,
      'authorName': authorName,
      'sectionHint': sectionHint.trim(),
      'statement': statement.trim(),
      'options': options.map((e) => e.trim()).toList(),
      'correctIndex': correctIndex.clamp(0, 3),
      'explanation': explanation.trim(),
      'difficulty': difficulty,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      if (rawMasteryData != null) 'masteryData': rawMasteryData,
    });
  }

  Stream<List<LaboQuestionDraft>> watchRecentDrafts({int limit = 60}) {
    return _db
        .collection('labo_question_drafts')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((s) => s.docs.map(LaboQuestionDraft.fromDoc).toList());
  }

  Future<void> setDraftStatus(
    String docId,
    String status, {
    String? reviewNote,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    await _db.collection('labo_question_drafts').doc(docId).update({
      'status': status,
      'reviewedAt': FieldValue.serverTimestamp(),
      'reviewedBy': uid,
      if (reviewNote != null && reviewNote.isNotEmpty) 'reviewNote': reviewNote,
    });
  }

  Future<void> deleteDraft(String docId) async {
    await _db.collection('labo_question_drafts').doc(docId).delete();
  }
}
