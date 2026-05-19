import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/services/asset_cache_service.dart';

import '../../../shared/widgets/eskolia_lesson_markdown.dart';

const Color _dlgSurface = Color(0xFF1E293B);
const Color _dlgSlate = Color(0xFF94A3B8);
const Color _dlgAccent = Color(0xFF6C63FF);

/// Popup « mini-formation » : markdown embarqué + lien optionnel vers une ressource officielle.
Future<void> showDocsMiniCourseDialog(
  BuildContext context, {
  required String title,
  required String assetPath,
  String? officialUrl,
  String? officialLinkLabel,
}) async {
  await showDialog<void>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        backgroundColor: _dlgSurface.withValues(alpha: 0.98),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
        ),
        title: Row(
          children: [
            Icon(Icons.school_outlined, color: _dlgAccent, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420, maxHeight: 460),
          child: FutureBuilder<String>(
            future: AssetCacheService.loadString(assetPath),
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: _dlgAccent,
                      strokeWidth: 2,
                    ),
                  ),
                );
              }
              if (snap.hasError) {
                return Text(
                  'Impossible de charger la formation.\n${snap.error}',
                  style: TextStyle(color: Colors.red.shade200, fontSize: 13),
                );
              }
              final md = snap.data ?? '';
              return SingleChildScrollView(
                child: EskoliaLessonMarkdown(
                  data: md,
                  lessonAssetPath: assetPath,
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Fermer',
              style: TextStyle(color: _dlgSlate.withValues(alpha: 0.9)),
            ),
          ),
          if (officialUrl != null && officialLinkLabel != null)
            FilledButton.icon(
              onPressed: () async {
                Navigator.pop(ctx);
                final uri = Uri.parse(officialUrl);
                final ok =
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                if (context.mounted && !ok) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Impossible d’ouvrir le lien."),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.open_in_new_rounded, size: 18),
              label: Text(officialLinkLabel),
              style: FilledButton.styleFrom(
                backgroundColor: _dlgAccent,
                foregroundColor: Colors.white,
              ),
            ),
        ],
      );
    },
  );
}
