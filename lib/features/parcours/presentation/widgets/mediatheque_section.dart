import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/optimus_content_models.dart';

const Color _violet = Color(0xFF6C63FF);
const Color _cyan = Color(0xFF00BCD4);
const Color _slate = Color(0xFF94A3B8);

class MediathequeSection extends StatefulWidget {
  const MediathequeSection({
    super.key,
    required this.specific,
    this.veille = const [],
    this.title = 'Ressources du module',
    this.initiallyExpanded = false,
  });

  final List<MediathequeItem> specific;
  final List<VeilleItem> veille;
  final String title;
  final bool initiallyExpanded;

  @override
  State<MediathequeSection> createState() => _MediathequeSectionState();
}

class _MediathequeSectionState extends State<MediathequeSection> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  int get _total => widget.specific.length + widget.veille.length;

  @override
  Widget build(BuildContext context) {
    if (_total == 0) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: _violet.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _violet.withValues(alpha: 0.22)),
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
                  Icon(Icons.play_lesson_rounded,
                      color: _violet.withValues(alpha: 0.85), size: 18),
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
                    '$_total lien${_total > 1 ? 's' : ''}',
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
                  Divider(color: _violet.withValues(alpha: 0.18), height: 1),
                  if (widget.specific.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _SectionLabel(label: 'Ressources specifiques', color: _violet),
                    const SizedBox(height: 6),
                    ...widget.specific.map((e) => _ResourceTile(
                          title: e.title,
                          subtitle: e.creator,
                          url: e.url,
                          accent: _violet,
                        )),
                  ],
                  if (widget.veille.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _SectionLabel(label: 'Annuaire de veille', color: _cyan),
                    const SizedBox(height: 6),
                    ...widget.veille.map((e) => _ResourceTile(
                          title: e.title,
                          subtitle: e.description,
                          url: e.url,
                          accent: _cyan,
                        )),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: color.withValues(alpha: 0.85),
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _ResourceTile extends StatelessWidget {
  const _ResourceTile({
    required this.title,
    required this.subtitle,
    required this.url,
    required this.accent,
  });

  final String title;
  final String subtitle;
  final String url;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => launchUrl(Uri.parse(url),
            mode: LaunchMode.externalApplication),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.open_in_new_rounded,
                  size: 14,
                  color: accent.withValues(alpha: 0.70),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.92),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: _slate.withValues(alpha: 0.90),
                        fontSize: 11.5,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
