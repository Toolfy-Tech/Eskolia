// ignore_for_file: avoid_print
//
// Audit des QCM TIP : biais de longueur (bonne vs distracteurs),
// énoncés courts. Lancer depuis la racine du projet :
//   dart tool/audit_quiz_questions.dart

import 'dart:convert';
import 'dart:io';
import 'dart:math';

class _Q {
  _Q(this.file, this.id, this.stem, this.options, this.correctIndex);

  final String file;
  final String id;
  final String stem;
  final List<String> options;
  final int correctIndex;
}

void main() {
  final root = Directory.current;
  final tipDir = Directory('${root.path}/data/questions/tip');
  final all = <_Q>[];
  all.addAll(_loadDir(tipDir, 'TIP'));

  if (all.isEmpty) {
    print('Aucune question trouvée (vérifier le cwd : racine du repo).');
    exit(1);
  }

  var lenBiasStrong = 0;
  var lenBiasMild = 0;
  var shortStem = 0;
  final offenders = <Map<String, Object>>[];

  for (final q in all) {
    final ci = q.correctIndex.clamp(0, q.options.length - 1);
    final correct = q.options[ci];
    final wrongLens = <int>[];
    for (var i = 0; i < q.options.length; i++) {
      if (i == ci) continue;
      final t = q.options[i].trim();
      if (t.isEmpty) continue;
      wrongLens.add(t.length);
    }
    if (wrongLens.isEmpty) continue;
    final maxWrong = wrongLens.reduce(max);
    final cLen = correct.length;
    final stemLen = q.stem.length;

    if (stemLen < 80) shortStem++;

    final delta = cLen - maxWrong;
    if (delta > 40) {
      lenBiasStrong++;
      offenders.add({
        'delta': delta,
        'file': q.file,
        'id': q.id,
        'stemLen': stemLen,
        'cLen': cLen,
        'maxWrong': maxWrong,
        'stem': q.stem.length > 120 ? '${q.stem.substring(0, 120)}…' : q.stem,
      });
    } else if (delta > 15) {
      lenBiasMild++;
    }
  }

  offenders.sort(
    (a, b) => (b['delta']! as int).compareTo(a['delta']! as int),
  );

  print('=== Audit QCM (TIP) ===\n');
  print('Total questions analysées : ${all.length}\n');
  print(
    'Biais longueur fort : bonne réponse > plus long distracteur de **>40** car. : $lenBiasStrong '
    '(${(100 * lenBiasStrong / all.length).toStringAsFixed(1)} %)',
  );
  print(
    'Biais longueur modéré : delta **16–40** car. : $lenBiasMild '
    '(${(100 * lenBiasMild / all.length).toStringAsFixed(1)} %)',
  );
  print(
    'Énoncés < 80 caractères (manque de contexte possible) : $shortStem '
    '(${(100 * shortStem / all.length).toStringAsFixed(1)} %)\n',
  );
  print(
    'Note : depuis le code, les **choix sont mélangés à chaque session** '
    '(shuffleQuizQuestionOptions) — la longueur seule ne suffit plus pour tricher.\n',
  );
  print('--- Top 25 pires écarts (longueur bonne − max distracteur) ---\n');
  for (var i = 0; i < min(25, offenders.length); i++) {
    final m = offenders[i];
    print(
      '${i + 1}. Δ=${m['delta']} | stem=${m['stemLen']}c | '
      'bonne=${m['cLen']}c maxFaux=${m['maxWrong']}c\n'
      '   ${m['file']}\n'
      '   id=${m['id']}\n'
      '   «${m['stem']}»\n',
    );
  }
}

List<_Q> _loadDir(Directory dir, String label) {
  final out = <_Q>[];
  if (!dir.existsSync()) {
    print('(!) Dossier absent : ${dir.path} ($label)');
    return out;
  }
  for (final f in dir.listSync(recursive: true, followLinks: false)) {
    if (f is! File) continue;
    if (!f.path.endsWith('.json')) continue;
    try {
      final raw = f.readAsStringSync();
      final decoded = jsonDecode(raw);
      if (decoded is! List) continue;
      final rel = f.path.replaceAll('\\', '/');
      final shortFile = rel.contains('data/questions/')
          ? rel.substring(rel.indexOf('data/questions/'))
          : rel;
      for (final e in decoded) {
        if (e is! Map) continue;
        final m = Map<String, dynamic>.from(e);
        final q = _parseOne(shortFile, m);
        if (q != null) out.add(q);
      }
    } catch (e) {
      print('(!) $label — erreur ${f.path}: $e');
    }
  }
  return out;
}

_Q? _parseOne(String file, Map<String, dynamic> m) {
  final choices = <String>[];
  final rawC = m['choices'];
  if (rawC is List) {
    for (final c in rawC) {
      choices.add(c.toString());
    }
  }
  if (choices.isEmpty) {
    final rawO = m['options'];
    if (rawO is List) {
      for (final c in rawO) {
        choices.add(c.toString());
      }
    }
  }
  if (choices.isEmpty) return null;
  while (choices.length < 4) {
    choices.add('');
  }
  final opts = choices.take(4).toList();
  final maxI = opts.length - 1;
  int ci;
  if (m.containsKey('bonne_reponse')) {
    ci = ((m['bonne_reponse'] as num?)?.toInt() ?? 0).clamp(0, maxI);
  } else {
    final ans = (m['answer'] as String?)?.trim().toUpperCase() ?? 'A';
    final c0 = ans.isEmpty ? 65 : ans.codeUnitAt(0);
    ci = (c0 >= 65 && c0 <= 68) ? c0 - 65 : 0;
    ci = ci.clamp(0, maxI);
  }
  final stem = (m['question'] as String?)?.trim() ?? '';
  if (stem.isEmpty) return null;
  final id = m['id'] as String? ?? '';
  return _Q(file, id, stem, opts, ci);
}
