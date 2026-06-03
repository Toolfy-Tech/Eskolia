import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../economy/data/achievement_rewards.dart';
import '../../labo/data/question_report_kind.dart';
import '../../labo/data/question_report_repository.dart';
import '../data/quiz_repository.dart';
import '../../../core/constants/eskolia_tokens.dart';

/// Dialogue de signalement (réutilisable depuis le quiz en cours ou l’écran résultats).
Future<void> showQuizQuestionReportDialog(
  BuildContext context,
  QuizQuestion q,
) async {
  final asset = q.sourceAssetPath ?? '';
  if (asset.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Signalement indisponible pour cette session.'),
      ),
    );
    return;
  }
  final ctrl = TextEditingController();
  var kind = QuestionReportKind.other;
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSt) => AlertDialog(
        backgroundColor: EskoliaTokens.surface1,
        title: const Text(
          'Signaler une erreur',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Type de problème',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: QuestionReportKind.values.map((k) {
                  final sel = kind == k;
                  return ChoiceChip(
                    label: Text(
                      k.label,
                      style: TextStyle(
                        color: sel ? Colors.white : Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                    selected: sel,
                    onSelected: (_) => setSt(() => kind = k),
                    selectedColor: EskoliaTokens.violet.withValues(alpha: 0.85),
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                    side: BorderSide(
                      color: sel ? EskoliaTokens.violet : Colors.white24,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: ctrl,
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Précision (optionnel)',
                  hintStyle: TextStyle(color: Colors.white54),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Envoyer'),
          ),
        ],
      ),
    ),
  );
  if (ok != true) {
    ctrl.dispose();
    return;
  }
  final preview = q.question.trim();
  final shortPreview =
      preview.length > 140 ? '${preview.substring(0, 140)}…' : preview;
  try {
    if (!context.mounted) return;
    await QuestionReportRepository().reportQuestion(
      assetPath: asset,
      questionId: q.id.isNotEmpty ? q.id : 'unknown',
      message: ctrl.text.trim(),
      kind: kind,
      questionPreview: shortPreview,
    );
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null && uid.isNotEmpty) {
      await AchievementRewards().unlock(uid, 'labo_first_report');
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signalement enregistré — merci !')),
      );
    }
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Échec de l’envoi (réseau / règles).')),
      );
    }
  } finally {
    ctrl.dispose();
  }
}
