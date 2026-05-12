// Copie le service worker « réseau seul » après `flutter build web`.
// ignore_for_file: avoid_print

import 'dart:io';

void main() {
  final root = Directory.current.path;
  final src = File('$root/web/flutter_service_worker.js');
  final dst = File('$root/build/web/flutter_service_worker.js');
  if (!src.existsSync()) {
    stderr.writeln('patch_service_worker: fichier manquant ${src.path}');
    exit(1);
  }
  if (!dst.parent.existsSync()) {
    stderr.writeln(
      'patch_service_worker: lance d’abord flutter build web (dossier build/web absent).',
    );
    exit(1);
  }
  dst.writeAsStringSync(src.readAsStringSync());
  print(
    'patch_service_worker: ${dst.path} (${dst.lengthSync()} octets)',
  );
}
