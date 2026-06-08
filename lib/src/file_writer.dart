import 'dart:io';

import 'package:path/path.dart' as p;

import 'scaffold/scaffold_plan.dart';

final class FileWriter {
  const FileWriter();

  Future<List<String>> write(
    ScaffoldPlan plan, {
    bool force = false,
    bool dryRun = false,
  }) async {
    final paths = [
      for (final file in plan.files) p.join(plan.root, file.relativePath),
    ];

    if (dryRun) {
      return paths;
    }

    for (var index = 0; index < plan.files.length; index += 1) {
      final file = plan.files[index];
      final output = File(paths[index]);
      if (output.existsSync() && !force) {
        throw FileSystemException('File already exists', output.path);
      }

      await output.parent.create(recursive: true);
      await output.writeAsString(file.contents);
    }

    return paths;
  }
}
