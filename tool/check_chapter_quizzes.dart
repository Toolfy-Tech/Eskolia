// dart run tool/check_chapter_quizzes.dart
import 'dart:convert';
import 'dart:io';

void main() {
  final root = Directory.current.path.endsWith('tool')
      ? Directory.current.parent.path
      : Directory.current.path;
  final indexFile = File('$root/data/curriculum/tip/index.json');
  final index =
      jsonDecode(indexFile.readAsStringSync()) as Map<String, dynamic>;
  final chapitres =
      (index['chapitres'] as List).cast<Map<String, dynamic>>();

  String sectionFolder(String sectionId) {
    final n = sectionId.replaceFirst(RegExp(r'^S'), '');
    final v = int.tryParse(n) ?? 1;
    return v.toString().padLeft(2, '0');
  }

  String chapterNum2(String chapterId) {
    final m = RegExp(r'(\d+)').firstMatch(chapterId);
    if (m == null) return '01';
    final v = int.tryParse(m.group(1)!) ?? 1;
    return v.toString().padLeft(2, '0');
  }

  bool exists(String p) => File('$root/$p').existsSync();

  final missing = <String>[];
  for (final ch in chapitres) {
    final sid = ch['section'] as String? ?? '';
    final slug = ch['slug'] as String? ?? '';
    final cid = ch['id'] as String? ?? '';
    final titre = ch['titre'] as String? ?? '';
    final qp = ch['questions_path'] as String?;

    final sf = sectionFolder(sid);
    final cn = chapterNum2(cid);
    final base = 'data/questions/tip/section-$sf';

    final candidates = <String>[
      if (qp != null && qp.isNotEmpty) 'data/$qp',
      if (slug.isNotEmpty) '$base/$slug.json',
      '$base/chapter-$cn.json',
      '$base/chapitre-$cn.json',
      '$base/chapitre-$cid.json',
      '$base/chapitre-${cid.toUpperCase()}.json',
      '$base/chapitre-${cid.toLowerCase()}.json',
      '$base/chapter-${cid.toLowerCase()}.json',
    ];

    final ok = candidates.any(exists);
    if (!ok) {
      missing.add('$sid · $cid · $slug — $titre');
    }
  }

  stdout.writeln('Chapitres dans index.json : ${chapitres.length}');
  stdout.writeln('Sans fichier QCM détecté (candidats épuisés) : ${missing.length}');
  for (final m in missing) {
    stdout.writeln('  - $m');
  }
}
