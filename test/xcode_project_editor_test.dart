import 'dart:io';

import 'package:swift_get_flutter/src/xcode/xcode_project_editor.dart';
import 'package:test/test.dart';

void main() {
  test('backs up pbxproj before appending project edits', () async {
    final root = await Directory.systemTemp.createTemp('swift_get_xcode_');
    final project = Directory('${root.path}/DemoApp.xcodeproj')..createSync();
    final pbxproj = File('${project.path}/project.pbxproj')..writeAsStringSync('// project');

    final edits = await const XcodeProjectEditor().apply(
      projectRoot: project.path,
      edits: const ['Add Login files to app target'],
    );

    expect(edits, contains('Xcode project: Add Login files to app target'));
    expect(pbxproj.readAsStringSync(), contains('Add Login files to app target'));
    expect(project.listSync().where((entity) => entity.path.endsWith('.bak')), isNotEmpty);
  });

  test('dry-run reports edits without writing backup', () async {
    final root = await Directory.systemTemp.createTemp('swift_get_xcode_dry_');
    final project = Directory('${root.path}/DemoApp.xcodeproj')..createSync();
    File('${project.path}/project.pbxproj').writeAsStringSync('// project');

    final edits = await const XcodeProjectEditor().apply(
      projectRoot: project.path,
      edits: const ['Install SnapKit with CocoaPods'],
      dryRun: true,
    );

    expect(edits, contains('Xcode project: Install SnapKit with CocoaPods'));
    expect(project.listSync().where((entity) => entity.path.endsWith('.bak')), isEmpty);
  });
}
