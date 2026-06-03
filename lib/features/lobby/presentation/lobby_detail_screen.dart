import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/eskolia_layout.dart';
import '../../../core/theme/eskolia_visual.dart';
import '../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../shared/widgets/eskolia_shell_body.dart';
import '../data/lobby_repository.dart';
import 'battle_screen.dart';

const Color _bg = EskoliaVisual.bgDeep;
const Color _cyan = Color(0xFF00BCD4);
const Color _violet = Color(0xFF6C63FF);
const Color _slate = Color(0xFF94A3B8);
const Color _slateLight = Color(0xFF94A3B8);
const Color _green = Color(0xFF10B981);
const Color _orange = Color(0xFFFF9800);

class LobbyDetailScreen extends StatefulWidget {
  const LobbyDetailScreen({super.key, required this.lobbyId});

  final String lobbyId;

  @override
  State<LobbyDetailScreen> createState() => _LobbyDetailScreenState();
}

class _LobbyDetailScreenState extends State<LobbyDetailScreen> {
  final LobbyRepository _repo = LobbyRepository();
  bool _battleNavScheduled = false;

  String get _uid =>
      FirebaseAuth.instance.currentUser?.uid ??
      'guest_${widget.lobbyId.hashCode}';

  Future<void> _pushBattle() async {
    if (!mounted) return;
    try {
      await Navigator.of(context).push<void>(
        MaterialPageRoute(
          builder: (_) => BattleScreen(lobbyId: widget.lobbyId),
        ),
      );
    } finally {
      if (mounted) setState(() => _battleNavScheduled = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const EskoliaAmbientBackground(),
          EskoliaShellBody(
            child: StreamBuilder<LobbyModel?>(
              stream: _repo.watchLobby(widget.lobbyId),
              builder: (context, lobbySnap) {
                final lobby = lobbySnap.data;
                if (lobbySnap.connectionState == ConnectionState.waiting &&
                    lobby == null) {
                  return const Center(
                    child: CircularProgressIndicator(color: _cyan),
                  );
                }
                if (lobby == null) {
                  return Center(
                    child: Text(
                      'Lobby introuvable',
                      style: TextStyle(color: _slateLight),
                    ),
                  );
                }
                return StreamBuilder<BattleState>(
                  stream: _repo.watchBattle(widget.lobbyId),
                  builder: (context, battleSnap) {
                    final battle = battleSnap.data;
                    const activeBattlePhases = {
                      'countdown', 'question', 'judgment', 'result', 'final_judgment',
                    };
                    if (battle != null &&
                        activeBattlePhases.contains(battle.phase) &&
                        !_battleNavScheduled) {
                      _battleNavScheduled = true;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _pushBattle();
                      });
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back_rounded,
                                    color: Colors.white),
                                onPressed: () => context.pop(),
                              ),
                              Expanded(
                                child: Text(
                                  lobby.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              _statusBadge(lobby.status),
                            ],
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(
                              EskoliaLayout.screenPaddingH,
                              8,
                              EskoliaLayout.screenPaddingH,
                              EskoliaLayout.screenPaddingBottom,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      'Joueurs',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      '${lobby.currentPlayers} / ${lobby.maxPlayers}',
                                      style: TextStyle(
                                        color: _slateLight,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _playerList(lobby),
                                const SizedBox(height: 24),
                                const Text(
                                  'Détails',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color:
                                          Colors.white.withValues(alpha: 0.1),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        lobby.isPrivate
                                            ? 'Visibilité : privée — partage le code pour inviter.'
                                            : 'Visibilité : publique — visible dans la liste des lobbies.',
                                        style: TextStyle(
                                          color: _slateLight.withValues(alpha: 0.95),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      if (lobby.joinCode.isNotEmpty) ...[
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                'Code : ${lobby.joinCode}',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w800,
                                                  letterSpacing: 1.2,
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              tooltip: 'Copier le code',
                                              icon: Icon(
                                                Icons.copy_rounded,
                                                color: _cyan.withValues(alpha: 0.9),
                                              ),
                                              onPressed: () async {
                                                await Clipboard.setData(
                                                  ClipboardData(text: lobby.joinCode),
                                                );
                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      content: Text('Code copié'),
                                                    ),
                                                  );
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                      ],
                                      Text(
                                        'Sujet : ${lobby.subject}',
                                        style: TextStyle(
                                          color: _slateLight,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Mode : ${lobby.gameModeLabelDetail}',
                                        style: TextStyle(
                                          color: _slateLight,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Questions : ${lobby.questionCount}',
                                        style: TextStyle(color: _slateLight, fontSize: 13),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Difficultés : ${lobby.difficultyFilters.join(", ")}',
                                        style: TextStyle(color: _slateLight, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                                _mainButton(lobby, battle),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    late Color bg;
    late Color fg;
    late String label;
    switch (status) {
      case 'in_progress':
        bg = _orange.withValues(alpha: 0.2);
        fg = _orange;
        label = 'En cours';
        break;
      case 'finished':
        bg = _slate.withValues(alpha: 0.2);
        fg = _slate;
        label = 'Terminé';
        break;
      default:
        bg = _green.withValues(alpha: 0.2);
        fg = _green;
        label = 'Ouvert';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _playerList(LobbyModel lobby) {
    final players = lobby.playerMeta;

    if (players.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 32),
        alignment: Alignment.center,
        child: Column(
          children: [
            const Icon(Icons.hourglass_empty_rounded, size: 36, color: Colors.white38),
            const SizedBox(height: 12),
            Text(
              'En attente de joueurs...',
              style: TextStyle(color: _slateLight, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        for (final player in players)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _violet.withValues(alpha: 0.2),
                  child: Text(
                    player.displayName.isNotEmpty
                        ? player.displayName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  player.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    'Prêt',
                    style: TextStyle(
                      color: _green,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _mainButton(LobbyModel lobby, BattleState? battle) {
    final uid = _uid;
    final isHost = lobby.hostId == uid;
    final inLobby = lobby.playerMeta.any((m) => m.userId == uid);

    if (lobby.status == 'in_progress') {
      if (!inLobby) {
        if (lobby.isFull) {
          return Text(
            'Lobby complet',
            textAlign: TextAlign.center,
            style: TextStyle(color: _slateLight),
          );
        }
        return FilledButton(
          onPressed: () async {
            await _repo.joinLobby(lobby.id, uid);
            if (mounted) await _pushBattle();
          },
          style: FilledButton.styleFrom(
            backgroundColor: _cyan,
            foregroundColor: Colors.black87,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text('Rejoindre la partie en cours'),
        );
      }
      return FilledButton(
        onPressed: () => _pushBattle(),
        style: FilledButton.styleFrom(
          backgroundColor: _violet,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text('Ouvrir la bataille'),
      );
    }

    if (lobby.status == 'waiting') {
      if (isHost) {
        final playerCount = lobby.playerMeta.length;
        if (playerCount < 2) {
          return Column(
            children: [
              Text(
                'En attente d\'un autre joueur… ($playerCount / ${lobby.maxPlayers})',
                textAlign: TextAlign.center,
                style: TextStyle(color: _slateLight, fontSize: 13),
              ),
              const SizedBox(height: 12),
              Text(
                'Partage le code ${lobby.joinCode} pour inviter.',
                textAlign: TextAlign.center,
                style: TextStyle(color: _cyan, fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ],
          );
        }
        return Material(
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          color: Colors.transparent,
          child: InkWell(
            onTap: () async {
              try {
                await _repo.startBattleCountdown(lobby.id, lobby);
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('$e')));
              }
            },
            child: Ink(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_violet, Color(0xFF8B5CF6)],
                ),
              ),
              child: Container(
                width: double.infinity,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Lancer la bataille ($playerCount joueurs)',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        );
      }
      if (!inLobby && !lobby.isFull) {
        return FilledButton(
          onPressed: () async {
            await _repo.joinLobby(lobby.id, uid);
            if (mounted) setState(() {});
          },
          style: FilledButton.styleFrom(
            backgroundColor: _cyan,
            foregroundColor: Colors.black87,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text('Rejoindre'),
        );
      }
      if (inLobby) {
        return Text(
          'En attente du lancement par le host…',
          textAlign: TextAlign.center,
          style: TextStyle(color: _slateLight, fontSize: 13),
        );
      }
    }

    return Text(
      battle?.phase == 'finished' ? 'Partie terminée' : 'En attente...',
      textAlign: TextAlign.center,
      style: TextStyle(color: _slateLight),
    );
  }
}
