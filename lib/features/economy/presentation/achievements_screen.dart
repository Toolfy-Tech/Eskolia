import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/eskolia_layout.dart';
import '../../../core/theme/eskolia_visual.dart';
import '../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../shared/widgets/eskolia_shell_body.dart';
import '../../../shared/widgets/eskolia_app_bar.dart';
import '../data/achievement_catalog.dart';
import '../data/achievements_repository.dart';
import '../data/badge_catalog.dart';

const Color _bg = EskoliaVisual.bgDeep;
const Color _slate = Color(0xFF94A3B8);
const Color _violet = Color(0xFF6C63FF);

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final repo = AchievementsRepository();

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: EskoliaAppBar.standard(context, title: 'Hauts faits', showBack: false),
      body: Stack(
        children: [
          const EskoliaAmbientBackground(),
          EskoliaShellBody(
            safeAreaTop: false,
            child: FutureBuilder<List<(AchievementDef, bool, String?)>>(
              future: repo.listWithStateAndProgress(uid),
              builder: (context, snap) {
                if (snap.hasError) {
                  return Center(
                    child: Text(
                      'Impossible de charger les hauts faits.',
                      style: TextStyle(color: Colors.red.shade200),
                    ),
                  );
                }
                if (!snap.hasData) {
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(
                      EskoliaLayout.screenPaddingH,
                      8,
                      EskoliaLayout.screenPaddingH,
                      EskoliaLayout.screenPaddingBottom,
                    ),
                    children: List.generate(
                      5,
                      (i) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Container(
                          height: 88,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(16),
                          ),
                        )
                            .animate(onPlay: (c) => c.repeat(reverse: true))
                            .shimmer(duration: 900.ms, color: Colors.white10),
                      ),
                    ),
                  );
                }
                final rows = snap.data!;
                final n = rows.where((e) => e.$2).length;
                if (rows.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('\u{1F3C6}', style: TextStyle(fontSize: 52)),
                        const SizedBox(height: 16),
                        const Text(
                          'Aucun haut fait disponible',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Complète des quiz et des duels pour en débloquer.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: _slate.withValues(alpha: 0.85), fontSize: 13),
                        ),
                      ],
                    ),
                  );
                }
                return ListView(
                  padding: const EdgeInsets.fromLTRB(
                    EskoliaLayout.screenPaddingH,
                    8,
                    EskoliaLayout.screenPaddingH,
                    EskoliaLayout.screenPaddingBottom,
                  ),
                  children: [
                    uid.isEmpty
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: _violet.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _violet.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline_rounded, color: _violet, size: 18),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Connecte-toi pour sauvegarder ta progression.',
                                    style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Text(
                            '$n / ${rows.length} débloqués',
                            style: TextStyle(
                              color: _slate.withValues(alpha: 0.95),
                              fontSize: 13,
                            ),
                          ),
                    const SizedBox(height: 16),
                    ...List.generate(rows.length, (index) {
                      final row = rows[index];
                      final d = row.$1;
                      final ok = row.$2;
                      final progressLabel = row.$3;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(
                              alpha: ok ? 0.1 : 0.05,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: ok
                                  ? _violet.withValues(alpha: 0.45)
                                  : Colors.white.withValues(alpha: 0.08),
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                d.emoji,
                                style: TextStyle(
                                  fontSize: 28,
                                  color: Colors.white.withValues(
                                    alpha: ok ? 1 : 0.35,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      d.title,
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: ok ? 1 : 0.55,
                                        ),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      d.description,
                                      style: TextStyle(
                                        color: _slate.withValues(
                                          alpha: ok ? 0.95 : 0.5,
                                        ),
                                        fontSize: 12,
                                        height: 1.3,
                                      ),
                                    ),
                                    if (progressLabel != null) ...[
                                      const SizedBox(height: 6),
                                      Text(
                                        'Progression : $progressLabel',
                                        style: TextStyle(
                                          color: ok
                                              ? const Color(0xFF43E97B)
                                                  .withValues(alpha: 0.95)
                                              : _violet.withValues(alpha: 0.9),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                    ],
                                    if (d.linkedBadgeId != null) ...[
                                      const SizedBox(height: 8),
                                      Builder(
                                        builder: (context) {
                                          final b =
                                              resolveBadgeDef(d.linkedBadgeId!);
                                          final superStyle = b.isSuper;
                                          return Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: superStyle
                                                  ? const Color(0xFFFFC107)
                                                      .withValues(alpha: 0.12)
                                                  : _violet.withValues(
                                                      alpha: 0.12,
                                                    ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                color: superStyle
                                                    ? const Color(0xFFFFC107)
                                                        .withValues(alpha: 0.45)
                                                    : _violet.withValues(
                                                        alpha: 0.35,
                                                      ),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  b.emoji,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    superStyle
                                                        ? 'Super badge : ${b.title}'
                                                        : 'Badge : ${b.title}',
                                                    style: TextStyle(
                                                      color: Colors.white
                                                          .withValues(
                                                        alpha:
                                                            ok ? 0.92 : 0.45,
                                                      ),
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      height: 1.25,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              if (ok)
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: Color(0xFF43E97B),
                                  size: 22,
                                )
                              else
                                Icon(
                                  Icons.lock_outline_rounded,
                                  color: _slate.withValues(alpha: 0.45),
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 280.ms, delay: (index * 45).ms)
                          .slideY(begin: 0.05, duration: 280.ms, delay: (index * 45).ms);
                    }),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
