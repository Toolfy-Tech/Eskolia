// Build web + patch SW — évite les '=' dans firebase.json predeploy (Windows).
// ignore_for_file: avoid_print

import 'dart:io';

Future<void> main() async {
  print('hosting_prebuild: flutter build web --release ...');
  final flutter = await Process.run(
    'flutter',
    [
      'build',
      'web',
      '--release',
      '--pwa-strategy=none',
      '--no-wasm-dry-run',
    ],
    workingDirectory: Directory.current.path,
    runInShell: true,
  );
  stdout.write(flutter.stdout);
  stderr.write(flutter.stderr);
  if (flutter.exitCode != 0) {
    stderr.writeln('hosting_prebuild: flutter build a échoué (${flutter.exitCode}).');
    exit(flutter.exitCode);
  }

  final patch = await Process.run(
    'dart',
    ['tool/patch_service_worker.dart'],
    workingDirectory: Directory.current.path,
    runInShell: true,
  );
  stdout.write(patch.stdout);
  stderr.write(patch.stderr);
  if (patch.exitCode != 0) {
    stderr.writeln('hosting_prebuild: patch_service_worker a échoué (${patch.exitCode}).');
    exit(patch.exitCode);
  }
}
