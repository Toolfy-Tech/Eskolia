import 'package:cloud_firestore/cloud_firestore.dart';

/// Entrée publique du classement « quiz du jour » (`leaderboard_daily/{dayKey}/scores/{uid}`).
/// Le score est désormais un double pour supporter la précision Mastery.
class DailyLeaderboardEntry {
  const DailyLeaderboardEntry({
    required this.uid,
    required this.username,
    required this.score,
    required this.total,
    required this.rank,
  });

  final String uid;
  final String username;
  final double score; // Changé de int à double
  final int total;
  final int rank;

  factory DailyLeaderboardEntry.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    required int rank,
  }) {
    final data = doc.data() ?? {};
    final name = (data['username'] as String?)?.trim();
    return DailyLeaderboardEntry(
      uid: doc.id,
      username: name != null && name.isNotEmpty ? name : 'Joueur',
      score: (data['score'] as num?)?.toDouble() ?? 0.0,
      total: (data['total'] as num?)?.toInt() ?? 0,
      rank: rank,
    );
  }
}
