import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../auth/data/user_model.dart';

class LeaderboardEntryModel {
  const LeaderboardEntryModel({
    required this.uid,
    required this.username,
    required this.xp,
    required this.level,
    required this.rank,
    required this.xpThisWeek,
    required this.totalWins,
    this.battleWins = 0,
    required this.streak,
  });

  final String uid;
  final String username;
  final int xp;
  final int level;
  final int rank;
  final int xpThisWeek;
  final int totalWins;
  final int battleWins;
  final int streak;

  factory LeaderboardEntryModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    int rank = 0,
  }) {
    final data = doc.data() ?? {};
    final xpVal = (data['xp'] as num?)?.toInt() ?? 0;
    return LeaderboardEntryModel(
      uid: doc.id,
      username: data['username'] as String? ?? '',
      xp: xpVal,
      level: (data['level'] as num?)?.toInt() ?? ((xpVal ~/ 1000) + 1),
      rank: (data['rank'] as num?)?.toInt() ?? rank,
      xpThisWeek: (data['xpThisWeek'] as num?)?.toInt() ?? 0,
      totalWins: (data['totalWins'] as num?)?.toInt() ?? 0,
      battleWins: (data['battleWins'] as num?)?.toInt() ?? 0,
      streak: (data['streak'] as num?)?.toInt() ?? 0,
    );
  }

  factory LeaderboardEntryModel.fromUserModel(UserModel user, int rank) {
    return LeaderboardEntryModel(
      uid: user.uid,
      username: user.username,
      xp: user.xp,
      level: user.level,
      rank: rank,
      xpThisWeek: user.xpThisWeek,
      totalWins: user.totalWins,
      battleWins: user.battleWins,
      streak: user.streak,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'uid': uid,
        'username': username,
        'xp': xp,
        'level': level,
        'rank': rank,
        'xpThisWeek': xpThisWeek,
        'totalWins': totalWins,
        'battleWins': battleWins,
        'streak': streak,
      };

  LeaderboardEntryModel copyWith({
    String? uid,
    String? username,
    int? xp,
    int? level,
    int? rank,
    int? xpThisWeek,
    int? totalWins,
    int? battleWins,
    int? streak,
  }) {
    return LeaderboardEntryModel(
      uid: uid ?? this.uid,
      username: username ?? this.username,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      rank: rank ?? this.rank,
      xpThisWeek: xpThisWeek ?? this.xpThisWeek,
      totalWins: totalWins ?? this.totalWins,
      battleWins: battleWins ?? this.battleWins,
      streak: streak ?? this.streak,
    );
  }
}
