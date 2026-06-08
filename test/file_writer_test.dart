import 'dart:io';

import 'package:swift_get_flutter/src/file_writer.dart';
import 'package:swift_get_flutter/src/scaffold/scaffold_plan.dart';
import 'package:test/test.dart';

void main() {
  test('dry-run returns paths without writing files', () async {
    final root = await Directory.systemTemp.createTemp('swift_get_dry_run_');
    final plan = ScaffoldPlan(root: root.path, files: const [
      PlannedFile(relativePath: 'Demo/File.swift', contents: 'final class File {}'),
    ]);

    final paths = await const FileWriter().write(plan, dryRun: true);

    expect(paths.single, endsWith('Demo/File.swift'));
    expect(File(paths.single).existsSync(), isFalse);
  });

  test('writes parent directories and files', () async {
    final root = await Directory.systemTemp.createTemp('swift_get_write_');
    final plan = ScaffoldPlan(root: root.path, files: const [
      PlannedFile(relativePath: 'Demo/File.swift', contents: 'final class File {}'),
    ]);

    final paths = await const FileWriter().write(plan);

    expect(await File(paths.single).readAsString(), 'final class File {}');
  });
}
