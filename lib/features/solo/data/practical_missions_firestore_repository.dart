import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Gère la progression des TP 100% Cloud sur Firestore.
/// Chemin : /users/{uid}/tp_progress/{trackId}
class PracticalMissionsFirestoreRepository {
  PracticalMissionsFirestoreRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  /// Lit l'index de la prochaine mission pour un parcours donné.
  Future<int> readNextMissionIndex(String trackId) async {
    final uid = _uid;
    if (uid == null) return 0;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('tp_progress')
          .doc(trackId)
          .get();

      if (!doc.exists) return 0;
      return doc.data()?['nextMissionIndex'] as int? ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Met à jour l'index de progression.
  Future<void> setNextMissionIndex(String trackId, int index) async {
    final uid = _uid;
    if (uid == null) return;

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('tp_progress')
        .doc(trackId)
        .set({
      'nextMissionIndex': index < 0 ? 0 : index,
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Réinitialise la progression d'un parcours.
  Future<void> clearTrack(String trackId) async {
    await setNextMissionIndex(trackId, 0);
  }

  /// Enregistre l'intérêt pour un TP "Coming Soon".
  /// Utilise arrayUnion pour éviter les doublons d'UID.
  Future<void> markInterest(String trackId) async {
    final uid = _uid;
    if (uid == null) return;

    await _firestore.collection('tp_coming_soon').doc(trackId).set({
      'interested_uids': FieldValue.arrayUnion([uid]),
      'last_interest': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Vérifie si l'utilisateur a déjà manifesté son intérêt.
  Future<bool> hasExpressedInterest(String trackId) async {
    final uid = _uid;
    if (uid == null) return false;

    final doc = await _firestore.collection('tp_coming_soon').doc(trackId).get();
    if (!doc.exists) return false;

    final uids = doc.data()?['interested_uids'] as List<dynamic>? ?? [];
    return uids.contains(uid);
  }
}
