import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/eskolia_tokens.dart';
import '../../core/constants/typography.dart';
import '../../core/theme/eskolia_visual.dart';

/// Rendu Markdown pour les leçons : plus de `**` / `####` visibles, style aligné maquettes.
class EskoliaLessonMarkdown extends StatelessWidget {
  const EskoliaLessonMarkdown({
    super.key,
    required this.data,
    this.lessonAssetPath,
  });

  final String data;

  /// Chemin bundle du `.md` (ex. `data/curriculum/.../chapter.md`) pour résoudre `../images/...`.
  final String? lessonAssetPath;

  static String? _resolveBundledImagePath(String? lessonPath, String src) {
    if (lessonPath == null || lessonPath.isEmpty) return null;
    final s = src.trim();
    if (s.startsWith('http://') || s.startsWith('https://')) return null;
    final trimmed = lessonPath.trim();
    final lastSlash = trimmed.lastIndexOf('/');
    if (lastSlash <= 0) return null;
    final dir = trimmed.substring(0, lastSlash);
    final segments = dir.split('/').where((e) => e.isNotEmpty).toList();
    var rel = s;
    if (rel.startsWith('./')) rel = rel.substring(2);
    for (final part in rel.split('/')) {
      if (part.isEmpty || part == '.') continue;
      if (part == '..') {
        if (segments.isNotEmpty) segments.removeLast();
      } else {
        segments.add(part);
      }
    }
    return segments.join('/');
  }

  static MarkdownStyleSheet _sheet() {
    final body = EskoliaTypography.body(EskoliaTokens.textPrimary.withValues(alpha: 0.9));
    final paragraph = body.copyWith(height: 1.58, fontSize: 15);
    final codeText = GoogleFonts.jetBrainsMono(
      fontSize: 12.5,
      height: 1.45,
      color: EskoliaVisual.neonCyanSoft,
    );

    return MarkdownStyleSheet(
      textAlign: WrapAlignment.start,
      h1Align: WrapAlignment.center,
      h2Align: WrapAlignment.center,
      h1: EskoliaTypography.h1().copyWith(
        fontSize: 22,
        height: 1.22,
        color: EskoliaTokens.textPrimary,
      ),
      h1Padding: const EdgeInsets.only(top: 4, bottom: 18),
      h2: EskoliaTypography.h2().copyWith(
        fontSize: 17,
        height: 1.28,
        color: EskoliaTokens.textPrimary.withValues(alpha: 0.96),
        fontWeight: FontWeight.w600,
      ),
      h2Padding: const EdgeInsets.only(top: 8, bottom: 14),
      h3Align: WrapAlignment.start,
      h3: EskoliaTypography.h3(EskoliaVisual.neonCyanSoft).copyWith(
        fontSize: 16,
        height: 1.3,
      ),
      h3Padding: const EdgeInsets.only(top: 22, bottom: 10),
      h4Align: WrapAlignment.start,
      h4: EskoliaTypography.label(EskoliaTokens.textPrimary.withValues(alpha: 0.95)).copyWith(
        fontSize: 14,
        height: 1.35,
        fontWeight: FontWeight.w700,
        color: EskoliaVisual.neonViolet,
      ),
      h4Padding: const EdgeInsets.only(top: 14, bottom: 8),
      h5Align: WrapAlignment.start,
      h5: paragraph.copyWith(
        fontWeight: FontWeight.w700,
        color: EskoliaTokens.textSecondary,
        fontSize: 13,
      ),
      h5Padding: const EdgeInsets.only(top: 10, bottom: 6),
      h6Align: WrapAlignment.start,
      h6: paragraph.copyWith(
        fontWeight: FontWeight.w600,
        color: EskoliaTokens.textSecondary,
        fontSize: 12.5,
      ),
      h6Padding: const EdgeInsets.only(top: 8, bottom: 4),
      p: paragraph,
      pPadding: const EdgeInsets.only(bottom: 10),
      strong: paragraph.copyWith(
        fontWeight: FontWeight.w700,
        color: EskoliaTokens.textPrimary,
      ),
      em: paragraph.copyWith(
        fontStyle: FontStyle.italic,
        color: EskoliaTokens.textSecondary,
      ),
      a: paragraph.copyWith(
        color: EskoliaVisual.neonCyan,
        decoration: TextDecoration.underline,
        decorationColor: EskoliaVisual.neonCyan.withValues(alpha: 0.45),
      ),
      code: codeText.copyWith(
        backgroundColor: EskoliaTokens.surface2,
      ),
      codeblockDecoration: BoxDecoration(
        color: EskoliaTokens.bgBase,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: EskoliaTokens.borderSubtle),
      ),
      codeblockPadding: const EdgeInsets.all(14),
      blockSpacing: 10,
      listIndent: 22,
      listBullet: paragraph.copyWith(
        color: EskoliaVisual.neonCyanSoft,
        fontWeight: FontWeight.w700,
      ),
      listBulletPadding: const EdgeInsets.only(right: 8),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: EskoliaTokens.borderGlass,
            width: 1,
          ),
        ),
      ),
      blockquote: paragraph.copyWith(color: EskoliaTokens.textSecondary),
      blockquoteDecoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: EskoliaVisual.neonViolet.withValues(alpha: 0.75),
            width: 3,
          ),
        ),
        color: EskoliaTokens.textPrimary.withValues(alpha: 0.04),
      ),
      blockquotePadding: const EdgeInsets.fromLTRB(14, 10, 12, 10),
      tableHead: paragraph.copyWith(
        fontWeight: FontWeight.w700,
        color: EskoliaTokens.textPrimary,
        fontSize: 13.5,
      ),
      tableBody: paragraph.copyWith(fontSize: 13.5),
      tableBorder: TableBorder.all(
        color: EskoliaTokens.borderGlass,
      ),
      tableCellsPadding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      tableScrollbarThumbVisibility: true,
    );
  }

  static Future<void> openMarkdownLink(String? href) async {
    if (href == null || href.isEmpty) return;
    final uri = Uri.tryParse(href);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
      data: data,
      selectable: true,
      styleSheet: _sheet(),
      onTapLink: (text, href, title) => openMarkdownLink(href),
      softLineBreak: true,
      sizedImageBuilder: (config) {
        final src = config.uri.toString();
        final assetKey = _resolveBundledImagePath(lessonAssetPath, src);
        if (assetKey != null) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Image.asset(
              assetKey,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Image introuvable : $assetKey',
                  style: TextStyle(
                    color: EskoliaTokens.textPrimary.withValues(alpha: 0.55),
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }
        if (src.startsWith('http://') || src.startsWith('https://')) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Image.network(
              src,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
