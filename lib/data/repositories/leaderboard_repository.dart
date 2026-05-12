import 'package:cloud_firestore/cloud_firestore.dart';

import '../../features/classement/data/models/daily_leaderboard_entry.dart';
import '../../features/classement/data/models/leaderboard_entry_model.dart';

class LeaderboardRepository {
  LeaderboardRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  Future<List<LeaderboardEntryModel>> getTopUsers({int limit = 100}) async {
    final snap = await _db
        .collection('users')
        .orderBy('xp', descending: true)
        .limit(limit)
        .get();
    return _withRanks(snap.docs);
  }

  Stream<List<LeaderboardEntryModel>> watchTopUsers({int limit = 100}) {
    return _db
        .collection('users')
        .orderBy('xp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => _withRanks(snap.docs));
  }

  Future<int> getUserRank(String uid) async {
    final userDoc = await _db.collection('users').doc(uid).get();
    if (!userDoc.exists) return 0;
    final data = userDoc.data();
    final userXp = (data?['xp'] as num?)?.toInt() ?? 0;
    final agg = await _db
        .collection('users')
        .where('xp', isGreaterThan: userXp)
        .count()
        .get();
    final higher = agg.count ?? 0;
    return higher + 1;
  }

  Future<List<LeaderboardEntryModel>> getWeeklyTop({int limit = 100}) async {
    final snap = await _db
        .collection('users')
        .orderBy('xpThisWeek', descending: true)
        .limit(limit)
        .get();
    return _withRanks(snap.docs);
  }

  Stream<List<LeaderboardEntryModel>> watchWeeklyTop({int limit = 100}) {
    return _db
        .collection('users')
        .orderBy('xpThisWeek', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => _withRanks(snap.docs));
  }

  /// Classement basé sur un champ numérique du doc utilisateur (ex. `battleWins`, `totalWins`).
  Stream<List<LeaderboardEntryModel>> watchTopByUserField(
    String field, {
    int limit = 100,
  }) {
    return _db
        .collection('users')
        .orderBy(field, descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => _withRanks(snap.docs));
  }

  /// `daily_yyyyMMdd` → `yyyyMMdd` (aligné sur [QuizRepository] session du jour).
  static String? dayKeyFromDailySessionId(String sessionId) {
    if (!sessionId.startsWith('daily_')) return null;
    final key = sessionId.substring('daily_'.length);
    return key.length == 8 ? key : null;
  }

  Stream<List<DailyLeaderboardEntry>> watchDailyQuizScores({
    required String dayKey,
    int limit = 100,
  }) {
    return _db
        .collection('leaderboard_daily')
        .doc(dayKey)
        .collection('scores')
        .orderBy('score', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) {
      return [
        for (var i = 0; i < snap.docs.length; i++)
          DailyLeaderboardEntry.fromDoc(snap.docs[i], rank: i + 1),
      ];
    });
  }

  /// Publie le meilleur score du joueur pour le jour (une seule entrée par `uid` / `dayKey`).
  Future<void> submitDailyQuizBest({
    required String uid,
    required String dayKey,
    required double score, // Changé int en double pour le scoring Mastery
    required int total,
  }) async {
    if (uid.isEmpty || dayKey.length != 8 || total <= 0) return;
    final userSnap = await _db.collection('users').doc(uid).get();
    final username = (userSnap.data()?['username'] as String?)?.trim();
    final name =
        username != null && username.isNotEmpty ? username : 'Joueur';
    final ref = _db
        .collection('leaderboard_daily')
        .doc(dayKey)
        .collection('scores')
        .doc(uid);
    await _db.runTransaction<void>((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) {
        tx.set(ref, {
          'username': name,
          'score': score,
          'total': total,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        return;
      }
      final old = (snap.data()?['score'] as num?)?.toDouble() ?? 0.0;
      if (score > old) {
        tx.update(ref, {
          'username': name,
          'score': score,
          'total': total,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        tx.update(ref, {
          'username': name,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  List<LeaderboardEntryModel> _withRanks(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final list = <LeaderboardEntryModel>[];
    for (var i = 0; i < docs.length; i++) {
      list.add(LeaderboardEntryModel.fromFirestore(docs[i], rank: i + 1));
    }
    return list;
  }
}
