// Génère data/questions/optimus/section-XX/evaluation-finale.json
// en fusionnant les chapitres (dédoublonnage par id).
// Usage : dart run tool/merge_optimus_section_evaluations.dart

import 'dart:convert';
import 'dart:io';

void main() {
  final root = Directory.current;
  for (var s = 1; s <= 6; s++) {
    final sec = s.toString().padLeft(2, '0');
    final dir = Directory(
      '${root.path}/data/questions/optimus/section-$sec',
    );
    if (!dir.existsSync()) {
      stderr.writeln('Dossier manquant : ${dir.path}');
      exitCode = 1;
      continue;
    }
    final out = <Map<String, dynamic>>[];
    final seen = <String>{};
    final files = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.json'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));
    for (final f in files) {
      final name = f.uri.pathSegments.last;
      if (name == 'evaluation-finale.json') continue;
      final raw = f.readAsStringSync();
      final decoded = jsonDecode(raw);
      if (decoded is! List) continue;
      for (final e in decoded) {
        if (e is! Map) continue;
        final m = Map<String, dynamic>.from(e);
        final id = m['id']?.toString() ?? '';
        final key = id.isNotEmpty ? id : '${m['question']}'.hashCode.toString();
        if (!seen.add(key)) continue;
        m['phase'] = 'Evaluation_Finale';
        out.add(m);
      }
    }
    final target = File('${dir.path}/evaluation-finale.json');
    target.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(out));
    stdout.writeln('section-$sec : ${out.length} questions → evaluation-finale.json');
  }
}
