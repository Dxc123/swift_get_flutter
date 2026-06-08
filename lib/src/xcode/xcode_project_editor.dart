import 'dart:io';

import 'package:path/path.dart' as p;

final class XcodeProjectEditor {
  const XcodeProjectEditor();

  Future<List<String>> apply({
    required String projectRoot,
    required List<String> edits,
    bool dryRun = false,
  }) async {
    if (edits.isEmpty) {
      return const [];
    }

    final pbxproj = File(p.join(projectRoot, 'project.pbxproj'));
    final planned = [
      for (final edit in edits) 'Xcode project: $edit',
    ];

    if (dryRun || !pbxproj.existsSync()) {
      return planned;
    }

    final backup = File('${pbxproj.path}.${DateTime.now().millisecondsSinceEpoch}.bak');
    await backup.writeAsString(await pbxproj.readAsString());
    await pbxproj.writeAsString('${await pbxproj.readAsString()}\n/* swift-get edits\n${edits.join('\n')}\n*/\n');
    return planned;
  }
}
