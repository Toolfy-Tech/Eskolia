import 'dart:math' show min;

import '../../../data/repositories/user_repository.dart';
import '../../auth/data/user_model.dart';
import '../../quiz/services/revision_pool_repository.dart';
import 'achievement_side_stats.dart';

/// Données pour afficher « 7 / 10 » (et équivalents) sur les hauts faits.
class AchievementProgressSnapshot {
  const AchievementProgressSnapshot({
    required this.user,
    required this.revisionQuizDone,
    required this.lacunesQuizDone,
    required this.dailyQuizDone,
    required this.flashSessionsDone,
    required this.battleWins,
    required this.pinCount,
  });

  final UserModel? user;
  final int revisionQuizDone;
  final int lacunesQuizDone;
  final int dailyQuizDone;
  final int flashSessionsDone;
  final int battleWins;
  final int pinCount;

  static Future<AchievementProgressSnapshot> load(String uid) async {
    if (uid.isEmpty) {
      return const AchievementProgressSnapshot(
        user: null,
        revisionQuizDone: 0,
        lacunesQuizDone: 0,
        dailyQuizDone: 0,
        flashSessionsDone: 0,
        battleWins: 0,
        pinCount: 0,
      );
    }
    final user = await UserRepository().getUserById(uid);
    final rev = await AchievementSideStats.read(uid, 'revisionQuizDone');
    final lac = await AchievementSideStats.read(uid, 'lacunesQuizDone');
    final daily = await AchievementSideStats.read(uid, 'dailyQuizDone');
    final flash = await AchievementSideStats.read(uid, 'flashSessionsDone');
    final bw = await AchievementSideStats.read(uid, 'battleWins');
    final pins = (await RevisionPoolRepository().readEntries()).length;
    return AchievementProgressSnapshot(
      user: user,
      revisionQuizDone: rev,
      lacunesQuizDone: lac,
      dailyQuizDone: daily,
      flashSessionsDone: flash,
      battleWins: bw,
      pinCount: pins,
    );
  }

  /// Texte « cur / target » ou `null` si pas de jauge pertinente.
  String? labelFor(String achievementId, bool unlocked) {
    final u = user;
    switch (achievementId) {
      case 'quiz_10':
        return _pair(u?.totalQuizzesPlayed ?? 0, 10, unlocked);
      case 'quiz_50':
        return _pair(u?.totalQuizzesPlayed ?? 0, 50, unlocked);
      case 'quiz_100':
        return _pair(u?.totalQuizzesPlayed ?? 0, 100, unlocked);
      case 'quiz_wins_10':
        return _pair(u?.totalWins ?? 0, 10, unlocked);
      case 'quiz_wins_50':
        return _pair(u?.totalWins ?? 0, 50, unlocked);
      case 'revision_quiz_10':
        return _pair(revisionQuizDone, 10, unlocked);
      case 'lacunes_grinder':
        return _pair(lacunesQuizDone, 15, unlocked);
      case 'daily_quiz_7':
        return _pair(dailyQuizDone, 7, unlocked);
      case 'pool_25_pins':
        return _pair(pinCount, 25, unlocked);
      case 'pool_75_pins':
        return _pair(pinCount, 75, unlocked);
      case 'flash_sessions_20':
        return _pair(flashSessionsDone, 20, unlocked);
      case 'flash_sessions_75':
        return _pair(flashSessionsDone, 75, unlocked);
      case 'level_15':
        if (u == null) return null;
        return _pair(u.levelFromXp, 15, unlocked);
      case 'level_30':
        if (u == null) return null;
        return _pair(u.levelFromXp, 30, unlocked);
      case 'streak_week_fire':
        return _pair(u?.streak ?? 0, 7, unlocked);
      case 'streak_month':
        return _pair(u?.streak ?? 0, 30, unlocked);
      case 'battle_wins_10':
        return _pair(battleWins, 10, unlocked);
      default:
        return null;
    }
  }

  static String _pair(int value, int target, bool unlocked) {
    final n = unlocked ? target : min(value, target);
    return '$n / $target';
  }
}
