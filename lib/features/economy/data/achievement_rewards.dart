import '../../../data/repositories/user_repository.dart';
import 'achievement_catalog.dart';
import 'achievements_repository.dart';

/// Débloque un haut fait (prefs) et, si défini, le badge Firestore associé.
class AchievementRewards {
  AchievementRewards({
    AchievementsRepository? achievements,
    UserRepository? users,
    this.onUnlocked,
  })  : _ach = achievements ?? AchievementsRepository(),
        _users = users ?? UserRepository();

  final AchievementsRepository _ach;
  final UserRepository _users;
  final void Function(String emoji, String title)? onUnlocked;

  /// `true` si le haut fait vient d’être débloqué pour la première fois.
  Future<bool> unlock(String uid, String achievementId) async {
    final def = kAchievementCatalogById[achievementId];
    final fresh = await _ach.unlock(uid, achievementId);
    if (!fresh) return false;
    final badgeId = def?.linkedBadgeId;
    if (badgeId != null && uid.isNotEmpty) {
      try {
        await _users.addBadge(uid, badgeId);
      } catch (_) {}
    }
    if (def != null) onUnlocked?.call(def.emoji, def.title);
    return true;
  }
}
