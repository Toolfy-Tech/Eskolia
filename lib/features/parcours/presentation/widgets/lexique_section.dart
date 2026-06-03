import 'package:flutter/material.dart';

import '../../data/optimus_content_models.dart';

const Color _cyan = Color(0xFF00BCD4);
const Color _slate = Color(0xFF94A3B8);

class LexiqueSection extends StatefulWidget {
  const LexiqueSection({
    super.key,
    required this.terms,
    this.title = 'Lexique du module',
    this.initiallyExpanded = false,
  });

  final List<LexiqueEntry> terms;
  final String title;
  final bool initiallyExpanded;

  @override
  State<LexiqueSection> createState() => _LexiqueSectionState();
}

class _LexiqueSectionState extends State<LexiqueSection> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.terms.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: _cyan.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _cyan.withValues(alpha: 0.22)),
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
                  Icon(Icons.menu_book_rounded,
                      color: _cyan.withValues(alpha: 0.85), size: 18),
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
                    '${widget.terms.length} terme${widget.terms.length > 1 ? 's' : ''}',
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
                  Divider(color: _cyan.withValues(alpha: 0.18), height: 1),
                  const SizedBox(height: 10),
                  ...widget.terms.map((e) => _TermTile(entry: e)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TermTile extends StatelessWidget {
  const _TermTile({required this.entry});

  final LexiqueEntry entry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            entry.term,
            style: TextStyle(
              color: _cyan.withValues(alpha: 0.95),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            entry.definition,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.80),
              fontSize: 12.5,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
