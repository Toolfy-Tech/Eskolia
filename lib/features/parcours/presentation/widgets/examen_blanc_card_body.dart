import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/parcours_repository.dart';
import '../../data/tip_progress_repository.dart';
import '../../../quiz/data/quiz_repository.dart';
import '../../../../core/constants/eskolia_tokens.dart';
import '../../../../shared/widgets/gradient_border_card.dart';

bool _formationAllSectionExamsCompleted(FormationModel f) {
  for (final s in f.sections) {
    for (final m in s.modules) {
      if (m.type == 'exam' && !m.isCompleted) return false;
    }
  }
  return true;
}

class ExamenBlancCardBody extends StatefulWidget {
  const ExamenBlancCardBody({super.key, required this.formation});

  final FormationModel formation;

  @override
  State<ExamenBlancCardBody> createState() => _ExamenBlancCardBodyState();
}

class _ExamenBlancCardBodyState extends State<ExamenBlancCardBody> {
  StreamSubscription<void>? _sub;
  Set<String> _completed = {};

  @override
  void initState() {
    super.initState();
    _reloadIds();
    _sub = TipProgressRepository.updates.listen((_) => _reloadIds());
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _reloadIds() async {
    final s = await TipProgressRepository().readCompletedIds();
    if (mounted) setState(() => _completed = s);
  }

  @override
  Widget build(BuildContext context) {
    final f = widget.formation;
    final isTip = f.id == 'tip';
    final progressId = isTip
        ? QuizRepository.grandFinaleSessionId
        : QuizRepository.optimusGrandFinaleSessionId;
    final route = isTip
        ? '/quiz/epreuve-finale-tip'
        : '/quiz/epreuve-finale-optimus';
    final title = isTip
        ? 'Examen blanc — fin TIP'
        : 'Examen blanc — fin Optimus';
    final unlocked = _formationAllSectionExamsCompleted(f);
    final grandDone = _completed.contains(progressId);

    final borderColors = unlocked
        ? (isTip
            ? const [Color(0xFFFFB74D), Color(0xFFE040FB)]
            : [EskoliaTokens.cyan, EskoliaTokens.violetSoft])
        : [
            Colors.white.withValues(alpha: 0.14),
            Colors.white.withValues(alpha: 0.06),
          ];
    final accent = isTip ? const Color(0xFFFFB74D) : EskoliaTokens.cyan;

    const Color slate = EskoliaTokens.textSecondary;

    return GradientBorderCard(
      gradientColors: borderColors,
      glowColor: unlocked ? accent : null,
      borderRadius: 16,
      innerBlurSigma: 12,
      innerColor: EskoliaTokens.surface1,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(isTip ? '\u{1F3C6}' : '\u{1F393}',
                  style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: unlocked ? 1 : 0.65),
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
              if (grandDone)
                Text(
                  '\u{2705} Réussie',
                  style: TextStyle(
                    color: slate.withValues(alpha: 0.95),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            unlocked
                ? (isTip
                    ? 'Au moins 40 questions (moyen + difficile sur tout le catalogue TIP ; '
                        '« faciles » exclues sauf complément). Pour valider : 80 % de bonnes réponses.'
                    : 'Au moins ${QuizRepository.grandFinaleOptimusMinQuestions} questions '
                        '(moyen + difficile sur tout le catalogue Optimus ; « faciles » en complément). '
                        'Pour valider : 80 % de bonnes réponses.')
                : (isTip
                    ? 'Termine d’abord toutes les évaluations finales de section '
                        '(S01–S10).'
                    : 'Termine d’abord toutes les évaluations finales de section '
                        '(O01–O06).'),
            style: TextStyle(
              color: slate.withValues(alpha: unlocked ? 0.9 : 0.65),
              fontSize: 12,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: unlocked ? () => context.push(route) : null,
            style: FilledButton.styleFrom(
              backgroundColor: accent,
              foregroundColor:
                  isTip ? const Color(0xFF1A1206) : EskoliaTokens.bgBase,
              disabledBackgroundColor: Colors.white.withValues(alpha: 0.08),
              disabledForegroundColor: slate,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text(
              grandDone ? 'Repasser l’épreuve' : 'Lancer l’épreuve finale',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}
