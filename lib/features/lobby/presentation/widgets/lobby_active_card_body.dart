import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/eskolia_tokens.dart';
import '../../../home/presentation/providers/home_providers.dart';
import '../../data/lobby_repository.dart';

class LobbyActiveCardBody extends ConsumerWidget {
  const LobbyActiveCardBody({super.key, this.isExpandedOverride});
  final bool? isExpandedOverride;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsMap = ref.watch(homeCardSettingsProvider);
    final isCollapsed = isExpandedOverride != null
        ? !isExpandedOverride!
        : (settingsMap['feature:lobbys_active']?.isCollapsed ?? false);

    final repo = LobbyRepository();

    return StreamBuilder<List<LobbyModel>>(
      stream: repo.watchLobbies(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Erreur de chargement des lobbies',
                style: TextStyle(color: EskoliaTokens.error, fontSize: 11),
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(12.0),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white24),
              ),
            ),
          );
        }

        final lobbies = snapshot.data ?? [];
        final waitingLobbies = lobbies.where((l) => l.status == 'waiting').toList();

        if (isCollapsed) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.02),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.radio_button_checked_rounded, color: Colors.pinkAccent, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        waitingLobbies.isEmpty
                            ? 'Aucun salon en attente'
                            : waitingLobbies.length == 1
                                ? '1 salon ouvert en attente'
                                : '${waitingLobbies.length} salons ouverts en attente',
                        style: const TextStyle(color: Colors.white70, fontSize: 12.0),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => context.go('/lobbys'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                child: const Text('Ouvrir Multijoueur', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        }

        // Expanded mode
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (waitingLobbies.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.02),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white10),
                ),
                child: const Column(
                  children: [
                    Text(
                      'Aucun salon public actif',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: EskoliaTokens.textSecondary, fontSize: 12),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Créez un nouveau salon ou rejoignez avec un code.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white38, fontSize: 10),
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: waitingLobbies.take(4).length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final lobby = waitingLobbies[index];
                  final diff = lobby.difficulty.toUpperCase();
                  final isSurvival = lobby.isSurvival;

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.05),
                          ),
                          child: Center(
                            child: Text(
                              lobby.hostAvatar.isNotEmpty ? lobby.hostAvatar : '👤',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lobby.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                                    decoration: BoxDecoration(
                                      color: isSurvival
                                          ? EskoliaTokens.error.withValues(alpha: 0.15)
                                          : EskoliaTokens.violet.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      isSurvival ? 'Survival' : 'Quiz',
                                      style: TextStyle(
                                        color: isSurvival ? EskoliaTokens.error : EskoliaTokens.violetSoft,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '👥 ${lobby.currentPlayers}/${lobby.maxPlayers}',
                                    style: const TextStyle(color: EskoliaTokens.textSecondary, fontSize: 9.5),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      diff,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: diff.contains('FACILE')
                                            ? EskoliaTokens.success
                                            : diff.contains('DIFFICILE')
                                                ? EskoliaTokens.error
                                                : EskoliaTokens.amber,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        ElevatedButton(
                          onPressed: () => context.push('/lobby/${lobby.id}'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withValues(alpha: 0.08),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Rejoindre',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.go('/lobbys'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text(
                      'Voir tous les salons',
                      style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600),
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
