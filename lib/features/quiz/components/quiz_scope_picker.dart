import 'package:flutter/material.dart';

import '../../parcours/data/tip_quiz_catalog.dart';

const Color _slateLight = Color(0xFF94A3B8);

/// Sélection de Maîtrise par section / chapitre (sources = chemins d’assets JSON).
/// Mode contrôlé : l’état vit dans le parent ([selectedPaths]).
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

  void _togglePath(Set<String> cur, String path, bool? v) {
    final next = Set<String>.from(cur);
    if (v == true) {
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
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                TextButton(
                  onPressed: () {
                    _emit(widget.entries.map((e) => e.quizAssetPath).toSet());
                  },
                  child: const Text('Tout sélectionner'),
                ),
                TextButton(
                  onPressed: () => _emit({}),
                  child: const Text('Effacer'),
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

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          color: Colors.white.withValues(alpha: 0.04),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: ExpansionTile(
            key: PageStorageKey<String>(sid),
            initiallyExpanded: expanded,
            onExpansionChanged: (v) {
              setState(() {
                if (v) {
                  _expanded.add(sid);
                } else {
                  _expanded.remove(sid);
                }
              });
            },
            title: Text(
              '$title · ${list.length} questionnaire(s)',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            children: [
              CheckboxListTile(
                dense: true,
                tristate: true,
                value: allOn ? true : (partial ? null : false),
                onChanged: (v) {
                  if (v == true) {
                    _toggleWholeSection(sel, sid, true);
                  } else {
                    _toggleWholeSection(sel, sid, false);
                  }
                },
                title: const Text(
                  'Toute la section',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: const Color(0xFF6C63FF),
              ),
              for (final e in list)
                CheckboxListTile(
                  dense: true,
                  value: sel.contains(e.quizAssetPath),
                  onChanged: (v) => _togglePath(sel, e.quizAssetPath, v),
                  title: Text(
                    e.chapterTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: const Color(0xFF6C63FF),
                ),
            ],
          ),
        );
      },
    );
  }
}
