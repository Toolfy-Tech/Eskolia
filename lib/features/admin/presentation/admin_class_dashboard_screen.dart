import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/eskolia_tokens.dart';
import '../../../core/theme/eskolia_layout.dart';
import '../../../core/theme/eskolia_visual.dart';
import '../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../shared/widgets/eskolia_app_bar.dart';
import '../../../shared/widgets/eskolia_shell_body.dart';
import '../../../shared/widgets/eskolia_card.dart';
import '../../auth/data/user_model.dart';
import 'staff_gate_scaffold.dart';

class AdminClassDashboardScreen extends StatefulWidget {
  const AdminClassDashboardScreen({super.key});

  @override
  State<AdminClassDashboardScreen> createState() => _AdminClassDashboardScreenState();
}

class _AdminClassDashboardScreenState extends State<AdminClassDashboardScreen> {
  final _db = FirebaseFirestore.instance;
  String _search = '';
  _SortField _sort = _SortField.xp;

  Stream<List<UserModel>> _watchUsers() {
    return _db.collection('users').snapshots().map(
      (snap) => snap.docs.map((d) => UserModel.fromFirestore(d)).toList(),
    );
  }

  List<UserModel> _filter(List<UserModel> all) {
    var list = all.where((u) => u.role != 'admin').toList();
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      list = list.where((u) =>
          u.username.toLowerCase().contains(q) ||
          u.email.toLowerCase().contains(q)).toList();
    }
    switch (_sort) {
      case _SortField.xp:
        list.sort((a, b) => b.xp.compareTo(a.xp));
      case _SortField.streak:
        list.sort((a, b) => b.streak.compareTo(a.streak));
      case _SortField.quizzes:
        list.sort((a, b) => b.totalQuizzesPlayed.compareTo(a.totalQuizzesPlayed));
      case _SortField.lastLogin:
        list.sort((a, b) {
          if (a.lastLogin == null && b.lastLogin == null) return 0;
          if (a.lastLogin == null) return 1;
          if (b.lastLogin == null) return -1;
          return b.lastLogin!.compareTo(a.lastLogin!);
        });
    }
    return list;
  }

  String _lastSeen(DateTime? t) {
    if (t == null) return 'Jamais';
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours} h';
    if (diff.inDays == 1) return 'Hier';
    return 'Il y a ${diff.inDays} j';
  }

  @override
  Widget build(BuildContext context) {
    return StaffGateScaffold(
      title: 'Vue classe',
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        appBar: EskoliaAppBar.standard(context, title: 'Vue classe'),
        body: Stack(
          children: [
            const EskoliaAmbientBackground(),
            EskoliaShellBody(
              safeAreaTop: false,
              child: Column(
                children: [
                  _buildControls(),
                  Expanded(
                    child: StreamBuilder<List<UserModel>>(
                      stream: _watchUsers(),
                      builder: (context, snap) {
                        if (snap.hasError) {
                          return Center(
                            child: Text(
                              'Erreur de chargement.',
                              style: TextStyle(color: EskoliaTokens.textSecondary),
                            ),
                          );
                        }
                        if (!snap.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        final users = _filter(snap.data!);
                        if (users.isEmpty) {
                          return _empty();
                        }
                        return _buildList(users);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        EskoliaLayout.screenPaddingH, 12, EskoliaLayout.screenPaddingH, 8,
      ),
      child: Column(
        children: [
          TextField(
            onChanged: (v) => setState(() => _search = v),
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Rechercher un élève...',
              hintStyle: TextStyle(color: EskoliaTokens.textSecondary.withValues(alpha: 0.6)),
              prefixIcon: Icon(Icons.search_rounded, color: EskoliaTokens.textSecondary, size: 20),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.05),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: EskoliaTokens.violetSoft.withValues(alpha: 0.5)),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _SortField.values.map((f) {
                final active = _sort == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _sort = f),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: active ? EskoliaTokens.violetSoft.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: active ? EskoliaTokens.violetSoft.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Text(
                        f.label,
                        style: TextStyle(
                          color: active ? EskoliaTokens.violetSoft : EskoliaTokens.textSecondary,
                          fontSize: 12,
                          fontWeight: active ? FontWeight.w700 : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<UserModel> users) {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
        EskoliaLayout.screenPaddingH, 4, EskoliaLayout.screenPaddingH, EskoliaLayout.screenPaddingBottom,
      ),
      itemCount: users.length,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: _UserRow(user: users[i], rank: i + 1, lastSeen: _lastSeen(users[i].lastLogin)),
      ),
    );
  }

  Widget _empty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('\u{1F465}', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(
            'Aucun élève trouvé.',
            style: TextStyle(color: EskoliaTokens.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

enum _SortField {
  xp('XP'),
  streak('Série 🔥'),
  quizzes('Quiz'),
  lastLogin('Dernière activité');

  const _SortField(this.label);
  final String label;
}

class _UserRow extends StatelessWidget {
  const _UserRow({required this.user, required this.rank, required this.lastSeen});

  final UserModel user;
  final int rank;
  final String lastSeen;

  @override
  Widget build(BuildContext context) {
    final initial = user.username.isNotEmpty ? user.username[0].toUpperCase() : '?';
    final isActive = user.isStreakActive;

    return EskoliaCardContent(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: EskoliaTokens.violetSoft.withValues(alpha: 0.2),
                child: Text(initial, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              if (isActive)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: EskoliaTokens.success,
                      shape: BoxShape.circle,
                      border: Border.all(color: EskoliaTokens.bgBase, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.username.isEmpty ? user.email : user.username,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  lastSeen,
                  style: TextStyle(color: EskoliaTokens.textSecondary.withValues(alpha: 0.7), fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _Stat(value: '${user.xp}', label: 'XP', color: EskoliaTokens.violetSoft),
          const SizedBox(width: 10),
          _Stat(value: '${user.streak}\u{1F525}', label: 'Série', color: EskoliaTokens.orange),
          const SizedBox(width: 10),
          _Stat(value: '${user.totalQuizzesPlayed}', label: 'Quiz', color: EskoliaTokens.cyan),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, required this.color});
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 13)),
        Text(label, style: TextStyle(color: EskoliaTokens.textSecondary.withValues(alpha: 0.65), fontSize: 10)),
      ],
    );
  }
}
