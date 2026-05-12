import '../../../data/repositories/user_repository.dart';
import '../../home/data/daily_quests_repository.dart';
import 'achievement_rewards.dart';
import 'achievement_triggers.dart';

/// Applique marquage quête + XP + hauts faits (utilisateur connecté).
class DailyQuestRewardService {
  DailyQuestRewardService({
    DailyQuestsRepository? quests,
    UserRepository? users,
    AchievementRewards? achievementRewards,
  })  : _quests = quests ?? DailyQuestsRepository(),
        _users = users ?? UserRepository(),
        _achievementRewards = achievementRewards ?? AchievementRewards();

  final DailyQuestsRepository _quests;
  final UserRepository _users;
  final AchievementRewards _achievementRewards;

  static const int perQuestXp = 20;
  static const int trioBonusXp = 50;

  Future<void> _grantIfNew(
    String uid,
    DailyQuestsSnapshot before,
    DailyQuestsSnapshot after, {
    required bool questJustCompleted,
    String? parcoursAchievementId,
  }) async {
    if (uid.isEmpty) return;
    if (questJustCompleted) {
      await _users.addXp(uid, perQuestXp);
    }
    if (after.completedCount == 3 && before.completedCount < 3) {
      await _users.addXp(uid, trioBonusXp);
      await _achievementRewards.unlock(uid, 'daily_trio');
    }
    if (parcoursAchievementId != null && questJustCompleted) {
      await _achievementRewards.unlock(uid, parcoursAchievementId);
    }
    if (questJustCompleted ||
        (after.completedCount == 3 && before.completedCount < 3)) {
      final u = await _users.getUserById(uid);
      if (u != null) {
        await AchievementTriggers().syncFromUserSnapshot(u);
      }
    }
  }

  Future<void> onQuizCompleted(String uid) async {
    final before = await _quests.snapshot();
    await _quests.markQuizDone();
    final after = await _quests.snapshot();
    final fresh = !before.quizDone && after.quizDone;
    await _grantIfNew(uid, before, after, questJustCompleted: fresh);
  }

  Future<void> onFlashSessionCompleted(String uid) async {
    final before = await _quests.snapshot();
    await _quests.markFlashcardSessionDone();
    final after = await _quests.snapshot();
    final fresh = !before.flashDone && after.flashDone;
    await _grantIfNew(uid, before, after, questJustCompleted: fresh);
  }

  Future<void> onParcoursVisited(String uid) async {
    final before = await _quests.snapshot();
    await _quests.markParcoursProgressDone();
    final after = await _quests.snapshot();
    final fresh = !before.parcoursDone && after.parcoursDone;
    await _grantIfNew(
      uid,
      before,
      after,
      questJustCompleted: fresh,
      parcoursAchievementId: 'first_parcours_day',
    );
  }
}
