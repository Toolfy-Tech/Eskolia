import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'podcast_blob_stub.dart'
    if (dart.library.html) 'podcast_blob_web.dart';
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
  AudioPlayer? _player;
  final List<StreamSubscription<dynamic>> _subs = [];

  final _webPlayer = WebPodcastPlayer();

  @override
  PodcastPlayerState build() {
    if (!kIsWeb) {
      _player = AudioPlayer();
      _player!.setReleaseMode(ReleaseMode.stop);

      _subs.add(_player!.onPlayerStateChanged.listen((s) {
        state = state.copyWith(playState: s, loading: false);
      }));
      _subs.add(_player!.onDurationChanged.listen((d) {
        state = state.copyWith(duration: d);
      }));
      _subs.add(_player!.onPositionChanged.listen((p) {
        state = state.copyWith(position: p);
      }));
      _subs.add(_player!.onPlayerComplete.listen((_) {
        state = state.copyWith(
          playState: PlayerState.completed,
          position: Duration.zero,
          loading: false,
        );
      }));
    }

    ref.onDispose(() {
      for (final s in _subs) {
        s.cancel();
      }
      _subs.clear();
      _player?.dispose();
      _webPlayer.dispose();
    });

    return const PodcastPlayerState();
  }

  Future<void> play(Podcast podcast) async {
    if (state.podcast?.url == podcast.url) {
      if (state.isPlaying) {
        _pauseAudio();
      } else {
        _resumeAudio();
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

    if (kIsWeb) {
      try {
        _webPlayer.stop();
        await _webPlayer.play(
          podcast.url,
          onPlayState: (playing) {
            state = state.copyWith(
              playState: playing ? PlayerState.playing : PlayerState.paused,
              loading: false,
            );
          },
          onPosition: (pos) {
            state = state.copyWith(position: pos);
          },
          onDuration: (dur) {
            state = state.copyWith(duration: dur);
          },
          onComplete: () {
            state = state.copyWith(
              playState: PlayerState.completed,
              position: Duration.zero,
              loading: false,
            );
          },
          onError: (msg) {
            state = state.copyWith(loading: false, error: msg);
          },
        );
      } catch (e) {
        debugPrint('[PodcastPlayer.play] error=$e url=${podcast.url}');
        state = state.copyWith(
          loading: false,
          error: 'Lecture impossible. Verifie ta connexion.',
        );
      }
    } else {
      try {
        await _player!.play(UrlSource(podcast.url));
      } catch (e) {
        debugPrint('[PodcastPlayer.play] error=$e url=${podcast.url}');
        state = state.copyWith(
          loading: false,
          error: 'Lecture impossible. Verifie ta connexion.',
        );
      }
    }
  }

  void _pauseAudio() {
    if (kIsWeb) {
      _webPlayer.pause();
    } else {
      _player?.pause();
    }
  }

  void _resumeAudio() {
    if (kIsWeb) {
      _webPlayer.resume();
    } else {
      _player?.resume();
    }
  }

  Future<void> seek(Duration d) async {
    if (kIsWeb) {
      await _webPlayer.seek(d);
    } else {
      await _player?.seek(d);
    }
  }

  void dismiss() {
    if (kIsWeb) {
      _webPlayer.stop();
    } else {
      _player?.stop();
    }
    state = const PodcastPlayerState();
  }
}

final podcastPlayerProvider =
    NotifierProvider<PodcastPlayerNotifier, PodcastPlayerState>(
  PodcastPlayerNotifier.new,
);
