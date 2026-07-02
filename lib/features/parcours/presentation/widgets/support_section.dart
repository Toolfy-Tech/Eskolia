import 'dart:math' show Random;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/optimus_content_models.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/eskolia_tokens.dart';
import '../../../../shared/widgets/eskolia_card.dart';
import 'support_media.dart';

const Color _orange = EskoliaTokens.orange;
const Color _slate = EskoliaTokens.textSecondary;

/// Affiche les supports directement dans le cours — image, vidéo ou PDF intégré.
class SupportSection extends StatelessWidget {
  const SupportSection({
    super.key,
    required this.items,
    this.title = 'Support de cours',
    this.initiallyExpanded = false,
  });

  final List<SupportItem> items;
  final String title;
  // ignore: unused_field — conservé pour compatibilité d'appel
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Header(title: title, count: items.length),
        const SizedBox(height: 14),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _InlineSupport(item: item),
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.count});
  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.school_rounded,
            color: _orange.withValues(alpha: 0.85), size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: _orange.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '$count fichier${count > 1 ? 's' : ''}',
            style: TextStyle(
                color: _orange, fontSize: 11, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _InlineSupport extends StatefulWidget {
  const _InlineSupport({required this.item});
  final SupportItem item;

  @override
  State<_InlineSupport> createState() => _InlineSupportState();
}

class _InlineSupportState extends State<_InlineSupport> {
  final String _viewId =
      'eskolia-support-${Random().nextInt(999999999)}';

  double _getImageHeight(String filename) {
    final name = filename.toLowerCase();
    if (name.contains('etapes') ||
        name.contains('guide') ||
        name.contains('6.regles') ||
        name.contains('veille')) {
      return 550.0;
    }
    return 300.0;
  }

  double _getImageAspectRatio(String filename) {
    final name = filename.toLowerCase();
    if (name.contains('etapes') ||
        name.contains('guide') ||
        name.contains('6.regles') ||
        name.contains('veille')) {
      return 0.67; // Portrait aspect ratio (width / height)
    }
    return 1.77; // Landscape aspect ratio (width / height)
  }

  @override
  Widget build(BuildContext context) {
    return EskoliaCardContent(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildMedia(context),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TypeBadge(type: widget.item.type),
                const SizedBox(height: 8),
                Text(
                  widget.item.title,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (widget.item.description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    widget.item.description,
                    style: TextStyle(
                      color: _slate.withValues(alpha: 0.9),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedia(BuildContext context) {
    if (!kIsWeb) return _fallback();
    return switch (widget.item.type) {
      'video' => _video(),
      'pdf'   => _pdf(),
      _       => _image(context),
    };
  }

  Widget _image(BuildContext context) {
    final double aspect = _getImageAspectRatio(widget.item.filename);
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          barrierColor: Colors.black.withValues(alpha: 0.85),
          builder: (context) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: InteractiveViewer(
                    maxScale: 4.0,
                    child: Center(
                      child: Image.network(
                        widget.item.url,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(color: EskoliaTokens.cyan),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return buildImageViewer(widget.item.url, _viewId);
                        },
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Material(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: const CircleBorder(),
                    child: IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white, size: 24),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          AspectRatio(
            aspectRatio: aspect,
            child: Container(
              color: Colors.black.withValues(alpha: 0.15),
              child: Image.network(
                widget.item.url,
                fit: BoxFit.contain,
                width: double.infinity,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(color: EskoliaTokens.cyan),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return buildImageViewer(widget.item.url, _viewId);
                },
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.70),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white12, width: 0.5),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.open_in_new_rounded, color: Colors.white, size: 12),
                SizedBox(width: 6),
                Text(
                  'Agrandir',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _video() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: buildVideoViewer(widget.item.url, _viewId),
    );
  }

  Widget _pdf() {
    return SizedBox(
      width: double.infinity,
      height: 580,
      child: buildPdfViewer(widget.item.url, _viewId),
    );
  }

  Widget _fallback() {
    final color = widget.item.type == 'pdf'
        ? EskoliaTokens.error
        : widget.item.type == 'video'
            ? EskoliaTokens.info
            : _orange;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 4),
      child: OutlinedButton.icon(
        onPressed: () => launchUrl(Uri.parse(widget.item.url),
            mode: LaunchMode.externalApplication),
        icon: const Icon(Icons.open_in_new_rounded, size: 15),
        label: const Text('Ouvrir'),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color.withValues(alpha: 0.3)),
        ),
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.type});
  final String type;

  static Color _c(String t) => switch (t) {
        'pdf'   => EskoliaTokens.error,
        'video' => EskoliaTokens.info,
        _       => _orange,
      };
  static IconData _i(String t) => switch (t) {
        'pdf'   => Icons.picture_as_pdf_rounded,
        'video' => Icons.play_circle_rounded,
        _       => Icons.image_rounded,
      };
  static String _l(String t) => switch (t) {
        'pdf'   => 'PDF',
        'video' => 'Video',
        _       => 'Image',
      };

  @override
  Widget build(BuildContext context) {
    final c = _c(type);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_i(type), size: 11, color: c),
          const SizedBox(width: 4),
          Text(_l(type),
              style: TextStyle(
                  color: c, fontSize: 10, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
