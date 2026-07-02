import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/podcast_player_service.dart';
import '../../../core/constants/eskolia_tokens.dart';

/// Mini-lecteur persistant affiché dans le shell quand un podcast est actif.
/// Permet de contrôler la lecture sans quitter l'écran courant.
class PodcastMiniPlayer extends ConsumerWidget {
  const PodcastMiniPlayer({super.key});

  static String _fmt(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s < 10 ? '0$s' : '$s'}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(podcastPlayerProvider);
    final podcast = state.podcast;
    if (podcast == null) return const SizedBox.shrink();

    final playing = state.isPlaying;
    final total = state.duration ?? Duration.zero;
    final hasDuration = total.inMilliseconds > 0;
    final pos = state.position.inMilliseconds
        .clamp(0, hasDuration ? total.inMilliseconds : 0)
        .toDouble();
    final progress = hasDuration ? pos / total.inMilliseconds : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: EskoliaTokens.bgBase.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: EskoliaTokens.violet.withValues(alpha: 0.30),
        ),
        boxShadow: [
          BoxShadow(
            color: EskoliaTokens.violet.withValues(alpha: 0.18),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Barre de progression fine en haut
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: SizedBox(
              height: 3,
              child: LinearProgressIndicator(
                value: progress.toDouble(),
                backgroundColor: Colors.white.withValues(alpha: 0.08),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(EskoliaTokens.cyan),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
            child: Row(
              children: [
                // Bouton play/pause compact
                _MiniPlayButton(
                  playing: playing,
                  loading: state.loading,
                  onTap: () => ref
                      .read(podcastPlayerProvider.notifier)
                      .play(podcast),
                ),
                const SizedBox(width: 10),
                // Titre + temps
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        podcast.displayTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hasDuration
                            ? '${_fmt(state.position)} / ${_fmt(total)}'
                            : 'Chargement...',
                        style: const TextStyle(
                          color: EskoliaTokens.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                // Seek -15s
                _SeekButton(
                  icon: Icons.replay_10_rounded,
                  onTap: hasDuration
                      ? () => ref.read(podcastPlayerProvider.notifier).seek(
                            Duration(
                              milliseconds: (state.position.inMilliseconds - 10000)
                                  .clamp(0, total.inMilliseconds),
                            ),
                          )
                      : null,
                ),
                // Seek +15s
                _SeekButton(
                  icon: Icons.forward_10_rounded,
                  onTap: hasDuration
                      ? () => ref.read(podcastPlayerProvider.notifier).seek(
                            Duration(
                              milliseconds: (state.position.inMilliseconds + 10000)
                                  .clamp(0, total.inMilliseconds),
                            ),
                          )
                      : null,
                ),
                // Fermer
                IconButton(
                  onPressed: () =>
                      ref.read(podcastPlayerProvider.notifier).dismiss(),
                  icon: Icon(
                    Icons.close_rounded,
                    color: Colors.white.withValues(alpha: 0.45),
                    size: 20,
                  ),
                  padding: const EdgeInsets.all(6),
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniPlayButton extends StatelessWidget {
  const _MiniPlayButton({
    required this.playing,
    required this.loading,
    required this.onTap,
  });

  final bool playing;
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [EskoliaTokens.cyan, EskoliaTokens.violet],
          ),
        ),
        child: loading
            ? const Padding(
                padding: EdgeInsets.all(10),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(
                playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: Colors.white,
                size: 22,
              ),
      ),
    );
  }
}

class _SeekButton extends StatelessWidget {
  const _SeekButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(
        icon,
        color: onTap != null
            ? Colors.white.withValues(alpha: 0.65)
            : Colors.white.withValues(alpha: 0.2),
        size: 22,
      ),
      padding: const EdgeInsets.all(6),
      constraints: const BoxConstraints(),
    );
  }
}
