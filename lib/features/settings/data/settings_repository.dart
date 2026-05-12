import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  const AppSettings({
    required this.notificationsEnabled,
    required this.soundEnabled,
    required this.vibrationEnabled,
    required this.darkModeForced,
    required this.language,
    required this.showStreak,
    required this.publicProfile,
    required this.dailyGoalMinutes,
  });

  final bool notificationsEnabled;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool darkModeForced;
  final String language;
  final bool showStreak;
  final bool publicProfile;
  final int dailyGoalMinutes;

  static AppSettings defaults() => const AppSettings(
        notificationsEnabled: true,
        soundEnabled: true,
        vibrationEnabled: true,
        darkModeForced: true,
        language: 'fr',
        showStreak: true,
        publicProfile: false,
        dailyGoalMinutes: 30,
      );

  AppSettings copyWith({
    bool? notificationsEnabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? darkModeForced,
    String? language,
    bool? showStreak,
    bool? publicProfile,
    int? dailyGoalMinutes,
  }) {
    return AppSettings(
      notificationsEnabled:
          notificationsEnabled ?? this.notificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      darkModeForced: darkModeForced ?? this.darkModeForced,
      language: language ?? this.language,
      showStreak: showStreak ?? this.showStreak,
      publicProfile: publicProfile ?? this.publicProfile,
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'darkModeForced': darkModeForced,
      'language': language,
      'showStreak': showStreak,
      'publicProfile': publicProfile,
      'dailyGoalMinutes': dailyGoalMinutes,
    };
  }

  factory AppSettings.fromFirestore(Map<String, dynamic> m) {
    final d = AppSettings.defaults();
    return AppSettings(
      notificationsEnabled:
          m['notificationsEnabled'] as bool? ?? d.notificationsEnabled,
      soundEnabled: m['soundEnabled'] as bool? ?? d.soundEnabled,
      vibrationEnabled:
          m['vibrationEnabled'] as bool? ?? d.vibrationEnabled,
      darkModeForced: m['darkModeForced'] as bool? ?? d.darkModeForced,
      language: m['language'] as String? ?? d.language,
      showStreak: m['showStreak'] as bool? ?? d.showStreak,
      publicProfile: m['publicProfile'] as bool? ?? d.publicProfile,
      dailyGoalMinutes:
          (m['dailyGoalMinutes'] as num?)?.toInt() ?? d.dailyGoalMinutes,
    );
  }
}

class SettingsRepository {
  SettingsRepository({
    FirebaseFirestore? db,
    FirebaseAuth? auth,
  })  : _db = db ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  static const _kNotif = 'eskolia_settings_notifications';
  static const _kSound = 'eskolia_settings_sound';
  static const _kVib = 'eskolia_settings_vibration';
  static const _kDark = 'eskolia_settings_dark_forced';
  static const _kLang = 'eskolia_settings_language';
  static const _kStreak = 'eskolia_settings_show_streak';
  static const _kPublic = 'eskolia_settings_public_profile';
  static const _kGoal = 'eskolia_settings_daily_goal';

  Future<AppSettings> loadSettings() async {
    final p = await SharedPreferences.getInstance();
    final goalRaw = p.getInt(_kGoal) ?? 30;
    var s = AppSettings(
      notificationsEnabled: p.getBool(_kNotif) ?? true,
      soundEnabled: p.getBool(_kSound) ?? true,
      vibrationEnabled: p.getBool(_kVib) ?? true,
      darkModeForced: p.getBool(_kDark) ?? true,
      language: p.getString(_kLang) ?? 'fr',
      showStreak: p.getBool(_kStreak) ?? true,
      publicProfile: p.getBool(_kPublic) ?? false,
      dailyGoalMinutes: _normalizeGoal(goalRaw),
    );

    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      try {
        final doc = await _db
            .collection('users')
            .doc(uid)
            .collection('settings')
            .doc('app')
            .get();
        if (doc.exists && doc.data() != null) {
          s = AppSettings.fromFirestore(doc.data()!);
          await _persistLocal(s);
        }
      } catch (_) {}
    }
    return s;
  }

  int _normalizeGoal(int v) {
    const opts = [15, 30, 45, 60];
    if (v <= 0 || !opts.contains(v)) return 30;
    return v;
  }

  Future<void> _persistLocal(AppSettings s) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kNotif, s.notificationsEnabled);
    await p.setBool(_kSound, s.soundEnabled);
    await p.setBool(_kVib, s.vibrationEnabled);
    await p.setBool(_kDark, s.darkModeForced);
    await p.setString(_kLang, s.language);
    await p.setBool(_kStreak, s.showStreak);
    await p.setBool(_kPublic, s.publicProfile);
    await p.setInt(_kGoal, s.dailyGoalMinutes);
  }

  Future<void> saveSettings(AppSettings settings) async {
    await _persistLocal(settings);
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      try {
        await _db
            .collection('users')
            .doc(uid)
            .collection('settings')
            .doc('app')
            .set(settings.toFirestore(), SetOptions(merge: true));
      } catch (_) {}
    }
  }

  Future<void> resetToDefaults() async {
    final d = AppSettings.defaults();
    await _persistLocal(d);
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      try {
        await _db
            .collection('users')
            .doc(uid)
            .collection('settings')
            .doc('app')
            .set(d.toFirestore());
      } catch (_) {}
    }
  }
}
