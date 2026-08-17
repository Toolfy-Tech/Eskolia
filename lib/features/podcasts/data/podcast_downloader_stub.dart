import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/utils/eskolia_snackbar.dart';
import 'podcast_model.dart';

Future<void> downloadPodcastDirectly(BuildContext context, Podcast podcast) async {
  try {
    showEskoliaSnackBar(context, 'Téléchargement de "${podcast.title}"...');
    final uri = Uri.parse(podcast.url);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      showEskoliaSnackBar(context, 'Impossible de télécharger le podcast.');
    }
  } catch (e) {
    if (context.mounted) {
      showEskoliaSnackBar(context, 'Erreur lors du téléchargement : $e');
    }
  }
}
