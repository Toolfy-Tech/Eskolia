import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:eskolia/features/settings/data/settings_repository.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('loadSettings retourne les valeurs par défaut attendues', () async {
    final repo = SettingsRepository(
      db: FakeFirebaseFirestore(),
      auth: MockFirebaseAuth(),
    );
    final s = await repo.loadSettings();
    expect(s.notificationsEnabled, true);
    expect(s.language, 'fr');
    expect(s.dailyGoalMinutes, 30);
  });

  test('saveSettings puis loadSettings retrouve les valeurs', () async {
    final repo = SettingsRepository(
      db: FakeFirebaseFirestore(),
      auth: MockFirebaseAuth(),
    );
    final custom = (await repo.loadSettings()).copyWith(
      notificationsEnabled: false,
      language: 'en',
      dailyGoalMinutes: 45,
    );
    await repo.saveSettings(custom);

    final repo2 = SettingsRepository(
      db: FakeFirebaseFirestore(),
      auth: MockFirebaseAuth(),
    );
    final loaded = await repo2.loadSettings();
    expect(loaded.notificationsEnabled, false);
    expect(loaded.language, 'en');
    expect(loaded.dailyGoalMinutes, 45);
  });

  test('resetToDefaults réapplique les valeurs d’origine', () async {
    final repo = SettingsRepository(
      db: FakeFirebaseFirestore(),
      auth: MockFirebaseAuth(),
    );
    await repo.saveSettings(
      (await repo.loadSettings()).copyWith(
        notificationsEnabled: false,
        language: 'en',
        dailyGoalMinutes: 60,
      ),
    );
    await repo.resetToDefaults();

    final repo2 = SettingsRepository(
      db: FakeFirebaseFirestore(),
      auth: MockFirebaseAuth(),
    );
    final s = await repo2.loadSettings();
    expect(s.notificationsEnabled, true);
    expect(s.language, 'fr');
    expect(s.dailyGoalMinutes, 30);
  });
}
