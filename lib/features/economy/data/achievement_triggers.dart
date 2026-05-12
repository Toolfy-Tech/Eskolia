import '../../../data/repositories/user_repository.dart';
import '../../auth/data/user_model.dart';
import 'achievement_rewards.dart';
import 'achievement_side_stats.dart';

/// Branche les hauts faits sur les événements de jeu (stats Firestore + compteurs locaux).
class AchievementTriggers {
  AchievementTriggers({
    UserRepository? users,
    AchievementRewards? rewards,
    void Function(String emoji, String title)? onUnlocked,
  })  : _users = users ?? UserRepository(),
        _rewards = rewards ?? AchievementRewards(onUnlocked: onUnlocked);

  final UserRepository _users;
  final AchievementRewards _rewards;

  /// Fin d'un quiz « feature » (résultat écran), avant quêtes du jour.
  /// Le score est désormais un double pour supporter les points partiels (indices/tickets).
  Future<void> onQuizSessionCompleted(
    String uid, {
    required double score,
    required int total,
    required String sessionId,
    required bool survivalRun,
    required bool survivalEliminated,
  }) async {
    if (uid.isEmpty) return;
    
    // On considère qu'un module est "réussi" si le score est >= 60%
    final passed = total > 0 && (score / total) >= 0.6;
    await _users.incrementQuizCompletionStats(uid, passed: passed);
    
    final user = await _users.getUserById(uid);
    if (user == null) return;

    final r = _rewards;
    await r.unlock(uid, 'first_quiz');
    
    // Pour les succès basés sur le score parfait, on tronque pour comparer
    final int intScore = score.floor();

    if (survivalRun &&
        !survivalEliminated &&
        total > 0 &&
        intScore >= total) {
      await r.unlock(uid, 'survival_perfect');
    }

    final played = user.totalQuizzesPlayed;
    if (played >= 10) await r.unlock(uid, 'quiz_10');
    if (played >= 50) await r.unlock(uid, 'quiz_50');
    if (played >= 100) await r.unlock(uid, 'quiz_100');

    final wins = user.totalWins;
    if (wins >= 10) await r.unlock(uid, 'quiz_wins_10');
    if (wins >= 50) await r.unlock(uid, 'quiz_wins_50');

    // Flawless Mastery : Requiert 100% des points (pas d'indices utilisés)
    if (!survivalRun && total >= 15 && score >= total.toDouble()) {
      await r.unlock(uid, 'quiz_flawless_big');
    }

    if (sessionId.startsWith('revision_')) {
      final c = await AchievementSideStats.bump(uid, 'revisionQuizDone', 1);
      await r.unlock(uid, 'first_revision_quiz');
      if (c >= 10) await r.unlock(uid, 'revision_quiz_10');
    }
    if (sessionId.startsWith('lacunes_')) {
      final c = await AchievementSideStats.bump(uid, 'lacunesQuizDone', 1);
      await r.unlock(uid, 'first_lacunes_quiz');
      if (c >= 15) await r.unlock(uid, 'lacunes_grinder');
    }
    if (sessionId.startsWith('daily_')) {
      final c = await AchievementSideStats.bump(uid, 'dailyQuizDone', 1);
      await r.unlock(uid, 'first_daily_quiz');
      if (c >= 7) await r.unlock(uid, 'daily_quiz_7');
    }

    await _applyProfileThresholds(user);
  }

  /// Pool 📌 : nombre de questions épinglées après sauvegarde d'un résultat.
  Future<void> onRevisionPoolPinsChanged(String uid, int pinCount) async {
    if (uid.isEmpty) return;
    final r = _rewards;
    if (pinCount >= 25) await r.unlock(uid, 'pool_25_pins');
    if (pinCount >= 75) await r.unlock(uid, 'pool_75_pins');
  }

  Future<void> onFlashSessionCompleted(String uid) async {
    if (uid.isEmpty) return;
    final r = _rewards;
    await r.unlock(uid, 'first_flash');
    final c = await AchievementSideStats.bump(uid, 'flashSessionsDone', 1);
    if (c >= 20) await r.unlock(uid, 'flash_sessions_20');
    if (c >= 75) await r.unlock(uid, 'flash_sessions_75');
  }

  /// Fin de bataille multijoueur ([won] : 1er au classement points).
  Future<void> onBattleFinished(String uid, {required bool won}) async {
    if (uid.isEmpty) return;
    await _users.addXp(uid, won ? 200 : 100);
    if (won) await _users.incrementBattleWins(uid);
    final r = _rewards;
    await AchievementSideStats.bump(uid, 'battlePlayed', 1);
    await r.unlock(uid, 'battle_first');
    if (won) {
      final w = await AchievementSideStats.bump(uid, 'battleWins', 1);
      await r.unlock(uid, 'battle_win_first');
      if (w >= 10) await r.unlock(uid, 'battle_wins_10');
    }
  }

  /// À appeler quand le profil Firestore est chargé (accueil, etc.).
  Future<void> syncFromUserSnapshot(UserModel user) async {
    if (user.uid.isEmpty) return;
    await _applyProfileThresholds(user);
  }

  Future<void> _applyProfileThresholds(UserModel user) async {
    final uid = user.uid;
    final r = _rewards;
    final level = user.levelFromXp;
    if (level >= 15) await r.unlock(uid, 'level_15');
    if (level >= 30) await r.unlock(uid, 'level_30');
    if (user.streak >= 7) await r.unlock(uid, 'streak_week_fire');
    if (user.streak >= 30) await r.unlock(uid, 'streak_month');
  }
}
