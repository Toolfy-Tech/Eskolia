import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'podcast_model.dart';

class PodcastPlayerState {
  const PodcastPlayerState({
    this.podcast,
    this.playState = PlayerState.stopped,
    this.position = Duration.zero,
    this.duration,
    this.loading = false,
    this.error,
  });

  final Podcast? podcast;
  final PlayerState playState;
  final Duration position;
  final Duration? duration;
  final bool loading;
  final String? error;

  bool get isPlaying => playState == PlayerState.playing;
  bool get hasAudio => podcast != null;

  PodcastPlayerState copyWith({
    Podcast? podcast,
    bool clearPodcast = false,
    PlayerState? playState,
    Duration? position,
    Duration? duration,
    bool clearDuration = false,
    bool? loading,
    String? error,
    bool clearError = false,
  }) {
    return PodcastPlayerState(
      podcast: clearPodcast ? null : (podcast ?? this.podcast),
      playState: playState ?? this.playState,
      position: position ?? this.position,
      duration: clearDuration ? null : (duration ?? this.duration),
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class PodcastPlayerNotifier extends Notifier<PodcastPlayerState> {
  late final AudioPlayer _player;
  final List<StreamSubscription<dynamic>> _subs = [];

  @override
  PodcastPlayerState build() {
    _player = AudioPlayer();
    _player.setReleaseMode(ReleaseMode.stop);

    _subs.add(_player.onPlayerStateChanged.listen((s) {
      state = state.copyWith(playState: s, loading: false);
    }));
    _subs.add(_player.onDurationChanged.listen((d) {
      state = state.copyWith(duration: d);
    }));
    _subs.add(_player.onPositionChanged.listen((p) {
      state = state.copyWith(position: p);
    }));
    _subs.add(_player.onPlayerComplete.listen((_) {
      state = state.copyWith(
        playState: PlayerState.completed,
        position: Duration.zero,
        loading: false,
      );
    }));

    ref.onDispose(() {
      for (final s in _subs) {
        s.cancel();
      }
      _subs.clear();
      _player.dispose();
    });

    return const PodcastPlayerState();
  }

  /// Lecture d'un podcast. Si c'est le même podcast, bascule play/pause.
  /// Si c'est un nouveau podcast, arrête le précédent et démarre le nouveau.
  Future<void> play(Podcast podcast) async {
    if (state.podcast?.url == podcast.url) {
      if (state.isPlaying) {
        await _player.pause();
      } else {
        await _player.resume();
      }
      return;
    }
    state = state.copyWith(
      podcast: podcast,
      loading: true,
      clearError: true,
      position: Duration.zero,
      clearDuration: true,
    );
    try {
      await _player.play(UrlSource(podcast.url));
    } catch (_) {
      state = state.copyWith(loading: false, error: 'Lecture impossible. Verifie ta connexion.');
    }
  }

  Future<void> seek(Duration d) async {
    await _player.seek(d);
  }

  void dismiss() {
    _player.stop();
    state = const PodcastPlayerState();
  }
}

final podcastPlayerProvider =
    NotifierProvider<PodcastPlayerNotifier, PodcastPlayerState>(
  PodcastPlayerNotifier.new,
);
