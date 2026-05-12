import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:eskolia/data/repositories/user_repository.dart';
import 'package:eskolia/features/notifications/data/notification_repository.dart';
import 'package:eskolia/features/profil/data/profile_repository.dart';

/// Modèle produit (règles métier) — pas encore extrait dans `lib/`.
class UserProfile {
  UserProfile({required this.totalXP});

  final int totalXP;

  int get level => totalXP ~/ 500;

  String get rank {
    if (totalXP >= 10000) return 'Diamant';
    if (totalXP >= 6000) return 'Platine';
    if (totalXP >= 3000) return 'Or';
    if (totalXP >= 1500) return 'Argent';
    if (totalXP >= 500) return 'Bronze';
    return 'Bronze';
  }
}

void main() {
  late FakeFirebaseFirestore fakeFs;

  setUp(() {
    fakeFs = FakeFirebaseFirestore();
  });

  group('NotificationRepository (mock invité, uid vide)', () {
    test('le flux mock contient 8 notifications', () async {
      final repo = NotificationRepository(db: fakeFs);
      final list = await repo.watchNotifications('').first;
      expect(list.length, 8);
    });

    test('unreadCount vaut 4 (quatre non lues dans le mock)', () async {
      final repo = NotificationRepository(db: fakeFs);
      await repo.watchNotifications('').first;
      expect(repo.unreadCount, 4);
    });

    test('markAllAsRead ramène unreadCount à 0', () async {
      final repo = NotificationRepository(db: fakeFs);
      await repo.watchNotifications('').first;
      expect(repo.unreadCount, 4);
      await repo.markAllAsRead('');
      expect(repo.unreadCount, 0);
    });
  });

  group('UserProfile (règles niveau / rang)', () {
    test('level == totalXP ~/ 500', () {
      expect(UserProfile(totalXP: 0).level, 0);
      expect(UserProfile(totalXP: 499).level, 0);
      expect(UserProfile(totalXP: 500).level, 1);
      expect(UserProfile(totalXP: 1249).level, 2);
    });

    test('seuils de rang : Bronze, Argent, Or, Platine, Diamant', () {
      expect(UserProfile(totalXP: 500).rank, 'Bronze');
      expect(UserProfile(totalXP: 1500).rank, 'Argent');
      expect(UserProfile(totalXP: 3000).rank, 'Or');
      expect(UserProfile(totalXP: 6000).rank, 'Platine');
      expect(UserProfile(totalXP: 10000).rank, 'Diamant');
    });
  });

  group('ProfileRepository', () {
    test('getProfile avec uid vide retourne le snapshot mock', () async {
      final repo = ProfileRepository(
        userRepo: UserRepository(db: fakeFs),
      );
      final p = await repo.getProfile('');
      expect(p.uid, 'mock');
      expect(p.username, isNotEmpty);
    });
  });
}
