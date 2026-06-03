import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../shared/widgets/eskolia_card.dart';
import '../data/podcast_model.dart';
import '../data/podcast_player_service.dart';
import '../../../core/constants/eskolia_tokens.dart';

export '../data/podcast_player_service.dart' show podcastPlayerProvider;

/// Lecteur pour un podcast donné. Délègue l'audio à [podcastPlayerProvider].
/// Un seul podcast peut jouer à la fois dans l'app.
class PodcastPlayerCard extends ConsumerWidget {
  const PodcastPlayerCard({
    super.key,
    required this.podcast,
  });

  final Podcast podcast;

  static String _fmt(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s < 10 ? '0$s' : '$s'}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(podcastPlayerProvider);
    final isThis = state.podcast?.url == podcast.url;
    final playing = isThis && state.isPlaying;
    final loading = isThis && state.loading;
    final total = isThis ? (state.duration ?? Duration.zero) : Duration.zero;
    final hasDuration = total.inMilliseconds > 0;
    final pos = isThis
        ? state.position.inMilliseconds
            .clamp(0, hasDuration ? total.inMilliseconds : 0)
            .toDouble()
        : 0.0;
    final error = isThis ? state.error : null;

    const timeStyle = TextStyle(
      color: EskoliaTokens.textSecondary,
      fontSize: 11,
      fontWeight: FontWeight.w600,
    );

    return EskoliaCardContent(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _PlayButton(
                playing: playing,
                loading: loading,
                onTap: () =>
                    ref.read(podcastPlayerProvider.notifier).play(podcast),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (podcast.id.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: EskoliaTokens.cyan.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                  color: EskoliaTokens.cyan.withValues(alpha: 0.40)),
                            ),
                            child: Text(
                              podcast.id,
                              style: const TextStyle(
                                color: EskoliaTokens.cyan,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: Text(
                            podcast.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              height: 1.25,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (podcast.subtitle != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        podcast.subtitle!,
                        style: const TextStyle(color: EskoliaTokens.textSecondary, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.download_rounded),
                color: EskoliaTokens.textSecondary,
                iconSize: 20,
                tooltip: 'Telecharger',
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(),
                visualDensity: VisualDensity.compact,
                onPressed: () => launchUrl(
                  Uri.parse(podcast.url),
                  mode: LaunchMode.externalApplication,
                ),
              ),
              const SizedBox(width: 2),
              Icon(
                Icons.graphic_eq_rounded,
                color: EskoliaTokens.cyan.withValues(alpha: playing ? 0.95 : 0.35),
                size: 20,
              ),
            ],
          ),
          if (isThis && (hasDuration || state.loading)) ...[
            const SizedBox(height: 8),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 3,
                activeTrackColor: EskoliaTokens.cyan,
                inactiveTrackColor: Colors.white.withValues(alpha: 0.15),
                thumbColor: EskoliaTokens.cyan,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape:
                    const RoundSliderOverlayShape(overlayRadius: 14),
              ),
              child: Slider(
                value: pos,
                max: hasDuration ? total.inMilliseconds.toDouble() : 1.0,
                onChanged: hasDuration
                    ? (v) {}
                    : null,
                onChangeEnd: hasDuration
                    ? (v) => ref
                        .read(podcastPlayerProvider.notifier)
                        .seek(Duration(milliseconds: v.round()))
                    : null,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isThis ? _fmt(state.position) : '0:00',
                    style: timeStyle,
                  ),
                  Text(
                    hasDuration ? _fmt(total) : '--:--',
                    style: timeStyle,
                  ),
                ],
              ),
            ),
          ],
          if (error != null) ...[
            const SizedBox(height: 8),
            Text(
              error,
              style: const TextStyle(color: EskoliaTokens.pink, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}

class _PlayButton extends StatelessWidget {
  const _PlayButton({
    required this.playing,
    required this.loading,
    required this.onTap,
  });

  final bool playing;
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: loading ? null : onTap,
        borderRadius: BorderRadius.circular(26),
        child: Container(
          width: 52,
          height: 52,
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
                  padding: EdgeInsets.all(15),
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: Colors.white,
                  ),
                )
              : Icon(
                  playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 30,
                ),
        ),
      ),
    );
  }
}
