// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html show Blob, Url, AnchorElement;
import 'dart:convert';
import 'dart:js' as js;
import 'dart:js_util' as js_util;

import 'package:flutter/foundation.dart';

enum EskoliaFolder {
  quiz('Quiz'),
  flashcards('Flashcards'),
  cours('Cours'),
  bilans('Bilans'),
  profil('Profil');

  const EskoliaFolder(this.folderName);
  final String folderName;
}

class EskoliaFolderService {
  EskoliaFolderService._();
  static final EskoliaFolderService instance = EskoliaFolderService._();

  bool get isSupported {
    try {
      final result = js.context['EskoliaFS'].callMethod('isSupported', []);
      return result is bool ? result : false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> pickFolder() async {
    if (!isSupported) return false;
    try {
      return await js_util.promiseToFuture<bool>(
        js.context['EskoliaFS'].callMethod('pickFolder', []),
      );
    } catch (_) {
      return false;
    }
  }

  Future<bool> hasFolder() async {
    if (!isSupported) return false;
    try {
      return await js_util.promiseToFuture<bool>(
        js.context['EskoliaFS'].callMethod('hasFolder', []),
      );
    } catch (_) {
      return false;
    }
  }

  Future<String?> getFolderName() async {
    if (!isSupported) return null;
    try {
      final result = await js_util.promiseToFuture<dynamic>(
        js.context['EskoliaFS'].callMethod('getFolderName', []),
      );
      return result is String ? result : null;
    } catch (_) {
      return null;
    }
  }

  /// Saves [content] to [folder]/[filename] in the Eskolia directory.
  /// Falls back to a browser download if the API is unavailable or no folder
  /// has been configured.
  Future<void> saveFile(
    EskoliaFolder folder,
    String filename,
    String content, {
    String mimeType = 'application/octet-stream',
  }) async {
    if (isSupported) {
      try {
        final hasFol = await hasFolder();
        if (hasFol) {
          await js_util.promiseToFuture<void>(
            js.context['EskoliaFS'].callMethod(
              'saveFile',
              [folder.folderName, filename, content],
            ),
          );
          return;
        }
      } catch (e) {
        debugPrint('[EskoliaFolderService.saveFile] $e');
      }
    }
    _blobDownload(filename, content, mimeType);
  }

  Future<List<String>> listFiles(EskoliaFolder folder) async {
    if (!isSupported) return [];
    try {
      final result = await js_util.promiseToFuture<dynamic>(
        js.context['EskoliaFS'].callMethod('listFiles', [folder.folderName]),
      );
      if (result is List) {
        return result.map((e) => e.toString()).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<String?> readFile(EskoliaFolder folder, String filename) async {
    if (!isSupported) return null;
    try {
      final result = await js_util.promiseToFuture<dynamic>(
        js.context['EskoliaFS']
            .callMethod('readFile', [folder.folderName, filename]),
      );
      return result is String ? result : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> forgetFolder() async {
    if (!isSupported) return;
    try {
      await js_util.promiseToFuture<void>(
        js.context['EskoliaFS'].callMethod('forgetFolder', []),
      );
    } catch (e) {
      debugPrint('[EskoliaFolderService.forgetFolder] $e');
    }
  }

  void _blobDownload(String filename, String content, String mimeType) {
    final bytes = utf8.encode(content);
    final blob = html.Blob([bytes], mimeType);
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..click();
    html.Url.revokeObjectUrl(url);
  }
}
