import 'package:flutter/material.dart';
import '../../parcours/data/tip_quiz_catalog.dart';

/// Filtre banque de questions : Curriculum (Optimus), Terrain (prof) ou Labo (communauté).
class QuizCatalogTrackSelector extends StatelessWidget {
  const QuizCatalogTrackSelector({
    super.key,
    required this.value,
    required this.onChanged,
    this.dense = false,
  });

  final QuizCatalogTrack value;
  final ValueChanged<QuizCatalogTrack> onChanged;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<QuizCatalogTrack>(
      style: ButtonStyle(
        visualDensity:
            dense ? VisualDensity.compact : VisualDensity.standard,
      ),
      segments: const [
        ButtonSegment(
          value: QuizCatalogTrack.optimusOnly,
          label: Text('Curriculum'),
          icon: Icon(Icons.school_rounded, size: 18),
        ),
        ButtonSegment(
          value: QuizCatalogTrack.terrain,
          label: Text('Terrain'),
          icon: Icon(Icons.construction_rounded, size: 18),
        ),
        ButtonSegment(
          value: QuizCatalogTrack.exams,
          label: Text('Examens'),
          icon: Icon(Icons.assignment_turned_in_rounded, size: 18),
        ),
        ButtonSegment(
          value: QuizCatalogTrack.labo,
          label: Text('Labo'),
          icon: Icon(Icons.science_rounded, size: 18),
        ),
        ButtonSegment(
          value: QuizCatalogTrack.teacher,
          label: Text('Prof'),
          icon: Icon(Icons.auto_stories_rounded, size: 18),
        ),
      ],
      selected: {value},
      onSelectionChanged: (s) {
        onChanged(s.first);
      },
    );
  }
}
