// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/utils/eskolia_snackbar.dart';
import 'podcast_model.dart';

Future<void> downloadPodcastDirectly(BuildContext context, Podcast podcast) async {
  final safeTitle = podcast.title.replaceAll(RegExp(r"[^\w\s-]"), '').replaceAll(' ', '_');
  final safeName = '${podcast.id}_$safeTitle.m4a';

  if (context.mounted) {
    showEskoliaSnackBar(context, 'Téléchargement de "${podcast.title}" en cours...');
  }

  try {
    // Attempt direct fetch as Blob via Dio
    final dio = Dio();
    final response = await dio.get<List<int>>(
      podcast.url,
      options: Options(responseType: ResponseType.bytes),
    );

    if (response.data != null && response.data!.isNotEmpty) {
      final blob = html.Blob([response.data], 'audio/mp4');
      final blobUrl = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: blobUrl)
        ..setAttribute('download', safeName)
        ..style.display = 'none';
      html.document.body?.children.add(anchor);
      anchor.click();
      anchor.remove();
      html.Url.revokeObjectUrl(blobUrl);

      if (context.mounted) {
        showEskoliaSnackBar(context, 'Podcast "${podcast.title}" téléchargé avec succès !');
      }
      return;
    }
  } catch (e) {
    debugPrint('[PodcastDownloader] Fetch blob error: $e. Fallback to direct anchor.');
  }

  // Fallback: direct anchor with download attribute
  try {
    final anchor = html.AnchorElement(href: podcast.url)
      ..setAttribute('download', safeName)
      ..setAttribute('target', '_blank')
      ..style.display = 'none';
    html.document.body?.children.add(anchor);
    anchor.click();
    anchor.remove();
  } catch (e) {
    if (context.mounted) {
      launchUrl(Uri.parse(podcast.url), mode: LaunchMode.externalApplication);
    }
  }
}
