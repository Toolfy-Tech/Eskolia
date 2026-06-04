import 'dart:async';
import 'dart:typed_data';

String createAudioBlobUrl(Uint8List bytes) => '';
void revokeAudioBlobUrl(String url) {}

class WebPodcastPlayer {
  Future<void> play(
    String blobUrl, {
    required void Function(bool playing) onPlayState,
    required void Function(Duration) onPosition,
    required void Function(Duration) onDuration,
    required void Function() onComplete,
    required void Function(String) onError,
  }) async {}

  Future<void> pause() async {}
  Future<void> resume() async {}
  Future<void> seek(Duration d) async {}
  void stop() {}
  void dispose() {}
}
