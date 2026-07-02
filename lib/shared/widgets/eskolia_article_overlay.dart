import 'dart:math' show Random;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/eskolia_tokens.dart';
import '../../features/parcours/presentation/widgets/support_media.dart';

/// Overlay de lecture d'article web pour Eskolia.
/// Intègre l'article dans un IFrame sur le web avec un bouton de secours pour l'ouverture externe.
class EskoliaArticleOverlay extends StatefulWidget {
  const EskoliaArticleOverlay({
    super.key,
    required this.title,
    required this.url,
  });

  final String title;
  final String url;

  @override
  State<EskoliaArticleOverlay> createState() => _EskoliaArticleOverlayState();
}

class _EskoliaArticleOverlayState extends State<EskoliaArticleOverlay> {
  final String _viewId = 'eskolia-article-${Random().nextInt(999999999)}';

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    final bool isMobile = width <= 600;

    final String embedUrl = widget.url.startsWith('http')
        ? 'https://txtify.it/${widget.url}'
        : widget.url;

    final Widget iframeWidget = SizedBox(
      width: double.infinity,
      height: isMobile ? 420 : 520,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          color: Colors.black.withValues(alpha: 0.15),
          child: buildIFrameViewer(embedUrl, _viewId),
        ),
      ),
    );

    final Widget header = Row(
      children: [
        const Icon(Icons.article_rounded, color: EskoliaTokens.cyan, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            widget.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            Icons.close_rounded,
            color: Colors.white.withValues(alpha: 0.6),
            size: 22,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );

    final Widget footer = Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Article converti en mode lecture épuré. Vous pouvez également ouvrir la page d\'origine complète ci-dessous.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.45),
              fontSize: 11,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: TextButton.icon(
              onPressed: () => launchUrl(
                Uri.parse(widget.url),
                mode: LaunchMode.externalApplication,
              ),
              icon: const Icon(
                Icons.open_in_new_rounded,
                size: 15,
                color: EskoliaTokens.cyan,
              ),
              label: const Text(
                'Ouvrir l\'article complet',
                style: TextStyle(
                  color: EskoliaTokens.cyan,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                backgroundColor: EskoliaTokens.cyan.withValues(alpha: 0.08),
              ),
            ),
          ),
        ],
      ),
    );

    if (isMobile) {
      // BottomSheet Layout for mobile
      return ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + MediaQuery.paddingOf(context).bottom),
            decoration: BoxDecoration(
              color: EskoliaTokens.surface1.withValues(alpha: 0.90),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.10),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                header,
                const SizedBox(height: 14),
                iframeWidget,
                footer,
              ],
            ),
          ),
        ),
      );
    }

    // Dialog Layout for Desktop/Web
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800), // Légèrement plus large pour les articles
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: EskoliaTokens.surface1.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: EskoliaTokens.violet.withValues(alpha: 0.15),
                      blurRadius: 30,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    header,
                    const SizedBox(height: 14),
                    iframeWidget,
                    footer,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Ouvre l'overlay article de manière responsive.
void showEskoliaArticleOverlay(
  BuildContext context, {
  required String title,
  required String url,
}) {
  final double width = MediaQuery.sizeOf(context).width;
  final bool isMobile = width <= 600;

  if (isMobile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (context) => EskoliaArticleOverlay(title: title, url: url),
    );
  } else {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (context) => EskoliaArticleOverlay(title: title, url: url),
    );
  }
}
