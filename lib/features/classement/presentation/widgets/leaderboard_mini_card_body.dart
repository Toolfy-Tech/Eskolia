import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/eskolia_tokens.dart';
import '../../../../data/repositories/leaderboard_repository.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../auth/data/user_model.dart';
import '../../../home/presentation/providers/home_providers.dart';
import '../../data/models/leaderboard_entry_model.dart';

class LeaderboardMiniCardBody extends ConsumerWidget {
  const LeaderboardMiniCardBody({super.key, this.isExpandedOverride});
  final bool? isExpandedOverride;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsMap = ref.watch(homeCardSettingsProvider);
    final isCollapsed = isExpandedOverride != null
        ? !isExpandedOverride!
        : (settingsMap['feature:leaderboard_mini']?.isCollapsed ?? false);

    final uid = FirebaseAuth.instance.currentUser?.uid;
    final repo = LeaderboardRepository();

    if (uid == null) return const SizedBox.shrink();

    return StreamBuilder<UserModel?>(
      stream: UserRepository().watchUser(uid),
      builder: (context, userSnap) {
        final user = userSnap.data;
        if (user == null) {
          return const Center(
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: EskoliaTokens.amber),
            ),
          );
        }

        if (isCollapsed) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.02),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    const Text('🏆', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Niveau ${user.level} · ${user.xpThisWeek} XP cette semaine',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Série de ${user.streak} jours consécutifs',
                            style: const TextStyle(color: EskoliaTokens.textSecondary, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => context.go('/classement'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: EskoliaTokens.amber,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                child: const Text('Voir le classement', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        }

        // Extended mode
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Podium de la semaine',
              style: TextStyle(color: EskoliaTokens.textSecondary, fontSize: 10.5, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            StreamBuilder<List<LeaderboardEntryModel>>(
              stream: repo.watchWeeklyTop(limit: 3),
              builder: (context, boardSnap) {
                if (boardSnap.hasError || !boardSnap.hasData) {
                  return const SizedBox(
                    height: 60,
                    child: Center(
                      child: SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: EskoliaTokens.amber),
                      ),
                    ),
                  );
                }

                final top3 = boardSnap.data!;
                if (top3.isEmpty) {
                  return const Text(
                    'Aucune donnée cette semaine',
                    style: TextStyle(color: Colors.white38, fontSize: 10),
                  );
                }

                return Column(
                  children: top3.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final player = entry.value;
                    final isPlayerSelf = player.uid == uid;
                    final medals = ['🥇', '🥈', '🥉'];
                    final medal = idx < medals.length ? medals[idx] : '👤';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: isPlayerSelf
                            ? EskoliaTokens.amber.withValues(alpha: 0.1)
                            : Colors.white.withValues(alpha: 0.02),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isPlayerSelf
                              ? EskoliaTokens.amber.withValues(alpha: 0.3)
                              : Colors.white.withValues(alpha: 0.04),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(medal, style: const TextStyle(fontSize: 14)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              player.username.isNotEmpty ? player.username : 'Anonyme',
                              style: TextStyle(
                                color: isPlayerSelf ? Colors.white : Colors.white70,
                                fontSize: 11,
                                fontWeight: isPlayerSelf ? FontWeight.bold : FontWeight.normal,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${player.xpThisWeek} XP',
                            style: TextStyle(
                              color: isPlayerSelf ? EskoliaTokens.amber : Colors.white54,
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.go('/classement'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text(
                      'Arène des champions',
                      style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
