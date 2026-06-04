// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';

String createAudioBlobUrl(Uint8List bytes) =>
    html.Url.createObjectUrl(html.Blob([bytes], 'audio/mp4'));

void revokeAudioBlobUrl(String url) => html.Url.revokeObjectUrl(url);
