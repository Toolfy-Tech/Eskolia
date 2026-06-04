import 'dart:math' show Random;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/optimus_content_models.dart';
import '../../../../core/constants/eskolia_tokens.dart';
import 'support_media.dart';

const Color _orange = EskoliaTokens.orange;
const Color _slate = EskoliaTokens.textSecondary;

/// Affiche les supports directement dans le cours sous forme de slides.
/// Si plusieurs items : navigation précédent/suivant + indicateurs de page.
class SupportSection extends StatefulWidget {
  const SupportSection({
    super.key,
    required this.items,
    this.title = 'Support de cours',
    this.initiallyExpanded = false,
  });

  final List<SupportItem> items;
  final String title;
  final bool initiallyExpanded;

  @override
  State<SupportSection> createState() => _SupportSectionState();
}

class _SupportSectionState extends State<SupportSection> {
  int _index = 0;

  SupportItem get _current => widget.items[_index];
  bool get _hasMany => widget.items.length > 1;

  void _prev() {
    if (_index > 0) setState(() => _index--);
  }

  void _next() {
    if (_index < widget.items.length - 1) setState(() => _index++);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(
              title: widget.title,
              current: _index,
              total: widget.items.length,
              onPrev: _hasMany && _index > 0 ? _prev : null,
              onNext: _hasMany && _index < widget.items.length - 1 ? _next : null,
            ),
            const SizedBox(height: 12),
            Container(
              width: w,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 260),
                    transitionBuilder: (child, anim) =>
                        FadeTransition(opacity: anim, child: child),
                    child: _MediaView(
                      key: ValueKey('${_index}_${_current.url}'),
                      item: _current,
                      width: w,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _TypeBadge(type: _current.type),
                        const SizedBox(height: 6),
                        Text(
                          _current.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (_current.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            _current.description,
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
            ),
            if (_hasMany) ...[
              const SizedBox(height: 10),
              _DotsRow(
                count: widget.items.length,
                current: _index,
                onTap: (i) => setState(() => _index = i),
              ),
            ],
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.current,
    required this.total,
    this.onPrev,
    this.onNext,
  });

  final String title;
  final int current;
  final int total;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

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
        if (total > 1) ...[
          _NavBtn(icon: Icons.chevron_left_rounded, onTap: onPrev),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              '${current + 1} / $total',
              style: TextStyle(
                color: _slate,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _NavBtn(icon: Icons.chevron_right_rounded, onTap: onNext),
        ] else
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _orange.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '1 fichier',
              style: TextStyle(
                  color: _orange,
                  fontSize: 11,
                  fontWeight: FontWeight.w700),
            ),
          ),
      ],
    );
  }
}

class _NavBtn extends StatelessWidget {
  const _NavBtn({required this.icon, this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: onTap != null
              ? _orange.withValues(alpha: 0.12)
              : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: 18,
          color: onTap != null
              ? _orange.withValues(alpha: 0.9)
              : _slate.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}

class _DotsRow extends StatelessWidget {
  const _DotsRow(
      {required this.count, required this.current, required this.onTap});
  final int count;
  final int current;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == current;
        return GestureDetector(
          onTap: () => onTap(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: active ? 16 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: active
                  ? _orange
                  : Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Affichage du media — viewId stable pendant toute la vie du widget.
// Recréé (via ValueKey dans AnimatedSwitcher) à chaque changement d'item.
// ─────────────────────────────────────────────────────────────────────────────

class _MediaView extends StatefulWidget {
  const _MediaView({super.key, required this.item, required this.width});
  final SupportItem item;
  final double width;

  @override
  State<_MediaView> createState() => _MediaViewState();
}

class _MediaViewState extends State<_MediaView> {
  late final String _viewId;

  @override
  void initState() {
    super.initState();
    _viewId = 'eskolia-support-${Random().nextInt(999999999)}';
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return _fallback();
    return switch (widget.item.type) {
      'video' => _video(),
      'pdf'   => _pdf(),
      _       => _image(),
    };
  }

  Widget _image() {
    final h = _imageHeight(widget.width);
    return GestureDetector(
      onTap: () => launchUrl(
        Uri.parse(widget.item.url),
        webOnlyWindowName: '_blank',
      ),
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          SizedBox(
            width: widget.width,
            height: h,
            child: buildImageViewer(widget.item.url, _viewId),
          ),
          Container(
            margin: const EdgeInsets.all(10),
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.60),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.open_in_new_rounded,
                    color: Colors.white, size: 13),
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
    // Ratio 16:9 basé sur la largeur réelle du conteneur.
    final h = (widget.width * 9 / 16).clamp(180.0, 400.0);
    return SizedBox(
      width: widget.width,
      height: h,
      child: buildVideoViewer(widget.item.url, _viewId),
    );
  }

  Widget _pdf() {
    return SizedBox(
      width: widget.width,
      height: 560,
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

  /// Hauteur de l'image : environ 60 % de la largeur, entre 220 et 480 px.
  static double _imageHeight(double w) => (w * 0.6).clamp(220.0, 480.0);
}

// ─────────────────────────────────────────────────────────────────────────────

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
