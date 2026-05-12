import 'package:flutter/material.dart';

/// Segments `/quiz/…` qui ne sont pas une session [QuizScreen] (écrans intermédiaires).
const _quizHubPathSegments = <String>{
  'setup',
  'quick',
  'survival',
  'epreuve-finale-tip',
  'epreuve-finale-optimus',
  'revision-lacunes',
  'true-false',
};

/// Indique si [location] correspond à un quiz « en session » ([QuizScreen]) :
/// `/quiz/run`, `/quiz/daily`, modules parcours, etc.
bool isQuizPlaySessionPath(String location) {
  final path = Uri.parse(location).path;
  if (path == '/quiz/run') return true;
  if (path.startsWith('/quiz/run/')) return true;
  if (!path.startsWith('/quiz/')) return false;
  final rest = path.substring('/quiz/'.length);
  if (rest.isEmpty) return false;
  final segment = rest.split('/').first;
  return !_quizHubPathSegments.contains(segment);
}

Future<bool> confirmNavigateAwayFromQuiz(BuildContext context) async {
  final r = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Quitter le quiz ?'),
      content: const Text(
        'Si vous quittez maintenant, votre progression sur ce quiz peut être perdue. '
        'Vous devrez peut-être recommencer depuis le début.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('Quitter'),
        ),
      ],
    ),
  );
  return r == true;
}
