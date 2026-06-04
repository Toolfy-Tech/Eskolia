// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:html' as html;

/// Lecteur audio web via HTMLAudioElement — contourne les limitations
/// de AudioContext (audioplayers v6) pour les sources AAC/m4a.
class WebPodcastPlayer {
  html.AudioElement? _audio;
  final List<StreamSubscription<dynamic>> _subs = [];

  Future<void> play(
    String url, {
    required void Function(bool playing) onPlayState,
    required void Function(Duration) onPosition,
    required void Function(Duration) onDuration,
    required void Function() onComplete,
    required void Function(String) onError,
  }) async {
    _clear();
    final el = html.AudioElement(url);
    _audio = el;

    _subs.add(el.onPlay.listen((_) => onPlayState(true)));
    _subs.add(el.onPause.listen((_) => onPlayState(false)));
    _subs.add(el.onTimeUpdate.listen((_) {
      onPosition(Duration(milliseconds: (el.currentTime * 1000).round()));
    }));
    _subs.add(el.onDurationChange.listen((_) {
      final d = el.duration;
      if (d.isFinite && d > 0) {
        onDuration(Duration(milliseconds: (d * 1000).round()));
      }
    }));
    _subs.add(el.onEnded.listen((_) {
      onPlayState(false);
      onComplete();
    }));
    _subs.add(el.onError.listen((_) {
      onError('Lecture impossible. Verifie ta connexion.');
    }));

    await el.play();
  }

  Future<void> pause() async => _audio?.pause();

  Future<void> resume() async => await _audio?.play();

  Future<void> seek(Duration d) async {
    if (_audio != null) _audio!.currentTime = d.inMilliseconds / 1000.0;
  }

  void stop() {
    _audio?.pause();
    if (_audio != null) _audio!.currentTime = 0;
  }

  void dispose() => _clear();

  void _clear() {
    for (final s in _subs) {
      s.cancel();
    }
    _subs.clear();
    _audio?.pause();
    _audio = null;
  }
}
