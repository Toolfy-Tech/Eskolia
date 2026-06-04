import 'dart:math' show Random;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/optimus_content_models.dart';
import '../../../../core/constants/eskolia_tokens.dart';
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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildMedia(context),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TypeBadge(type: widget.item.type),
                const SizedBox(height: 6),
                Text(
                  widget.item.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (widget.item.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.item.description,
                    style: TextStyle(
                      color: _slate.withValues(alpha: 0.85),
                      fontSize: 11.5,
                      height: 1.35,
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
    return GestureDetector(
      onTap: () => launchUrl(
        Uri.parse(widget.item.url),
        webOnlyWindowName: '_blank',
      ),
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          SizedBox(height: 260, child: buildImageViewer(widget.item.url, _viewId)),
          Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.60),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.open_in_new_rounded, color: Colors.white, size: 13),
                SizedBox(width: 5),
                Text(
                  'Agrandir',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
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
    return SizedBox(
      height: 220,
      child: buildVideoViewer(widget.item.url, _viewId),
    );
  }

  Widget _pdf() {
    return SizedBox(
      height: 520,
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
