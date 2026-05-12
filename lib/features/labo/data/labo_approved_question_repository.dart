import 'package:cloud_firestore/cloud_firestore.dart';

import 'labo_question_draft.dart';

/// Lecture Firestore des brouillons **validés** — sans dépendre de [QuizRepository].
class LaboApprovedQuestionRepository {
  LaboApprovedQuestionRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  static const _collection = 'labo_question_drafts';

  /// Sections déduites des chemins `data/questions/.../section-XX/...`.
  static Set<String> sectionIdsFromAssetPaths(Iterable<String> paths) {
    final out = <String>{};
    for (final p in paths) {
      final m = RegExp(r'section-(\d+)', caseSensitive: false).firstMatch(p);
      if (m == null) continue;
      final n = int.tryParse(m.group(1)!);
      if (n == null) continue;
      out.add('S${n.toString().padLeft(2, '0')}');
    }
    return out;
  }

  static bool draftMatchesSectionHints(
    LaboQuestionDraft d,
    Set<String> sectionIds,
  ) {
    if (sectionIds.isEmpty) return true;
    final h = d.sectionHint.toUpperCase().replaceAll(' ', '');
    if (h.isEmpty) return true;
    for (final s in sectionIds) {
      if (h.contains(s)) return true;
      final n = s.replaceFirst(RegExp(r'^S'), '');
      if (h.contains('SECTION-$n') || h.contains('SECTION$n')) return true;
    }
    return false;
  }

  /// Nombre max de questions Labo à injecter dans une session.
  static int capForSession(int sessionMaxQuestions) {
    if (sessionMaxQuestions <= 0) return 0;
    return (sessionMaxQuestions * 0.25).ceil().clamp(2, 14);
  }

  Future<List<LaboQuestionDraft>> fetchApprovedDrafts({
    int limit = 300,
    Set<String>? restrictToSectionIds,
  }) async {
    final snap = await _db
        .collection(_collection)
        .where('status', isEqualTo: 'approved')
        .limit(limit)
        .get();
    var list = snap.docs.map(LaboQuestionDraft.fromDoc).toList();
    final restrict = restrictToSectionIds;
    if (restrict != null && restrict.isNotEmpty) {
      list = list
          .where((d) => draftMatchesSectionHints(d, restrict))
          .toList();
    }
    return list;
  }

  Future<LaboQuestionDraft?> fetchApprovedDraftById(String docId) async {
    if (docId.isEmpty) return null;
    final doc = await _db.collection(_collection).doc(docId).get();
    if (!doc.exists) return null;
    final d = LaboQuestionDraft.fromDoc(doc);
    if (d.status != 'approved') return null;
    return d;
  }
}
