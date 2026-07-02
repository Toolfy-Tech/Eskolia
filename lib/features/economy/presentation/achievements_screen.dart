import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/eskolia_tokens.dart';
import '../../../core/theme/eskolia_layout.dart';
import '../../../core/theme/eskolia_visual.dart';
import '../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../shared/widgets/eskolia_shell_body.dart';
import '../../../shared/widgets/eskolia_app_bar.dart';
import '../data/achievement_catalog.dart';
import '../data/achievements_repository.dart';
import '../data/badge_catalog.dart';

const Color _bg = EskoliaVisual.bgDeep;
const Color _slate = EskoliaTokens.textSecondary;
const Color _violet = EskoliaTokens.violet;

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final repo = AchievementsRepository();

    return Scaffold(
      extendBodyBehindAppBar: false,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const EskoliaAmbientBackground(),
          EskoliaShellBody(
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
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 24, top: 8),
                          child: Text(
                            '🏅 Hauts faits',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      ...List.generate(
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
                    ],
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
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 24, top: 8),
                        child: Text(
                          '🏅 Hauts faits',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
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
                        : Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  EskoliaTokens.violet.withValues(alpha: 0.16),
                                  EskoliaTokens.cyan.withValues(alpha: 0.04),
                                ],
                              ),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.08),
                                width: 1.0,
                              ),
                            ),
                            child: Row(
                              children: [
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    SizedBox(
                                      width: 60,
                                      height: 60,
                                      child: CircularProgressIndicator(
                                        value: rows.isEmpty ? 0 : n / rows.length,
                                        strokeWidth: 5,
                                        backgroundColor: Colors.white10,
                                        color: EskoliaTokens.cyan,
                                      ),
                                    ),
                                    Text(
                                      rows.isEmpty
                                          ? '0%'
                                          : '${((n / rows.length) * 100).toInt()}%',
                                      style: GoogleFonts.outfit(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 18),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '$n / ${rows.length} Débloqués',
                                        style: GoogleFonts.outfit(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 18,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Continue à résoudre des quiz et des duels pour collecter tous les hauts faits !',
                                        style: GoogleFonts.plusJakartaSans(
                                          color: EskoliaTokens.textSecondary.withValues(alpha: 0.8),
                                          fontSize: 11,
                                          height: 1.35,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                    const SizedBox(height: 20),
                    ...List.generate(rows.length, (index) {
                      final row = rows[index];
                      final d = row.$1;
                      final ok = row.$2;
                      final progressLabel = row.$3;

                      double? progressPercent;
                      if (progressLabel != null) {
                        final parts = progressLabel.split('/');
                        if (parts.length == 2) {
                          final current = double.tryParse(parts[0].trim());
                          final target = double.tryParse(parts[1].trim());
                          if (current != null && target != null && target > 0) {
                            progressPercent = current / target;
                          }
                        }
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: ok
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.white.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: ok
                                  ? EskoliaTokens.cyan.withValues(alpha: 0.45)
                                  : Colors.white.withValues(alpha: 0.06),
                              width: ok ? 1.4 : 1.0,
                            ),
                            boxShadow: ok
                                ? [
                                    BoxShadow(
                                      color: EskoliaTokens.cyan.withValues(alpha: 0.12),
                                      blurRadius: 10,
                                      spreadRadius: 1,
                                    )
                                  ]
                                : null,
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: ok
                                      ? EskoliaTokens.cyan.withValues(alpha: 0.15)
                                      : Colors.white.withValues(alpha: 0.05),
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  d.emoji,
                                  style: TextStyle(
                                    fontSize: 26,
                                    color: Colors.white.withValues(
                                      alpha: ok ? 1 : 0.35,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      d.title,
                                      style: GoogleFonts.plusJakartaSans(
                                        color: Colors.white.withValues(
                                          alpha: ok ? 1 : 0.55,
                                        ),
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      d.description,
                                      style: GoogleFonts.plusJakartaSans(
                                        color: _slate.withValues(
                                          alpha: ok ? 0.95 : 0.5,
                                        ),
                                        fontSize: 12,
                                        height: 1.3,
                                      ),
                                    ),
                                    if (progressLabel != null) ...[
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(4),
                                              child: LinearProgressIndicator(
                                                value: progressPercent ?? 0.0,
                                                minHeight: 4,
                                                backgroundColor: Colors.white10,
                                                color: ok ? EskoliaTokens.success : EskoliaTokens.cyan,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            progressLabel,
                                            style: GoogleFonts.outfit(
                                              color: ok
                                                  ? EskoliaTokens.success.withValues(alpha: 0.95)
                                                  : EskoliaTokens.cyan,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                    if (d.linkedBadgeId != null) ...[
                                      const SizedBox(height: 10),
                                      Builder(
                                        builder: (context) {
                                          final b = resolveBadgeDef(d.linkedBadgeId!);
                                          final superStyle = b.isSuper;
                                          return Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: superStyle
                                                  ? EskoliaTokens.amber.withValues(alpha: 0.12)
                                                  : EskoliaTokens.violet.withValues(alpha: 0.12),
                                              borderRadius: BorderRadius.circular(10),
                                              border: Border.all(
                                                color: superStyle
                                                    ? EskoliaTokens.amber.withValues(alpha: 0.45)
                                                    : EskoliaTokens.violet.withValues(alpha: 0.35),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  b.emoji,
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  superStyle
                                                      ? 'Super badge : ${b.title}'
                                                      : 'Badge : ${b.title}',
                                                  style: GoogleFonts.plusJakartaSans(
                                                    color: Colors.white.withValues(
                                                      alpha: ok ? 0.92 : 0.45,
                                                    ),
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w700,
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
                              const SizedBox(width: 8),
                              if (ok)
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Color(0x264ADE80),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check_circle_rounded,
                                    color: EskoliaTokens.success,
                                    size: 22,
                                  ),
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
