import '../../auth/data/user_model.dart';
import '../../../data/repositories/user_repository.dart';

class ProfileSnapshot {
  const ProfileSnapshot({
    required this.uid,
    required this.level,
    required this.xp,
    required this.streak,
    required this.xpThisWeek,
    required this.username,
    required this.totalQuizzesPlayed,
    required this.totalWins,
    required this.battleWins,
    this.quizzesThisWeek = 0,
    this.tpMissionsThisWeek = 0,
    this.badges = const [],
    this.activeDays = const [],
  });

  final String uid;
  final int level;
  final int xp;
  final int streak;
  final int xpThisWeek;
  final String username;
  final int totalQuizzesPlayed;
  final int totalWins;
  final int battleWins;
  final int quizzesThisWeek;
  final int tpMissionsThisWeek;
  /// Badges profil (Firestore `badges`).
  final List<String> badges;
  /// Jours d'activité YYYYMMDD pour le calendrier de série.
  final List<int> activeDays;

  factory ProfileSnapshot.fromUser(UserModel u) {
    return ProfileSnapshot(
      uid: u.uid,
      level: u.levelFromXp,
      xp: u.xp,
      streak: u.streak,
      xpThisWeek: u.xpThisWeek,
      username: u.username,
      totalQuizzesPlayed: u.totalQuizzesPlayed,
      totalWins: u.totalWins,
      battleWins: u.battleWins,
      quizzesThisWeek: u.quizzesThisWeek,
      tpMissionsThisWeek: u.tpMissionsThisWeek,
      badges: List<String>.from(u.badges),
      activeDays: List<int>.from(u.activeDays),
    );
  }

  factory ProfileSnapshot.mock() {
    return const ProfileSnapshot(
      uid: 'mock',
      level: 5,
      xp: 4200,
      streak: 4,
      xpThisWeek: 120,
      username: 'Élève',
      totalQuizzesPlayed: 12,
      totalWins: 8,
      battleWins: 3,
    );
  }
}

class ProfileRepository {
  ProfileRepository({UserRepository? userRepo})
      : _userRepo = userRepo ?? UserRepository();

  final UserRepository _userRepo;

  Future<ProfileSnapshot> getProfile(String uid) async {
    if (uid.isEmpty) return ProfileSnapshot.mock();
    try {
      final u = await _userRepo.getUserById(uid);
      if (u != null) return ProfileSnapshot.fromUser(u);
    } catch (_) {}
    return ProfileSnapshot.mock();
  }
}
