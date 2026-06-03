import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/optimus_content_models.dart';

const Color _orange = Color(0xFFFF9800);
const Color _slate = Color(0xFF94A3B8);

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
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: _orange.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _orange.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: _expanded
                ? const BorderRadius.vertical(top: Radius.circular(14))
                : BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              child: Row(
                children: [
                  Icon(Icons.school_rounded,
                      color: _orange.withValues(alpha: 0.85), size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.95),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    '${widget.items.length} fichier${widget.items.length > 1 ? 's' : ''}',
                    style: TextStyle(color: _slate, fontSize: 12),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 240),
                    child: Icon(Icons.expand_more_rounded,
                        color: _slate, size: 20),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 240),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Divider(color: _orange.withValues(alpha: 0.18), height: 1),
                  const SizedBox(height: 10),
                  ...widget.items.map((e) => _SupportTile(item: e)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SupportTile extends StatelessWidget {
  const _SupportTile({required this.item});

  final SupportItem item;

  static IconData _iconFor(String type) => switch (type) {
        'pdf' => Icons.picture_as_pdf_rounded,
        'video' => Icons.play_circle_rounded,
        _ => Icons.image_rounded,
      };

  static Color _colorFor(String type) => switch (type) {
        'pdf' => const Color(0xFFEF5350),
        'video' => const Color(0xFF42A5F5),
        _ => _orange,
      };

  static String _labelFor(String type) => switch (type) {
        'pdf' => 'PDF',
        'video' => 'Vidéo',
        _ => 'Image',
      };

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(item.type);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => launchUrl(Uri.parse(item.url),
            mode: LaunchMode.externalApplication),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 1),
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_iconFor(item.type), size: 13, color: color),
                    const SizedBox(width: 4),
                    Text(
                      _labelFor(item.type),
                      style: TextStyle(
                        color: color,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.92),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.description,
                      style: TextStyle(
                        color: _slate.withValues(alpha: 0.90),
                        fontSize: 11.5,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 2, left: 8),
                child: Icon(Icons.open_in_new_rounded,
                    size: 13,
                    color: _slate.withValues(alpha: 0.60)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
