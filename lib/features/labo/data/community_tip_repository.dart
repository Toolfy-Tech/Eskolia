import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'community_tip.dart';
import 'labo_tip_kind.dart';

/// Tips communautaires — collection Firestore `community_tips`.
class CommunityTipRepository {
  CommunityTipRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  Future<void> submitTip({
    required String moduleId,
    String moduleTitle = '',
    required LaboTipKind kind,
    required String body,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isEmpty) throw StateError('Utilisateur non connecté');
    final mid = moduleId.trim();
    if (mid.isEmpty) throw ArgumentError('ID module requis');
    final b = body.trim();
    if (b.isEmpty) throw ArgumentError('Texte requis');
    await _db.collection('community_tips').add({
      'authorId': uid,
      'moduleId': mid,
      'moduleTitle': moduleTitle.trim(),
      'kind': kind.firestoreValue,
      'body': b,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'upCount': 0,
      'downCount': 0,
      'voters': <String, dynamic>{},
    });
  }

  /// Vote utile / pas utile. Même bouton = retire le vote. Basculer d’un côté à l’autre met à jour les compteurs.
  Future<void> castTipVote(String docId, int direction) async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isEmpty) throw StateError('Utilisateur non connecté');
    if (direction != 1 && direction != -1) {
      throw ArgumentError('direction doit être 1 ou -1');
    }
    final ref = _db.collection('community_tips').doc(docId);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) throw StateError('Astuce introuvable');
      final d = snap.data() ?? {};
      final voters = Map<String, dynamic>.from(d['voters'] as Map? ?? {});
      var up = (d['upCount'] as num?)?.toInt() ?? 0;
      var down = (d['downCount'] as num?)?.toInt() ?? 0;
      final prev = (voters[uid] as num?)?.toInt();
      void removePrev() {
        if (prev == 1) up = (up - 1).clamp(0, 1 << 30);
        if (prev == -1) down = (down - 1).clamp(0, 1 << 30);
        voters.remove(uid);
      }

      int nextVote;
      if (prev == direction) {
        nextVote = 0;
      } else {
        nextVote = direction;
      }

      if (nextVote == 0) {
        removePrev();
      } else {
        removePrev();
        if (nextVote == 1) {
          up++;
          voters[uid] = 1;
        } else {
          down++;
          voters[uid] = -1;
        }
      }

      tx.update(ref, {
        'upCount': up,
        'downCount': down,
        'voters': voters,
      });
    });
  }

  /// Astuces validées pour un module (filtre `approved` côté client).
  Stream<List<CommunityTip>> watchApprovedForModule(String moduleId) {
    if (moduleId.isEmpty) return Stream.value([]);
    return _db
        .collection('community_tips')
        .where('moduleId', isEqualTo: moduleId)
        .limit(30)
        .snapshots()
        .map(
          (s) => s.docs
              .map(CommunityTip.fromDoc)
              .where((t) => t.status == 'approved')
              .toList(),
        );
  }

  Stream<List<CommunityTip>> watchAllTips({int limit = 80}) {
    return _db
        .collection('community_tips')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((s) => s.docs.map(CommunityTip.fromDoc).toList());
  }

  Future<void> setTipStatus(String docId, String status) async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    await _db.collection('community_tips').doc(docId).update({
      'status': status,
      'reviewedAt': FieldValue.serverTimestamp(),
      'reviewedBy': uid,
    });
  }

  Future<void> deleteTip(String docId) async {
    await _db.collection('community_tips').doc(docId).delete();
  }
}
