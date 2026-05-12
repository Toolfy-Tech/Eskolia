import '../../../data/repositories/user_repository.dart';
import 'parcours_repository.dart';
import 'tip_progress_repository.dart';

/// Badge Firestore lorsque **tous** les modules d’une section sont validés.
class ParcoursSectionBadgeRewards {
  ParcoursSectionBadgeRewards({UserRepository? users})
      : _users = users ?? UserRepository();

  final UserRepository _users;

  static String badgeIdForSection({
    required String formationId,
    required String sectionId,
  }) {
    final f = formationId.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
    final s = sectionId.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
    return 'badge_section_${f}_$s';
  }

  /// À appeler après [TipProgressRepository.markModulePassed] pour le module concerné.
  Future<void> tryAwardSectionBadge(String uid, String moduleIdJustPassed) async {
    if (uid.isEmpty || moduleIdJustPassed.isEmpty) return;
    final loc = ParcoursRepository.moduleLocation[moduleIdJustPassed];
    if (loc == null) return;

    final key = '${loc.formationId}::${loc.sectionId}';
    final section = ParcoursRepository.sectionByCompoundKey[key];
    if (section == null) return;

    final done = await TipProgressRepository().readCompletedIds();
    if (!section.modules.every((m) => done.contains(m.id))) return;

    final badgeId = badgeIdForSection(
      formationId: loc.formationId,
      sectionId: loc.sectionId,
    );
    try {
      await _users.addBadge(uid, badgeId);
    } catch (_) {}
  }
}
