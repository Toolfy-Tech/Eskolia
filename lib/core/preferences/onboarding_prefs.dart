import 'package:shared_preferences/shared_preferences.dart';

/// Onboarding 3 slides — `blueprint v3.md` § Auth & onboarding.
abstract final class OnboardingPrefs {
  OnboardingPrefs._();

  static const _key = 'eskolia_onboarding_v3_done';

  /// `true` par défaut si jamais défini : utilisateurs existants ne repassent pas par les slides.
  static Future<bool> isCompleted() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_key) ?? true;
  }

  static Future<void> markCompleted() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_key, true);
  }

  /// Après inscription : forcer l’affichage de l’onboarding.
  static Future<void> requireForNewUser() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_key, false);
  }
}
