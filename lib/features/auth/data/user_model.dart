import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  const UserModel({
    required this.uid,
    required this.username,
    required this.email,
    this.interestSections = const [],
    required this.level,
    required this.xp,
    required this.xpThisWeek,
    required this.streak,
    required this.currentChapter,
    required this.currentModule,
    required this.totalQuizzesPlayed,
    required this.totalWins,
    this.battleWins = 0,
    this.quizzesThisWeek = 0,
    this.tpMissionsThisWeek = 0,
    required this.badges,
    this.lastLogin,
    required this.createdAt,
    this.role = 'user',
  });

  final String uid;
  final String username;
  final String email;
  /// Sections TIP choisies à l’inscription (ex. S01, S02).
  final List<String> interestSections;
  final int level;
  final int xp;
  final int xpThisWeek;
  final int streak;
  final int currentChapter;
  final int currentModule;
  final int totalQuizzesPlayed;
  final int totalWins;
  /// Victoires en duel multijoueur (champ `battleWins` sur `users/{uid}`).
  final int battleWins;
  final int quizzesThisWeek;
  final int tpMissionsThisWeek;
  final List<String> badges;
  final DateTime? lastLogin;
  final DateTime createdAt;
  /// `user` | `moderator` | `admin` — défini dans Firestore (ou bootstrap email).
  final String role;

  bool get isStaff => role == 'admin' || role == 'moderator';

  int get levelFromXp => (xp ~/ 1000) + 1;

  int get xpToNextLevel => (levelFromXp * 1000) - xp;

  double get xpProgress => (xp % 1000) / 1000.0;

  String get displayLevel => 'Niveau $levelFromXp';

  bool get isStreakActive {
    if (lastLogin == null) return false;
    final now = DateTime.now();
    final d = DateTime(lastLogin!.year, lastLogin!.month, lastLogin!.day);
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    return d == today || d == yesterday;
  }

  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final xpVal = (data['xp'] as num?)?.toInt() ?? 0;
    return UserModel(
      uid: doc.id,
      username: data['username'] as String? ?? '',
      email: data['email'] as String? ?? '',
      interestSections: _stringList(data['interestSections']),
      level: (data['level'] as num?)?.toInt() ?? ((xpVal ~/ 1000) + 1),
      xp: xpVal,
      xpThisWeek: (data['xpThisWeek'] as num?)?.toInt() ?? 0,
      streak: (data['streak'] as num?)?.toInt() ?? 0,
      currentChapter: (data['currentChapter'] as num?)?.toInt() ?? 0,
      currentModule: (data['currentModule'] as num?)?.toInt() ?? 0,
      totalQuizzesPlayed: (data['totalQuizzesPlayed'] as num?)?.toInt() ?? 0,
      totalWins: (data['totalWins'] as num?)?.toInt() ?? 0,
      battleWins: (data['battleWins'] as num?)?.toInt() ?? 0,
      quizzesThisWeek: (data['quizzesThisWeek'] as num?)?.toInt() ?? 0,
      tpMissionsThisWeek: (data['tpMissionsThisWeek'] as num?)?.toInt() ?? 0,
      badges: _stringList(data['badges']),
      lastLogin: _tsToDate(data['lastLogin']),
      createdAt: _tsToDate(data['createdAt']) ?? DateTime.fromMillisecondsSinceEpoch(0),
      role: (data['role'] as String?)?.trim().isNotEmpty == true
          ? (data['role'] as String).trim()
          : 'user',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'username': username,
      'email': email,
      'interestSections': interestSections,
      'level': level,
      'xp': xp,
      'xpThisWeek': xpThisWeek,
      'streak': streak,
      'currentChapter': currentChapter,
      'currentModule': currentModule,
      'totalQuizzesPlayed': totalQuizzesPlayed,
      'totalWins': totalWins,
      'battleWins': battleWins,
      'quizzesThisWeek': quizzesThisWeek,
      'tpMissionsThisWeek': tpMissionsThisWeek,
      'badges': badges,
      if (lastLogin != null) 'lastLogin': Timestamp.fromDate(lastLogin!),
      'createdAt': Timestamp.fromDate(createdAt),
      'role': role,
    };
  }

  UserModel copyWith({
    String? uid,
    String? username,
    String? email,
    List<String>? interestSections,
    int? level,
    int? xp,
    int? xpThisWeek,
    int? streak,
    int? currentChapter,
    int? currentModule,
    int? totalQuizzesPlayed,
    int? totalWins,
    int? battleWins,
    int? quizzesThisWeek,
    int? tpMissionsThisWeek,
    List<String>? badges,
    DateTime? lastLogin,
    bool clearLastLogin = false,
    DateTime? createdAt,
    String? role,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      username: username ?? this.username,
      email: email ?? this.email,
      interestSections: interestSections ?? this.interestSections,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      xpThisWeek: xpThisWeek ?? this.xpThisWeek,
      streak: streak ?? this.streak,
      currentChapter: currentChapter ?? this.currentChapter,
      currentModule: currentModule ?? this.currentModule,
      totalQuizzesPlayed: totalQuizzesPlayed ?? this.totalQuizzesPlayed,
      totalWins: totalWins ?? this.totalWins,
      battleWins: battleWins ?? this.battleWins,
      quizzesThisWeek: quizzesThisWeek ?? this.quizzesThisWeek,
      tpMissionsThisWeek: tpMissionsThisWeek ?? this.tpMissionsThisWeek,
      badges: badges ?? this.badges,
      lastLogin: clearLastLogin ? null : (lastLogin ?? this.lastLogin),
      createdAt: createdAt ?? this.createdAt,
      role: role ?? this.role,
    );
  }

  static List<String> _stringList(dynamic raw) {
    if (raw is! List) return [];
    return raw.map((e) => e.toString()).toList();
  }

  static DateTime? _tsToDate(dynamic v) {
    if (v is Timestamp) return v.toDate();
    return null;
  }
}
