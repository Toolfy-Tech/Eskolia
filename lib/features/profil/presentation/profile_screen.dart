import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/eskolia_layout.dart';
import '../../../core/theme/eskolia_visual.dart';
import '../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../shared/widgets/eskolia_shell_body.dart';
import '../../../shared/widgets/eskolia_app_bar.dart';
import '../../../shared/widgets/gradient_border_card.dart';
import '../../ai/data/ai_key_repository.dart';
import '../../auth/data/auth_repository.dart';
import '../../economy/data/badge_catalog.dart';
import '../../parcours/data/parcours_repository.dart';
import '../../parcours/data/tip_progress_repository.dart';
import '../../quiz/services/revision_pool_repository.dart';
import '../data/profile_repository.dart';

const Color _bg = EskoliaVisual.bgDeep;
const Color _violet = Color(0xFF6C63FF);
const Color _cyan = Color(0xFF00BCD4);
const Color _slate = Color(0xFF94A3B8);
const Color _amber = Color(0xFFFFC107);
const Color _red = Color(0xFFEF4444);
const Color _green = Color(0xFF43E97B);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.uid = ''});

  final String uid;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _repo = ProfileRepository();
  late Future<ProfileSnapshot> _future;
  late Future<({int optimusCompleted, int totalChapters, int poolPins})> _learningFuture;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    final selfUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final effectiveUid = widget.uid.isNotEmpty ? widget.uid : selfUid;
    _future = _repo.getProfile(effectiveUid);
    _learningFuture = _loadLearningSnapshot();
  }

  Future<({int optimusCompleted, int totalChapters, int poolPins})> _loadLearningSnapshot() async {
    final done = await OptimusProgressRepository().readCompletedIds();
    final parcoursDone = done.where((id) => id.startsWith('optimus_')).length;
    final catalogCount = ParcoursRepository.moduleCatalog.keys
        .where((k) => k.startsWith('optimus_'))
        .length;
    final totalChapters = catalogCount > 0 ? catalogCount : 23;
    final pool = await RevisionPoolRepository().readEntries();
    return (optimusCompleted: parcoursDone, totalChapters: totalChapters, poolPins: pool.length);
  }

  Future<void> _signOut() async {
    await AuthRepository().signOut();
    if (!mounted) return;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: EskoliaAppBar.standard(context, title: 'Moi', showBack: false),
      body: Stack(
        children: [
          const EskoliaAmbientBackground(),
          EskoliaShellBody(
            safeAreaTop: false,
            child: FutureBuilder<ProfileSnapshot>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: _violet));
                }
                if (snap.hasError) {
                  return _buildErrorState(snap.error.toString());
                }
                final p = snap.data!;
                final selfUid = FirebaseAuth.instance.currentUser?.uid ?? '';
                final effectiveUid = widget.uid.isNotEmpty ? widget.uid : selfUid;
                final isSelf = selfUid.isNotEmpty && effectiveUid == selfUid;

                return ListView(
                  padding: const EdgeInsets.fromLTRB(
                    EskoliaLayout.screenPaddingH,
                    8,
                    EskoliaLayout.screenPaddingH,
                    120,
                  ),
                  children: [
                    _buildHeaderCard(p),
                    const SizedBox(height: 20),
                    _buildMetricsGrid(p),
                    const SizedBox(height: 20),
                    _buildStreakCalendar(p),
                    const SizedBox(height: 24),
                    _buildParcoursProgressSection(),
                    const SizedBox(height: 24),
                    _buildWeeklySection(p),
                    const SizedBox(height: 24),
                    _buildBadgesSection(p),
                    const SizedBox(height: 24),
                    _buildExplorerSection(context),
                    if (isSelf) ...[
                      const SizedBox(height: 32),
                      _buildLogoutButton(),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(ProfileSnapshot p) {
    final initial = p.username.isNotEmpty ? p.username[0].toUpperCase() : '?';
    final levelProgress = (p.xp % 1000) / 1000.0;

    return GradientBorderCard(
      gradientColors: EskoliaVisual.borderPrimary,
      glowColor: _violet,
      borderRadius: 22,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          StreamBuilder<AiConnectionState>(
            stream: AiKeyRepository().watch(),
            builder: (context, snap) {
              final aiConnected = snap.data?.isConnected ?? false;
              return Stack(
                alignment: Alignment.topRight,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: _violet.withValues(alpha: 0.2),
                    child: Text(initial, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                  ),
                  if (aiConnected)
                    Positioned(
                      right: 2,
                      top: 2,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50),
                          shape: BoxShape.circle,
                          border: Border.all(color: _bg, width: 2.5),
                        ),
                        child: const Icon(Icons.psychology_rounded, size: 11, color: Colors.white),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          Text(p.username, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Niveau ${p.level}', style: const TextStyle(color: _amber, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Text('${p.xp} XP', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: levelProgress,
              backgroundColor: Colors.white10,
              color: _violet,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(ProfileSnapshot p) {
    final showVictories = p.battleWins > 0 || p.totalWins > 0;
    final streakValue = p.streak >= 1 ? '${p.streak} 🔥' : '0';

    return Row(
      children: [
        Expanded(child: _MetricCard(label: 'Série', value: streakValue, color: Colors.orange)),
        const SizedBox(width: 10),
        Expanded(child: _MetricCard(label: 'Quiz', value: '${p.totalQuizzesPlayed}', color: _cyan)),
        const SizedBox(width: 10),
        Expanded(
          child: showVictories
              ? _MetricCard(label: 'Victoires', value: '${p.battleWins}', color: _green)
              : _MetricCard(label: 'Multi joués', value: '${p.totalWins}', color: _green),
        ),
      ],
    );
  }

  Widget _buildStreakCalendar(ProfileSnapshot p) {
    final activeDaySet = p.activeDays.toSet();
    final now = DateTime.now();
    final todayInt = now.year * 10000 + now.month * 100 + now.day;

    const days = 28;
    final slots = List.generate(days, (i) {
      final d = now.subtract(Duration(days: days - 1 - i));
      final dayInt = d.year * 10000 + d.month * 100 + d.day;
      final isActive = activeDaySet.contains(dayInt);
      final isToday = dayInt == todayInt;
      return (isActive: isActive, isToday: isToday, day: d);
    });

    final weekLabels = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    final startWeekday = slots.first.day.weekday;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'ACTIVITÉ',
              style: TextStyle(color: _slate, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.2),
            ),
            const SizedBox(width: 8),
            if (p.streak > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${p.streak} jour${p.streak > 1 ? "s" : ""} 🔥',
                  style: const TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(7, (i) {
                  final label = weekLabels[(startWeekday - 1 + i) % 7];
                  return SizedBox(
                    width: 28,
                    child: Text(label, textAlign: TextAlign.center, style: TextStyle(color: _slate.withValues(alpha: 0.5), fontSize: 10, fontWeight: FontWeight.w600)),
                  );
                }),
              ),
              const SizedBox(height: 6),
              ...List.generate(4, (row) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(7, (col) {
                      final idx = row * 7 + col;
                      if (idx >= slots.length) return const SizedBox(width: 28, height: 28);
                      final s = slots[idx];
                      Color dotColor;
                      if (s.isToday && s.isActive) {
                        dotColor = _violet;
                      } else if (s.isActive) {
                        dotColor = _cyan.withValues(alpha: 0.75);
                      } else {
                        dotColor = Colors.white.withValues(alpha: 0.07);
                      }
                      return Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: dotColor,
                          borderRadius: BorderRadius.circular(6),
                          border: s.isToday
                              ? Border.all(color: _violet.withValues(alpha: 0.6), width: 1.5)
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: s.isActive
                            ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                            : null,
                      );
                    }),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildParcoursProgressSection() {
    return FutureBuilder<({int optimusCompleted, int totalChapters, int poolPins})>(
      future: _learningFuture,
      builder: (context, snap) {
        final done = snap.data?.optimusCompleted ?? 0;
        final total = snap.data?.totalChapters ?? 23;
        final ratio = total > 0 ? (done / total).clamp(0.0, 1.0) : 0.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('PROGRESSION PARCOURS', style: TextStyle(color: _slate, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Parcours Optimus', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      Text('$done / $total chapitres', style: const TextStyle(color: _cyan, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(value: ratio, backgroundColor: Colors.white10, color: _cyan, minHeight: 8),
                  if (ratio >= 1.0) ...[
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => context.push('/certificate/optimus'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFFFD166).withValues(alpha: 0.5)),
                          color: const Color(0xFFFFD166).withValues(alpha: 0.07),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.emoji_events_rounded, color: Color(0xFFFFD166), size: 18),
                            const SizedBox(width: 8),
                            const Text(
                              'Voir mon certificat',
                              style: TextStyle(
                                color: Color(0xFFFFD166),
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(Icons.arrow_forward_ios_rounded, color: const Color(0xFFFFD166).withValues(alpha: 0.7), size: 12),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWeeklySection(ProfileSnapshot p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CETTE SEMAINE',
          style: TextStyle(color: _slate, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.2),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _MetricCard(label: 'XP gagnés', value: '${p.xpThisWeek}', color: _amber)),
            const SizedBox(width: 10),
            Expanded(child: _MetricCard(label: 'Quiz joués', value: '${p.quizzesThisWeek}', color: _cyan)),
            const SizedBox(width: 10),
            Expanded(child: _MetricCard(label: 'Missions TP', value: '${p.tpMissionsThisWeek}', color: _green)),
          ],
        ),
      ],
    );
  }

  Widget _buildBadgesSection(ProfileSnapshot p) {
    if (p.badges.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('BADGES RÉCENTS', style: TextStyle(color: _slate, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: p.badges.length,
            itemBuilder: (context, i) {
              final b = resolveBadgeDef(p.badges[i]);
              return Container(
                width: 70,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: b.isSuper ? _amber.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.1)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(b.emoji, style: const TextStyle(fontSize: 24)),
                    const SizedBox(height: 4),
                    Text(b.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 9)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildExplorerSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('EXPLORER', style: TextStyle(color: _slate, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
        const SizedBox(height: 12),
        _ExplorerTile(icon: Icons.psychology_rounded, label: 'Mon IA', route: '/ai/setup', color: _violet),
        _ExplorerTile(icon: Icons.emoji_events_rounded, label: 'Classement', route: '/leaderboard', color: _amber),
        _ExplorerTile(icon: Icons.military_tech_rounded, label: 'Hauts faits', route: '/achievements', color: _violet),
        _ExplorerTile(icon: Icons.biotech_rounded, label: 'Le Labo', route: '/labo', color: _green),
        _ExplorerTile(icon: Icons.settings_rounded, label: 'Réglages', route: '/settings', color: _slate),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return OutlinedButton(
      onPressed: _signOut,
      style: OutlinedButton.styleFrom(
        foregroundColor: _red,
        side: const BorderSide(color: _red, width: 1.5),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: const Text('Se déconnecter', style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: _red, size: 48),
          const SizedBox(height: 16),
          Text(error, style: const TextStyle(color: _slate)),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: _reload, child: const Text('Réessayer')),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MetricCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: _slate, fontSize: 11)),
        ],
      ),
    );
  }
}

class _ExplorerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final Color color;

  const _ExplorerTile({required this.icon, required this.label, required this.route, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => context.push(route),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(width: 16),
                Expanded(child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
                const Icon(Icons.chevron_right_rounded, color: Colors.white24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
