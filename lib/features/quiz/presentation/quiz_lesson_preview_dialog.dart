import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/asset_cache_service.dart';

import '../../../shared/widgets/eskolia_lesson_markdown.dart';
import '../../parcours/data/parcours_repository.dart';
import '../../../core/constants/eskolia_tokens.dart';

/// Aperçu markdown du chapitre + lien vers le cours complet ([ChapterLessonScreen]).
Future<void> showQuizLessonPreviewDialog(
  BuildContext context,
  String moduleId,
) async {
  final mod = ParcoursRepository.moduleById(moduleId);
  final path = mod?.lessonAssetPath;
  final title = mod?.title ?? 'Cours';
  if (path == null || path.isEmpty) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Pas de fiche cours liée à ce chapitre pour l’instant.',
          ),
        ),
      );
    }
    return;
  }
  await showDialog<void>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        backgroundColor: EskoliaTokens.surface2.withValues(alpha: 0.98),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
        ),
        title: Row(
          children: [
            Icon(Icons.menu_book_outlined, color: EskoliaTokens.violet, size: 22),
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
          constraints: const BoxConstraints(maxWidth: 420, maxHeight: 420),
          child: FutureBuilder<String>(
            future: AssetCacheService.loadString(path),
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: EskoliaTokens.violet,
                      strokeWidth: 2,
                    ),
                  ),
                );
              }
              if (snap.hasError) {
                return Text(
                  'Impossible de charger la fiche.\n${snap.error}',
                  style: TextStyle(color: Colors.red.shade200, fontSize: 13),
                );
              }
              final md = snap.data ?? '';
              return SingleChildScrollView(
                child: EskoliaLessonMarkdown(
                  data: md,
                  lessonAssetPath: path,
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
              style: TextStyle(color: EskoliaTokens.textSecondary.withValues(alpha: 0.9)),
            ),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              context.push('/cours/$moduleId');
            },
            icon: const Icon(Icons.open_in_new_rounded, size: 18),
            label: const Text('Cours complet'),
            style: FilledButton.styleFrom(
              backgroundColor: EskoliaTokens.violet,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      );
    },
  );
}
