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

Widget buildImageViewer(String url, String viewId) {
  if (_registeredViews.add(viewId)) {
    ui.platformViewRegistry.registerViewFactory(viewId, (_) {
      return html.ImageElement()
        ..src = url
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'contain'
        ..style.display = 'block';
    });
  }
  return HtmlElementView(viewType: viewId);
}

Widget buildPdfViewer(String url, String viewId) {
  if (_registeredViews.add(viewId)) {
    // Google Docs Viewer contourne Content-Disposition: attachment de GitHub Releases.
    final viewerUrl =
        'https://docs.google.com/viewer?url=${Uri.encodeComponent(url)}&embedded=true';
    ui.platformViewRegistry.registerViewFactory(viewId, (_) {
      return html.IFrameElement()
        ..src = viewerUrl
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%';
    });
  }
  return HtmlElementView(viewType: viewId);
}

Widget buildVideoViewer(String url, String viewId) {
  if (_registeredViews.add(viewId)) {
    ui.platformViewRegistry.registerViewFactory(viewId, (_) {
      return html.VideoElement()
        ..src = url
        ..controls = true
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.backgroundColor = '#000000';
    });
  }
  return HtmlElementView(viewType: viewId);
}
