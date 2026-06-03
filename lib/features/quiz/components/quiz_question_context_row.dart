import 'package:flutter/material.dart';

import '../../../core/constants/eskolia_tokens.dart';
import '../../../core/theme/eskolia_visual.dart';
import '../models/quiz_models.dart';

/// Libellé français pour le badge de difficulté (JSON / bucket normalisé).
String quizDifficultyLabelFr(String difficultyBucket) {
  switch (difficultyBucket) {
    case 'facile':
      return 'Facile';
    case 'difficile':
      return 'Difficile';
    case 'moyen':
      return 'Moyen';
    default:
      return 'Niveau non précisé';
  }
}

Color _difficultyAccent(String bucket) {
  switch (bucket) {
    case 'facile':
      return EskoliaTokens.success;
    case 'difficile':
      return EskoliaTokens.error;
    case 'moyen':
      return EskoliaTokens.amber;
    default:
      return EskoliaVisual.neonCyanSoft;
  }
}

/// Ligne au-dessus de l’intitulé : origine pédagogique + difficulté.
class QuizQuestionContextRow extends StatelessWidget {
  const QuizQuestionContextRow({
    super.key,
    required this.contextLine,
    required this.difficultyBucket,
    this.categoryGroup = QuestionCategoryGroup.officialParcours,
    this.authorName = 'Eskolia Team',
  });

  final String? contextLine;
  final String difficultyBucket;
  final QuestionCategoryGroup categoryGroup;
  final String authorName;

  @override
  Widget build(BuildContext context) {
    final diffLabel = quizDifficultyLabelFr(difficultyBucket);
    final diffColor = _difficultyAccent(difficultyBucket);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (contextLine != null && contextLine!.trim().isNotEmpty)
                Expanded(
                  child: Text(
                    contextLine!.trim(),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.82),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                ),
              _buildCategoryBadge(),
            ],
          ),
          if (contextLine != null && contextLine!.trim().isNotEmpty)
            const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: diffColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: diffColor.withValues(alpha: 0.45),
                  ),
                ),
                child: Text(
                  'Difficulté : $diffLabel',
                  style: TextStyle(
                    color: diffColor.withValues(alpha: 0.95),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Spacer(),
              if (categoryGroup != QuestionCategoryGroup.officialParcours)
                Text(
                  'Par $authorName',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBadge() {
    String label;
    Color color;
    IconData icon;

    switch (categoryGroup) {
      case QuestionCategoryGroup.officialParcours:
        label = 'OFFICIEL';
        color = EskoliaTokens.violetSoft;
        icon = Icons.verified_rounded;
        break;
      case QuestionCategoryGroup.themes:
        label = 'THÈME';
        color = EskoliaTokens.cyan;
        icon = Icons.category_rounded;
        break;
      case QuestionCategoryGroup.labo:
        label = 'LABO';
        color = EskoliaTokens.orange;
        icon = Icons.science_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
