// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:ui_web' as ui;

import 'package:flutter/widgets.dart';

String createBlobUrl(Uint8List bytes, String mimeType) {
  final blob = html.Blob([bytes], mimeType);
  return html.Url.createObjectUrl(blob);
}

void revokeBlobUrl(String url) => html.Url.revokeObjectUrl(url);

// platformViewRegistry allows only one factory per viewId — guard against
// redundant build() calls that would throw "already registered".
final _registeredViews = <String>{};

Widget buildPdfViewer(String blobUrl, String viewId) {
  if (_registeredViews.add(viewId)) {
    ui.platformViewRegistry.registerViewFactory(viewId, (_) {
      return html.IFrameElement()
        ..src = blobUrl
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%';
    });
  }
  return HtmlElementView(viewType: viewId);
}

Widget buildVideoViewer(String blobUrl, String viewId) {
  if (_registeredViews.add(viewId)) {
    ui.platformViewRegistry.registerViewFactory(viewId, (_) {
      return html.VideoElement()
        ..src = blobUrl
        ..controls = true
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.backgroundColor = '#000000';
    });
  }
  return HtmlElementView(viewType: viewId);
}
