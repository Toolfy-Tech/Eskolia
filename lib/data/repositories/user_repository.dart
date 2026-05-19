import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/time/xp_week_key.dart';
import '../../features/auth/data/user_model.dart';

class UserRepository {
  UserRepository({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  Future<UserModel?> getUserById(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  Stream<UserModel?> watchUser(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    });
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
  }

  Future<void> addXp(String uid, int amount) async {
    if (amount <= 0) return;
    final ref = _db.collection('users').doc(uid);
    final weekKey = xpWeekMondayKey(DateTime.now());
    await _db.runTransaction<void>((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) return;
      final storedKey = snap.data()?['xpWeekStartKey'] as String?;
      if (storedKey != weekKey) {
        tx.update(ref, {
          'xp': FieldValue.increment(amount),
          'xpThisWeek': amount,
          'xpWeekStartKey': weekKey,
        });
      } else {
        tx.update(ref, {
          'xp': FieldValue.increment(amount),
          'xpThisWeek': FieldValue.increment(amount),
        });
      }
    });
  }

  Future<void> incrementBattleWins(String uid) async {
    if (uid.isEmpty) return;
    await _db.collection('users').doc(uid).update({
      'battleWins': FieldValue.increment(1),
    });
  }

  Future<void> addBadge(String uid, String badge) async {
    if (uid.isEmpty || badge.isEmpty) return;
    await _db.collection('users').doc(uid).update({
      'badges': FieldValue.arrayUnion([badge]),
    });
  }

  /// Incrémente les stats de quiz solo (parcours, rapide, révision, etc.).
  Future<void> incrementQuizCompletionStats(String uid, {required bool passed}) async {
    if (uid.isEmpty) return;
    final patch = <String, dynamic>{
      'totalQuizzesPlayed': FieldValue.increment(1),
    };
    if (passed) {
      patch['totalWins'] = FieldValue.increment(1);
    }
    await _db.collection('users').doc(uid).update(patch);
  }

  Future<void> updateStreak(String uid, int streak) async {
    final now = DateTime.now();
    final todayInt = now.year * 10000 + now.month * 100 + now.day;
    await _db.collection('users').doc(uid).update({
      'streak': streak,
      'lastLogin': FieldValue.serverTimestamp(),
      'activeDays': FieldValue.arrayUnion([todayInt]),
    });
  }

  Future<void> updateProgress(String uid, int chapter, int module) async {
    await _db.collection('users').doc(uid).update({
      'currentChapter': chapter,
      'currentModule': module,
    });
  }
}
