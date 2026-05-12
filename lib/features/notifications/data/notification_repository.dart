import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType { quiz, battle, badge, streak, system }

class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.emoji,
    required this.isRead,
    required this.createdAt,
    this.actionRoute,
  });

  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final String emoji;
  final bool isRead;
  final DateTime createdAt;
  final String? actionRoute;

  AppNotification copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? body,
    String? emoji,
    bool? isRead,
    DateTime? createdAt,
    String? actionRoute,
    bool clearActionRoute = false,
  }) {
    return AppNotification(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      emoji: emoji ?? this.emoji,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      actionRoute:
          clearActionRoute ? null : (actionRoute ?? this.actionRoute),
    );
  }
}

class NotificationRepository {
  NotificationRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  List<AppNotification>? _lastEmitted;

  /// Dérivé du dernier élément émis par [watchNotifications].
  int get unreadCount =>
      _lastEmitted?.where((n) => !n.isRead).length ?? 0;

  static List<AppNotification> _buildMock() {
    final now = DateTime.now();
    return [
      AppNotification(
        id: 'mock_1',
        type: NotificationType.quiz,
        title: 'Quiz terminé',
        body: 'Tu as eu 4/5 au quiz réseau (exemple).',
        emoji: '\u{1F3AF}',
        isRead: false,
        createdAt: now.subtract(const Duration(minutes: 12)),
        actionRoute: '/quiz/daily',
      ),
      AppNotification(
        id: 'mock_2',
        type: NotificationType.battle,
        title: 'Battle gagnée !',
        body: 'Victoire sur un duel (exemple).',
        emoji: '\u{2694}\u{FE0F}',
        isRead: false,
        createdAt: now.subtract(const Duration(hours: 1)),
        actionRoute: '/lobbys',
      ),
      AppNotification(
        id: 'mock_3',
        type: NotificationType.badge,
        title: 'Badge débloqué',
        body: 'Tu as obtenu \'Guerrier\' !',
        emoji: '\u{1F3C6}',
        isRead: false,
        createdAt: now.subtract(const Duration(hours: 3)),
        actionRoute: '/profil',
      ),
      AppNotification(
        id: 'mock_4',
        type: NotificationType.streak,
        title: 'Série en danger !',
        body: 'Connecte-toi pour garder ta série de 4j',
        emoji: '\u{1F525}',
        isRead: false,
        createdAt: now.subtract(const Duration(hours: 5)),
        actionRoute: '/home',
      ),
      AppNotification(
        id: 'mock_5',
        type: NotificationType.system,
        title: 'Nouveau parcours',
        body: 'Nouveau module disponible sur la formation TIP (Technicien informatique de proximité) — parcours Optimus.',
        emoji: '\u{1F4DA}',
        isRead: true,
        createdAt: now.subtract(const Duration(days: 1, hours: 2)),
        actionRoute: '/parcours',
      ),
      AppNotification(
        id: 'mock_6',
        type: NotificationType.battle,
        title: 'Défi reçu',
        body: 'Un coéquipier t\'invite sur un lobby (exemple).',
        emoji: '\u{2694}\u{FE0F}',
        isRead: true,
        createdAt: now.subtract(const Duration(days: 1, hours: 8)),
        actionRoute: '/lobbys',
      ),
      AppNotification(
        id: 'mock_7',
        type: NotificationType.system,
        title: 'Objectif atteint',
        body: '50 XP gagnés aujourd\'hui !',
        emoji: '\u{1F31F}',
        isRead: true,
        createdAt: now.subtract(const Duration(days: 2)),
        actionRoute: '/home',
      ),
      AppNotification(
        id: 'mock_8',
        type: NotificationType.quiz,
        title: 'Rappel',
        body: 'Tu n\'as pas fait de quiz aujourd\'hui',
        emoji: '\u{1F3AF}',
        isRead: true,
        createdAt: now.subtract(const Duration(days: 3)),
        actionRoute: '/quiz/daily',
      ),
    ];
  }

  final List<AppNotification> _guestMock = List<AppNotification>.from(
    _buildMock(),
    growable: true,
  );

  final StreamController<List<AppNotification>> _guestStream =
      StreamController<List<AppNotification>>.broadcast();

  Stream<List<AppNotification>> watchNotifications(String uid) {
    if (uid.isEmpty) {
      final initial = List<AppNotification>.from(_guestMock);
      _lastEmitted = initial;
      scheduleMicrotask(() {
        if (!_guestStream.isClosed) _guestStream.add(initial);
      });
      return _guestStream.stream.map((list) {
        _lastEmitted = list;
        return list;
      });
    }

    return _db
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) {
          try {
            return snap.docs.map(_fromDoc).toList();
          } catch (_) {
            return List<AppNotification>.from(_guestMock);
          }
        })
        .transform(
          StreamTransformer<List<AppNotification>,
              List<AppNotification>>.fromHandlers(
            handleData: (data, sink) {
              _lastEmitted = data;
              sink.add(data);
            },
            handleError: (_, __, sink) {
              final fallback = List<AppNotification>.from(_guestMock);
              _lastEmitted = fallback;
              sink.add(fallback);
            },
          ),
        );
  }

  void _emitGuest() {
    final copy = List<AppNotification>.from(_guestMock);
    _lastEmitted = copy;
    if (!_guestStream.isClosed) _guestStream.add(copy);
  }

  AppNotification _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data();
    return AppNotification(
      id: d.id,
      type: _parseType(m['type'] as String?),
      title: m['title'] as String? ?? '',
      body: m['body'] as String? ?? '',
      emoji: m['emoji'] as String? ?? '\u{1F514}',
      isRead: m['isRead'] as bool? ?? false,
      createdAt: _ts(m['createdAt']) ?? DateTime.now(),
      actionRoute: m['actionRoute'] as String?,
    );
  }

  DateTime? _ts(dynamic v) {
    if (v is Timestamp) return v.toDate();
    return null;
  }

  NotificationType _parseType(String? s) {
    switch (s) {
      case 'battle':
        return NotificationType.battle;
      case 'badge':
        return NotificationType.badge;
      case 'streak':
        return NotificationType.streak;
      case 'system':
        return NotificationType.system;
      case 'quiz':
      default:
        return NotificationType.quiz;
    }
  }

  Future<void> markAsRead(String uid, String notificationId) async {
    if (uid.isEmpty) {
      final i = _guestMock.indexWhere((e) => e.id == notificationId);
      if (i >= 0) {
        _guestMock[i] = _guestMock[i].copyWith(isRead: true);
        _emitGuest();
      }
      return;
    }
    await _db
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .doc(notificationId)
        .set({'isRead': true}, SetOptions(merge: true));
  }

  Future<void> markAllAsRead(String uid) async {
    if (uid.isEmpty) {
      for (var i = 0; i < _guestMock.length; i++) {
        _guestMock[i] = _guestMock[i].copyWith(isRead: true);
      }
      _emitGuest();
      return;
    }
    final batch = _db.batch();
    final snap = await _db
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .get();
    for (final d in snap.docs) {
      batch.update(d.reference, {'isRead': true});
    }
    await batch.commit();
  }

  Future<void> deleteNotification(String uid, String notificationId) async {
    if (uid.isEmpty) {
      _guestMock.removeWhere((e) => e.id == notificationId);
      _emitGuest();
      return;
    }
    await _db
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .doc(notificationId)
        .delete();
  }
}
