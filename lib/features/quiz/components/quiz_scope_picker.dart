import 'package:flutter/material.dart';

import '../../../core/theme/tip_section_theme.dart';
import '../../parcours/data/tip_quiz_catalog.dart';

const Color _slateLight = Color(0xFF94A3B8);

/// Sélection de Maîtrise par section / chapitre (sources = chemins d'assets JSON).
/// Mode contrôlé : l'état vit dans le parent ([selectedPaths]).
class QuizScopePicker extends StatefulWidget {
  const QuizScopePicker({
    super.key,
    required this.entries,
    required this.selectedPaths,
    required this.onSelectionChanged,
  });

  final List<TipQuizChapterRef> entries;
  final Set<String> selectedPaths;
  final ValueChanged<Set<String>> onSelectionChanged;

  @override
  State<QuizScopePicker> createState() => _QuizScopePickerState();
}

class _QuizScopePickerState extends State<QuizScopePicker> {
  final Set<String> _expanded = {};

  Map<String, List<TipQuizChapterRef>> get _grouped =>
      TipQuizCatalog.groupBySection(widget.entries);

  void _emit(Set<String> next) {
    widget.onSelectionChanged(Set<String>.from(next));
  }

  void _togglePath(Set<String> cur, String path, bool check) {
    final next = Set<String>.from(cur);
    if (check) {
      next.add(path);
    } else {
      next.remove(path);
    }
    _emit(next);
  }

  void _toggleWholeSection(Set<String> cur, String sectionId, bool selectAll) {
    final list = _grouped[sectionId] ?? [];
    final next = Set<String>.from(cur);
    for (final e in list) {
      if (selectAll) {
        next.add(e.quizAssetPath);
      } else {
        next.remove(e.quizAssetPath);
      }
    }
    _emit(next);
  }

  bool _sectionFullySelected(String sectionId, Set<String> sel) {
    final list = _grouped[sectionId] ?? [];
    if (list.isEmpty) return false;
    return list.every((e) => sel.contains(e.quizAssetPath));
  }

  bool _sectionPartiallySelected(String sectionId, Set<String> sel) {
    final list = _grouped[sectionId] ?? [];
    if (list.isEmpty) return false;
    final n = list.where((e) => sel.contains(e.quizAssetPath)).length;
    return n > 0 && n < list.length;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.entries.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'Aucune Maîtrise indexée.',
          style: TextStyle(color: _slateLight),
        ),
      );
    }

    final sel = widget.selectedPaths;
    final keys = _grouped.keys.toList()..sort();

    return ListView.builder(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      itemCount: keys.length + 1,
      itemBuilder: (context, i) {
        if (i == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                _ActionChip(
                  label: 'Tout',
                  onTap: () {
                    _emit(widget.entries.map((e) => e.quizAssetPath).toSet());
                  },
                ),
                const SizedBox(width: 8),
                _ActionChip(
                  label: 'Effacer',
                  onTap: () => _emit({}),
                  dimmed: true,
                ),
              ],
            ),
          );
        }

        final sid = keys[i - 1];
        final list = _grouped[sid]!;
        final title = list.first.sectionTitle;
        final expanded = _expanded.contains(sid);
        final allOn = _sectionFullySelected(sid, sel);
        final partial = _sectionPartiallySelected(sid, sel);
        final colors = TipSectionTheme.colorsFor(sid);
        final selectedCount = list.where((e) => sel.contains(e.quizAssetPath)).length;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _SectionCard(
            sectionId: sid,
            title: title,
            colors: colors,
            expanded: expanded,
            allOn: allOn,
            partial: partial,
            selectedCount: selectedCount,
            totalCount: list.length,
            onHeaderTap: () {
              setState(() {
                if (expanded) {
                  _expanded.remove(sid);
                } else {
                  _expanded.add(sid);
                }
              });
            },
            onSelectAll: () => _toggleWholeSection(sel, sid, !allOn && !partial || partial),
            children: list.map((e) {
              final checked = sel.contains(e.quizAssetPath);
              return _ChapterRow(
                title: e.chapterTitle,
                checked: checked,
                accentColor: colors.primary,
                onTap: () => _togglePath(sel, e.quizAssetPath, !checked),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.sectionId,
    required this.title,
    required this.colors,
    required this.expanded,
    required this.allOn,
    required this.partial,
    required this.selectedCount,
    required this.totalCount,
    required this.onHeaderTap,
    required this.onSelectAll,
    required this.children,
  });

  final String sectionId;
  final String title;
  final ({Color primary, Color secondary, Color glow}) colors;
  final bool expanded;
  final bool allOn;
  final bool partial;
  final int selectedCount;
  final int totalCount;
  final VoidCallback onHeaderTap;
  final VoidCallback onSelectAll;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final hasSel = selectedCount > 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withValues(alpha: 0.04),
        border: Border.all(
          color: hasSel
              ? colors.primary.withValues(alpha: 0.55)
              : Colors.white.withValues(alpha: 0.08),
          width: hasSel ? 1.5 : 1,
        ),
        boxShadow: hasSel
            ? [
                BoxShadow(
                  color: colors.glow.withValues(alpha: 0.15),
                  blurRadius: 12,
                  spreadRadius: -4,
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header row
            InkWell(
              onTap: onHeaderTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    // Color dot
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colors.primary,
                        boxShadow: [
                          BoxShadow(
                            color: colors.glow.withValues(alpha: 0.6),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Title
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    // Badge count
                    if (hasSel)
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: colors.primary.withValues(alpha: 0.2),
                          border: Border.all(
                            color: colors.primary.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Text(
                          '$selectedCount/$totalCount',
                          style: TextStyle(
                            color: colors.secondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    // Select-all checkbox
                    GestureDetector(
                      onTap: onSelectAll,
                      child: Container(
                        width: 22,
                        height: 22,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: allOn
                              ? colors.primary.withValues(alpha: 0.9)
                              : partial
                                  ? colors.primary.withValues(alpha: 0.3)
                                  : Colors.white.withValues(alpha: 0.06),
                          border: Border.all(
                            color: allOn || partial
                                ? colors.primary
                                : Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                        child: allOn
                            ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                            : partial
                                ? Icon(Icons.remove_rounded, size: 14, color: colors.secondary)
                                : null,
                      ),
                    ),
                    // Expand arrow
                    AnimatedRotation(
                      turns: expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.white54,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Chapters
            if (expanded) ...[
              Divider(
                height: 1,
                color: colors.primary.withValues(alpha: 0.2),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: children,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ChapterRow extends StatelessWidget {
  const _ChapterRow({
    required this.title,
    required this.checked,
    required this.accentColor,
    required this.onTap,
  });

  final String title;
  final bool checked;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: checked
                ? accentColor.withValues(alpha: 0.1)
                : Colors.white.withValues(alpha: 0.03),
            border: Border.all(
              color: checked
                  ? accentColor.withValues(alpha: 0.4)
                  : Colors.white.withValues(alpha: 0.06),
            ),
          ),
          child: Row(
            children: [
              // Custom checkbox
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: checked
                      ? accentColor.withValues(alpha: 0.9)
                      : Colors.white.withValues(alpha: 0.05),
                  border: Border.all(
                    color: checked
                        ? accentColor
                        : Colors.white.withValues(alpha: 0.18),
                  ),
                ),
                child: checked
                    ? const Icon(Icons.check_rounded, size: 12, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: checked ? Colors.white : Colors.white60,
                    fontSize: 12,
                    fontWeight: checked ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.label,
    required this.onTap,
    this.dimmed = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: dimmed
              ? Colors.white.withValues(alpha: 0.05)
              : const Color(0xFF6C63FF).withValues(alpha: 0.15),
          border: Border.all(
            color: dimmed
                ? Colors.white.withValues(alpha: 0.12)
                : const Color(0xFF6C63FF).withValues(alpha: 0.4),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: dimmed ? Colors.white54 : const Color(0xFF818CF8),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
