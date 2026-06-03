import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/eskolia_layout.dart';
import '../../../core/theme/eskolia_visual.dart';
import '../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../shared/widgets/eskolia_shell_body.dart';
import '../../../shared/widgets/eskolia_app_bar.dart';
import '../data/notification_repository.dart';

const Color _bg = EskoliaVisual.bgDeep;
const Color _cyan = Color(0xFF00BCD4);
const Color _violet = Color(0xFF6C63FF);
const Color _slate = Color(0xFF94A3B8);
const Color _slateLight = Color(0xFF94A3B8);
const Color _surface = Color(0xFF1E293B);
const Color _redBadge = Color(0xFFE53935);

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  final NotificationRepository _repo = NotificationRepository();
  late AnimationController _pulse;
  int _retry = 0;

  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  String _dateBucket(DateTime t) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(t.year, t.month, t.day);
    final diff = today.difference(d).inDays;
    if (diff == 0) return 'Aujourd\'hui';
    if (diff == 1) return 'Hier';
    if (diff >= 2 && diff < 7) return 'Cette semaine';
    return 'Plus tôt';
  }

  String _relativeTime(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 1) return 'À l\'instant';
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours} h';
    if (diff.inDays == 1) return 'Hier';
    return 'Il y a ${diff.inDays} j';
  }

  Map<String, List<AppNotification>> _group(List<AppNotification> list) {
    final sorted = List<AppNotification>.from(list)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final map = <String, List<AppNotification>>{};
    for (final n in sorted) {
      final k = _dateBucket(n.createdAt);
      map.putIfAbsent(k, () => []).add(n);
    }
    const order = ['Aujourd\'hui', 'Hier', 'Cette semaine', 'Plus tôt'];
    final out = <String, List<AppNotification>>{};
    for (final key in order) {
      if (map.containsKey(key)) out[key] = map[key]!;
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: EskoliaAppBar.standard(
        context,
        title: '\u{1F514} Notifications',
        actions: [
          StreamBuilder<List<AppNotification>>(
            stream: _repo.watchNotifications(_uid),
            builder: (context, snap) {
              final list = snap.data ?? [];
              final unread = list.where((n) => !n.isRead).length;
              if (unread == 0) return const SizedBox.shrink();
              return TextButton(
                onPressed: () => _repo.markAllAsRead(_uid),
                child: const Text(
                  'Tout lire',
                  style: TextStyle(color: _cyan),
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          const EskoliaAmbientBackground(),
          EskoliaShellBody(
            safeAreaTop: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: StreamBuilder<List<AppNotification>>(
                    key: ValueKey(_retry),
                    stream: _repo.watchNotifications(_uid),
                    builder: (context, snap) {
                      if (snap.hasError) {
                        return _buildError(snap.error.toString());
                      }
                      if (snap.connectionState == ConnectionState.waiting &&
                          !snap.hasData) {
                        return _skeleton();
                      }
                      final list = snap.data ?? [];
                      if (list.isEmpty) {
                        return _empty();
                      }
                      final unread =
                          list.where((n) => !n.isRead).length;
                      final groups = _group(list);
                      final children = <Widget>[];
                      var index = 0;
                      if (unread > 0) {
                        children.add(
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _redBadge.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color:
                                        _redBadge.withValues(alpha: 0.5),
                                  ),
                                ),
                                child: Text(
                                  '$unread non lues',
                                  style: const TextStyle(
                                    color: _redBadge,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                      for (final e in groups.entries) {
                        children.add(
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8, top: 8),
                            child: Text(
                              e.key,
                              style: TextStyle(
                                color: _slateLight.withValues(alpha: 0.9),
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        );
                        for (final n in e.value) {
                          children.add(
                            _NotificationDismissTile(
                              repo: _repo,
                              uid: _uid,
                              notification: n,
                              index: index,
                              relative: _relativeTime(n.createdAt),
                              onTap: () async {
                                await _repo.markAsRead(_uid, n.id);
                                if (!context.mounted) return;
                                if (n.actionRoute != null &&
                                    n.actionRoute!.isNotEmpty) {
                                  context.push(n.actionRoute!);
                                }
                              },
                            ),
                          );
                          index++;
                        }
                      }
                      return ListView(
                        padding: const EdgeInsets.fromLTRB(
                          EskoliaLayout.screenPaddingH,
                          8,
                          EskoliaLayout.screenPaddingH,
                          EskoliaLayout.screenPaddingBottom,
                        ),
                        children: children,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _skeleton() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: List.generate(
        4,
        (i) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AnimatedBuilder(
            animation: _pulse,
            builder: (context, child) {
              final c =
                  Color.lerp(_surface, const Color(0xFF2D3748), _pulse.value)!;
              return Container(
                height: 88,
                decoration: BoxDecoration(
                  color: c,
                  borderRadius: BorderRadius.circular(16),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _empty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('\u{1F515}', style: TextStyle(fontSize: 52)),
          const SizedBox(height: 16),
          const Text(
            'Tout est calme ici',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tu recevras des alertes pour les défis,\nles badges et les invitations multijoueur.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _slate.withValues(alpha: 0.85),
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String msg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('\u{26A0}\u{FE0F}', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 8),
            Text(
              msg,
              textAlign: TextAlign.center,
              style: TextStyle(color: _slateLight),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => setState(() => _retry++),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationDismissTile extends StatelessWidget {
  const _NotificationDismissTile({
    required this.repo,
    required this.uid,
    required this.notification,
    required this.index,
    required this.relative,
    required this.onTap,
  });

  final NotificationRepository repo;
  final String uid;
  final AppNotification notification;
  final int index;
  final String relative;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final n = notification;
    final read = n.isRead;

    return Dismissible(
      key: ValueKey<String>(n.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => repo.deleteNotification(uid, n.id),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            splashColor: _violet.withValues(alpha: 0.15),
            child: Container(
              decoration: BoxDecoration(
                color: read
                    ? Colors.transparent
                    : _violet.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!read)
                    Container(
                      width: 4,
                      decoration: const BoxDecoration(
                        color: _violet,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          bottomLeft: Radius.circular(16),
                        ),
                      ),
                    ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Opacity(
                        opacity: read ? 0.6 : 1,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.08),
                              ),
                              child: Text(
                                n.emoji,
                                style: const TextStyle(fontSize: 22),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    n.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    n.body,
                                    style: TextStyle(
                                      color: _slateLight
                                          .withValues(alpha: 0.95),
                                      fontSize: 13,
                                      height: 1.35,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    relative,
                                    style: TextStyle(
                                      color: _slate
                                          .withValues(alpha: 0.85),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 280.ms, delay: (index * 50).ms)
        .slideX(begin: 0.03, duration: 280.ms, delay: (index * 50).ms);
  }
}
