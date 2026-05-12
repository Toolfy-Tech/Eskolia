// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
import 'dart:math';

void main(List<String> args) {
  final root = _repoRoot();
  final questionsDir = Directory('${root.path}/data/questions');
  if (!questionsDir.existsSync()) {
    print('OK: dossier data/questions absent (aucun quiz a valider).');
    exit(0);
  }

  final jsonFiles = questionsDir
      .listSync(recursive: true, followLinks: false)
      .whereType<File>()
      .where((f) => f.path.toLowerCase().endsWith('.json'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  if (jsonFiles.isEmpty) {
    print('OK: aucun fichier JSON de quiz detecte dans data/questions.');
    exit(0);
  }

  final errors = <String>[];
  final warnings = <String>[];

  for (final file in jsonFiles) {
    _validateFile(file, errors, warnings);
  }

  if (warnings.isNotEmpty) {
    print('\n=== Quiz quality gate: warnings ===');
    for (final w in warnings) {
      print('- $w');
    }
  }

  if (errors.isNotEmpty) {
    print('\n=== Quiz quality gate: ECHEC ===');
    for (final e in errors) {
      print('- $e');
    }
    print('\nTotal erreurs: ${errors.length}');
    exit(1);
  }

  print('\n=== Quiz quality gate: OK ===');
  print('Fichiers valides: ${jsonFiles.length}');
}

Directory _repoRoot() {
  var current = Directory.current;
  if (current.path.endsWith('${Platform.pathSeparator}tool')) {
    current = current.parent;
  }
  return current;
}

void _validateFile(File file, List<String> errors, List<String> warnings) {
  final relPath = _normalize(file.path);
  dynamic decoded;
  try {
    decoded = jsonDecode(file.readAsStringSync());
  } catch (e) {
    errors.add('$relPath: JSON invalide ($e)');
    return;
  }

  if (decoded is! List) {
    errors.add('$relPath: le fichier doit contenir une liste de questions.');
    return;
  }

  final answerSequence = <String>[];
  final vfValues = <bool>[];
  final difficultyCounts = <int, int>{1: 0, 2: 0, 3: 0};

  for (var i = 0; i < decoded.length; i++) {
    final item = decoded[i];
    if (item is! Map) {
      errors.add('$relPath#${i + 1}: chaque question doit etre un objet JSON.');
      continue;
    }

    final q = Map<String, dynamic>.from(item.cast<String, dynamic>());
    _validateQuestion(
      relPath: relPath,
      index: i + 1,
      q: q,
      errors: errors,
      warnings: warnings,
      answerSequence: answerSequence,
      vfValues: vfValues,
      difficultyCounts: difficultyCounts,
    );
  }

  _validateAnswerDistribution(relPath, answerSequence, warnings);
  _validateVfBalance(relPath, vfValues, warnings);
  _validateDifficultyBalance(relPath, difficultyCounts, warnings);
}

void _validateQuestion({
  required String relPath,
  required int index,
  required Map<String, dynamic> q,
  required List<String> errors,
  required List<String> warnings,
  required List<String> answerSequence,
  required List<bool> vfValues,
  required Map<int, int> difficultyCounts,
}) {
  final prefix = '$relPath#$index';
  final question = (q['question'] ?? '').toString().trim();
  final explanation = (q['explanation'] ?? '').toString().trim();
  if (question.isEmpty) errors.add('$prefix: champ "question" obligatoire.');
  if (explanation.isEmpty) errors.add('$prefix: champ "explanation" obligatoire.');

  final difficulty = _parseDifficulty(q['difficulty']);
  if (difficulty == null) {
    errors.add('$prefix: "difficulty" doit etre 1, 2 ou 3.');
  } else {
    difficultyCounts[difficulty] = (difficultyCounts[difficulty] ?? 0) + 1;
  }

  final hasQcm =
      (q['choices'] is List && (q['choices'] as List).length == 4) ||
      (q['options'] is List && (q['options'] as List).length == 4);
  final isVf = _isTrueFalseQuestion(q);

  if (hasQcm) {
    _validateQcm(
      prefix: prefix,
      q: q,
      errors: errors,
      warnings: warnings,
      answerSequence: answerSequence,
    );
  }

  if (isVf) {
    final value = _extractTrueFalseValue(q);
    if (value == null) {
      errors.add('$prefix: question V/F sans reponse Vrai/Faux explicite.');
    } else {
      vfValues.add(value);
    }
  }

  if (!_hasCourseAnchor(q)) {
    warnings.add(
      '$prefix: aucun ancrage explicite au cours (ex: notion_id, chapter_slug, source_ref).',
    );
  }
}

void _validateQcm({
  required String prefix,
  required Map<String, dynamic> q,
  required List<String> errors,
  required List<String> warnings,
  required List<String> answerSequence,
}) {
  final optionsRaw = (q['choices'] ?? q['options']) as List<dynamic>;
  if (optionsRaw.length != 4) {
    errors.add('$prefix: un QCM doit avoir exactement 4 reponses.');
    return;
  }
  final options = optionsRaw.map((e) => e.toString().trim()).toList();
  if (options.any((o) => o.isEmpty)) {
    errors.add('$prefix: les 4 options QCM doivent etre non vides.');
    return;
  }

  final correctIndex = _extractCorrectIndex(q);
  if (correctIndex == null || correctIndex < 0 || correctIndex > 3) {
    errors.add('$prefix: bonne reponse invalide (attendu A-D ou index 0-3).');
    return;
  }

  final longest = options.map((o) => o.length).reduce(max);
  final shortest = options.map((o) => o.length).reduce(min);
  if (shortest == 0 || longest / shortest > 1.20) {
    warnings.add('$prefix: ecart de longueur > +/-20% entre options.');
  }

  final parenFlags = options.map(_hasParentheses).toList();
  final parenCount = parenFlags.where((v) => v).length;
  if (parenCount == 1 && parenFlags[correctIndex]) {
    warnings.add(
      '$prefix: la bonne reponse est la seule option avec parentheses.',
    );
  }

  final punctuationPattern = options.map(_finalPunctuationClass).toSet();
  if (punctuationPattern.length > 1) {
    warnings.add('$prefix: ponctuation finale non coherente entre options.');
  }

  final connectorFlags = options.map(_hasLogicalConnector).toList();
  final connectorCount = connectorFlags.where((v) => v).length;
  if (connectorCount == 1 && connectorFlags[correctIndex]) {
    warnings.add(
      '$prefix: la bonne reponse est la seule option avec connecteur logique.',
    );
  }

  final numberFlags = options.map(_hasNumber).toList();
  final numberCount = numberFlags.where((v) => v).length;
  if (numberCount == 1 && numberFlags[correctIndex]) {
    warnings.add('$prefix: la bonne reponse est la seule option avec chiffre/date.');
  }

  final correctLen = options[correctIndex].length;
  final secondLongest = options
      .map((o) => o.length)
      .where((len) => len != longest)
      .fold<int>(0, max);
  final standoutLengthDelta = longest - secondLongest;
  if (correctLen == longest &&
      options.where((o) => o.length == longest).length == 1 &&
      standoutLengthDelta >= 8) {
    warnings.add('$prefix: la bonne reponse est la seule option la plus longue.');
  }

  if (q.containsKey('shuffle_answers') && q['shuffle_answers'] != true) {
    warnings.add('$prefix: "shuffle_answers" devrait etre true.');
  }
  if (!q.containsKey('shuffle_answers')) {
    warnings.add('$prefix: champ "shuffle_answers" absent (recommande: true).');
  }

  answerSequence.add(String.fromCharCode(65 + correctIndex));
}

int? _parseDifficulty(dynamic raw) {
  if (raw is int && raw >= 1 && raw <= 3) return raw;
  if (raw is String) {
    final s = raw.trim().toLowerCase();
    if (s == '1' || s == 'facile' || s == 'easy') return 1;
    if (s == '2' || s == 'moyen' || s == 'medium') return 2;
    if (s == '3' || s == 'difficile' || s == 'hard') return 3;
  }
  return null;
}

int? _extractCorrectIndex(Map<String, dynamic> q) {
  if (q['correct_index'] is int) return q['correct_index'] as int;
  if (q['bonne_reponse'] is int) return q['bonne_reponse'] as int;
  if (q['answer'] is String) {
    final s = (q['answer'] as String).trim().toUpperCase();
    if (s.isNotEmpty) {
      final c = s.codeUnitAt(0);
      if (c >= 65 && c <= 68) return c - 65;
    }
  }
  return null;
}

bool _isTrueFalseQuestion(Map<String, dynamic> q) {
  final type = (q['type'] ?? '').toString().toLowerCase();
  return type.contains('vrai') ||
      type.contains('faux') ||
      type.contains('true_false') ||
      type.contains('truefalse') ||
      type == 'vf';
}

bool? _extractTrueFalseValue(Map<String, dynamic> q) {
  final raw = (q['answer'] ?? q['correct_answer'] ?? q['correct'] ?? '')
      .toString()
      .trim()
      .toLowerCase();
  if (raw == 'vrai' || raw == 'true') return true;
  if (raw == 'faux' || raw == 'false') return false;
  return null;
}

void _validateAnswerDistribution(
  String relPath,
  List<String> answers,
  List<String> warnings,
) {
  if (answers.isEmpty) return;

  for (var i = 2; i < answers.length; i++) {
    if (answers[i] == answers[i - 1] && answers[i] == answers[i - 2]) {
      warnings.add(
        '$relPath: meme lettre correcte 3 fois de suite (${answers[i]} aux positions ${i - 1}, $i, ${i + 1}).',
      );
      break;
    }
  }

  if (answers.length >= 10) {
    for (var i = 0; i <= answers.length - 10; i++) {
      final window = answers.sublist(i, i + 10);
      final counts = <String, int>{'A': 0, 'B': 0, 'C': 0, 'D': 0};
      for (final a in window) {
        counts[a] = (counts[a] ?? 0) + 1;
      }
      final maxCount = counts.values.reduce(max);
      if (maxCount > 3) {
        warnings.add(
          '$relPath: distribution A/B/C/D non conforme dans une fenetre de 10 questions (max observe=$maxCount).',
        );
        break;
      }
    }
  }
}

void _validateVfBalance(String relPath, List<bool> vfValues, List<String> warnings) {
  if (vfValues.isEmpty) return;
  final trueCount = vfValues.where((v) => v).length;
  final falseCount = vfValues.length - trueCount;
  if ((trueCount - falseCount).abs() > 1) {
    warnings.add(
      '$relPath: repartition V/F desequilibree (Vrai=$trueCount, Faux=$falseCount).',
    );
  }
}

void _validateDifficultyBalance(
  String relPath,
  Map<int, int> counts,
  List<String> warnings,
) {
  final total = counts.values.fold<int>(0, (a, b) => a + b);
  if (total == 0) return;
  final pct1 = (counts[1]! / total) * 100;
  final pct2 = (counts[2]! / total) * 100;
  final pct3 = (counts[3]! / total) * 100;

  const tolerance = 10.0;
  if ((pct1 - 30).abs() > tolerance ||
      (pct2 - 50).abs() > tolerance ||
      (pct3 - 20).abs() > tolerance) {
    warnings.add(
      '$relPath: distribution des difficultes hors cible 30/50/20 '
      '(actuel: ${pct1.toStringAsFixed(1)}/${pct2.toStringAsFixed(1)}/${pct3.toStringAsFixed(1)}).',
    );
  }
}

bool _hasCourseAnchor(Map<String, dynamic> q) {
  const keys = [
    'notion_id',
    'chapter_slug',
    'section_id',
    'source_ref',
    'curriculum_ref',
    'lesson_id',
    'course_id',
  ];
  for (final key in keys) {
    final value = q[key];
    if (value != null && value.toString().trim().isNotEmpty) {
      return true;
    }
  }
  return false;
}

bool _hasParentheses(String value) => value.contains('(') || value.contains(')');

String _finalPunctuationClass(String value) {
  final trimmed = value.trimRight();
  if (trimmed.isEmpty) return 'none';
  final c = trimmed[trimmed.length - 1];
  if (['.', '!', '?', ';', ':'].contains(c)) return c;
  return 'none';
}

bool _hasLogicalConnector(String value) {
  final lower = value.toLowerCase();
  const connectors = [
    'car ',
    'donc ',
    'ainsi ',
    'cependant ',
    'toutefois ',
    'en revanche ',
    'puis ',
    'alors ',
  ];
  return connectors.any(lower.contains);
}

bool _hasNumber(String value) => RegExp(r'\d').hasMatch(value);

String _normalize(String path) => path.replaceAll('\\', '/');
