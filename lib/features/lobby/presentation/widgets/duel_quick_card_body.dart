import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/eskolia_tokens.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../auth/data/user_model.dart';
import '../../../home/presentation/providers/home_providers.dart';
import '../../data/lobby_repository.dart';

class DuelQuickCardBody extends ConsumerStatefulWidget {
  const DuelQuickCardBody({super.key, this.isExpandedOverride});
  final bool? isExpandedOverride;

  @override
  ConsumerState<DuelQuickCardBody> createState() => _DuelQuickCardBodyState();
}

class _DuelQuickCardBodyState extends ConsumerState<DuelQuickCardBody> {
  bool _searching = false;
  Timer? _searchTimer;

  Future<void> _startMatchmaking() async {
    setState(() => _searching = true);

    _searchTimer = Timer(const Duration(milliseconds: 2000), () async {
      if (!mounted) return;
      try {
        final uid = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
        String name = 'Hôte';
        if (uid != 'guest') {
          final userDoc = await UserRepository().getUserById(uid);
          if (userDoc != null && userDoc.username.isNotEmpty) {
            name = userDoc.username;
          }
        }

        final db = FirebaseFirestore.instance;
        // 1. Chercher un lobby de duel (maxPlayers == 2) ouvert (waiting) et non privé, où l'hôte n'est pas nous-même
        final snap = await db
            .collection('lobbies')
            .where('maxPlayers', isEqualTo: 2)
            .where('status', isEqualTo: 'waiting')
            .where('isPrivate', isEqualTo: false)
            .get();

        final joinable = snap.docs.where((doc) {
          final data = doc.data();
          final hostId = data['hostId'] as String?;
          final currentPlayers = (data['currentPlayers'] as num?)?.toInt() ?? 0;
          return hostId != uid && currentPlayers < 2;
        }).toList();

        if (joinable.isNotEmpty) {
          // Rejoindre le premier disponible
          final matchedLobby = joinable.first;
          await LobbyRepository().joinLobby(matchedLobby.id, uid);
          if (!mounted) return;
          setState(() => _searching = false);
          context.push('/lobby/${matchedLobby.id}');
        } else {
          // Créer un nouveau lobby de duel
          final lobbyId = await LobbyRepository().createLobby(LobbyModel(
            id: '',
            title: 'Duel de $name',
            subject: 'Défi Express 1v1',
            hostName: name,
            hostAvatar: '⚡',
            currentPlayers: 1,
            maxPlayers: 2,
            status: 'waiting',
            difficulty: 'mixte',
            quizId: 'tip',
            createdAt: DateTime.now(),
            hostId: uid,
            questionAssetPaths: const [
              'data/quiz/optimus/module-01-support-utilisateur/M01-CH01-Q-itil-cadre-gestion.quiz.json',
              'data/quiz/optimus/module-02-hardware-architecture/M02-CH01-Q-boitiers.quiz.json',
              'data/quiz/optimus/module-03-systeme-exploitation/M03-CH01-Q-differents-os.quiz.json',
              'data/quiz/optimus/module-04-reseaux-infrastructure/M04-CH01-Q-composants-reseau-binaire.quiz.json',
              'data/quiz/optimus/module-05-maintenance-sauvegarde/M05-CH01-Q-backup-definition-3210.quiz.json',
              'data/quiz/optimus/module-06-administration-windows/M06-CH01-Q-m365-entra-id.quiz.json',
              'data/quiz/optimus/module-07-cybersecurite/M07-CH01-malwares.json',
              'data/quiz/optimus/module-08-utiliser-ia/M08-CH01-roct-contexte.json',
              'data/exam/exam01.json',
              'data/exam/exam02.json',
              'data/exam/exam03.json',
              'data/exam/exam04.json',
              'data/exam/exam05.json',
              'data/exam/exam06.json',
              'data/exam/exam07.json',
              'data/exam/exam08.json',
            ],
            isPrivate: false,
            correctionMode: 'at_end',
            gameMode: kLobbyGameModeQuiz,
            timed: true,
            questionCount: 10,
            difficultyFilters: const ['facile', 'moyen', 'difficile'],
            playerMeta: [PlayerMeta(userId: uid, displayName: name, avatar: '⚡')],
          ));

          if (!mounted) return;
          setState(() => _searching = false);
          context.push('/lobby/$lobbyId');
        }
      } catch (e) {
        if (mounted) {
          setState(() => _searching = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur matchmaking: $e')),
          );
        }
      }
    });
  }

  void _cancelMatchmaking() {
    _searchTimer?.cancel();
    setState(() => _searching = false);
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsMap = ref.watch(homeCardSettingsProvider);
    final isCollapsed = widget.isExpandedOverride != null
        ? !widget.isExpandedOverride!
        : (settingsMap['feature:duel_quick']?.isCollapsed ?? false);

    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_searching)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              children: [
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(EskoliaTokens.cyan),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Recherche d\'un adversaire...',
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Recherche d\'un salon de duel ouvert...',
                  style: TextStyle(color: Colors.white38, fontSize: 10),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: _cancelMatchmaking,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: EskoliaTokens.error),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    minimumSize: Size.zero,
                  ),
                  child: const Text(
                    'Annuler',
                    style: TextStyle(color: EskoliaTokens.error, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          )
        else ...[
          // Stats & Matchmaking Button
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.02),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Statut de connexion',
                        style: TextStyle(color: EskoliaTokens.textSecondary, fontSize: 9.5),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: EskoliaTokens.success,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'En ligne',
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (uid != null)
                Expanded(
                  child: StreamBuilder<UserModel?>(
                    stream: UserRepository().watchUser(uid),
                    builder: (context, snapshot) {
                      final wins = snapshot.data?.battleWins ?? 0;
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.02),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Victoires Duel',
                              style: TextStyle(color: EskoliaTokens.textSecondary, fontSize: 9.5),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '🏆 $wins',
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: _startMatchmaking,
            style: ElevatedButton.styleFrom(
              backgroundColor: EskoliaTokens.cyan,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
            icon: const Icon(Icons.flash_on_rounded, size: 16),
            label: const Text(
              'Matchmaking Rapide (1v1)',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],

        // Expanded view details: List of active users
        if (!isCollapsed && !_searching) ...[
          const SizedBox(height: 12),
          const Text(
            'Autres joueurs en ligne',
            style: TextStyle(color: EskoliaTokens.textSecondary, fontSize: 11, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance.collection('users').limit(4).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError || !snapshot.hasData) {
                return const SizedBox.shrink();
              }
              final docs = snapshot.data!.docs.where((d) => d.id != uid).toList();
              if (docs.isEmpty) {
                return const Text(
                  'Aucun autre joueur disponible',
                  style: TextStyle(color: Colors.white38, fontSize: 10),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: docs.length,
                separatorBuilder: (context, index) => const SizedBox(height: 6),
                itemBuilder: (context, index) {
                  final data = docs[index].data();
                  final name = data['username'] as String? ?? 'Joueur';
                  final wins = data['battleWins'] as int? ?? 0;

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.015),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
                    ),
                    child: Row(
                      children: [
                        const Text('👤', style: TextStyle(fontSize: 12)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(color: Colors.white70, fontSize: 11.5, fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '🏆 $wins v.',
                          style: const TextStyle(color: Colors.white38, fontSize: 10),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () async {
                            // Créer un duel privé et naviguer
                            final hostUid = uid ?? 'guest';
                            final hostDoc = await UserRepository().getUserById(hostUid);
                            final hostName = hostDoc?.username ?? 'Hôte';

                            final lobbyId = await LobbyRepository().createLobby(LobbyModel(
                              id: '',
                              title: 'Défi de $hostName',
                              subject: 'Défi direct à $name',
                              hostName: hostName,
                              hostAvatar: '⚡',
                              currentPlayers: 1,
                              maxPlayers: 2,
                              status: 'waiting',
                              difficulty: 'mixte',
                              quizId: 'tip',
                              createdAt: DateTime.now(),
                              hostId: hostUid,
                              questionAssetPaths: const [
                                'data/quiz/optimus/module-01-support-utilisateur/M01-CH01-Q-itil-cadre-gestion.quiz.json',
                                'data/quiz/optimus/module-02-hardware-architecture/M02-CH01-Q-boitiers.quiz.json',
                                'data/quiz/optimus/module-03-systeme-exploitation/M03-CH01-Q-differents-os.quiz.json',
                                'data/quiz/optimus/module-04-reseaux-infrastructure/M04-CH01-Q-composants-reseau-binaire.quiz.json',
                                'data/quiz/optimus/module-05-maintenance-sauvegarde/M05-CH01-Q-backup-definition-3210.quiz.json',
                                'data/quiz/optimus/module-06-administration-windows/M06-CH01-Q-m365-entra-id.quiz.json',
                                'data/quiz/optimus/module-07-cybersecurite/M07-CH01-malwares.json',
                                'data/quiz/optimus/module-08-utiliser-ia/M08-CH01-roct-contexte.json',
                              ],
                              isPrivate: true,
                              correctionMode: 'at_end',
                              gameMode: kLobbyGameModeQuiz,
                              timed: true,
                              questionCount: 10,
                              difficultyFilters: const ['facile', 'moyen', 'difficile'],
                              playerMeta: [PlayerMeta(userId: hostUid, displayName: hostName, avatar: '⚡')],
                            ));

                            if (!context.mounted) return;
                            context.push('/lobby/$lobbyId');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withValues(alpha: 0.08),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Défier',
                            style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ],
    );
  }
}
