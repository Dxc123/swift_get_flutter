import 'dart:io';

import 'package:swift_get_flutter/src/commands/swift_get_command_runner.dart';
import 'package:swift_get_flutter/src/xcode/cocoapods_installer.dart';
import 'package:swift_get_flutter/src/xcode/xcodegen_project_generator.dart';
import 'package:test/test.dart';

final class RecordingXcodeGenProjectGenerator
    implements XcodeGenProjectGenerator {
  String? projectDirectory;
  String? specPath;
  bool? dryRun;

  @override
  Future<XcodeGenResult> generate({
    required String projectDirectory,
    required String specPath,
    bool dryRun = false,
  }) async {
    this.projectDirectory = projectDirectory;
    this.specPath = specPath;
    this.dryRun = dryRun;
    return XcodeGenResult(
      message: dryRun ? 'Would run XcodeGen' : 'Generated Xcode project',
      generated: !dryRun,
    );
  }
}

final class RecordingCocoaPodsInstaller implements CocoaPodsInstaller {
  String? projectDirectory;
  bool? dryRun;

  @override
  Future<CocoaPodsResult> install({
    required String projectDirectory,
    bool dryRun = false,
  }) async {
    this.projectDirectory = projectDirectory;
    this.dryRun = dryRun;
    return CocoaPodsResult(
      message: dryRun ? 'Would run pod install' : 'Installed CocoaPods',
      installed: !dryRun,
    );
  }
}

void main() {
  test('create dry-run prints planned files and does not write', () async {
    final root = await Directory.systemTemp.createTemp('swift_get_create_');
    final output = StringBuffer();
    final runner = SwiftGetCommandRunner(output: output);

    await runner.run([
      'create',
      'DemoApp',
      '--bundle-id',
      'com.example.demo',
      '--path',
      root.path,
      '--dry-run',
    ]);

    expect(output.toString(), contains('Would create'));
    expect(output.toString(), contains('DemoApp/App/AppDelegate.swift'));
    expect(output.toString(), contains('project.yml'));
    expect(output.toString(), contains('Podfile'));
    expect(Directory('${root.path}/DemoApp').existsSync(), isFalse);
  });

  test('create runs XcodeGen and CocoaPods after writing specs', () async {
    final root = await Directory.systemTemp.createTemp('swift_get_create_');
    final output = StringBuffer();
    final xcodeGen = RecordingXcodeGenProjectGenerator();
    final cocoaPods = RecordingCocoaPodsInstaller();
    final runner = SwiftGetCommandRunner(
      output: output,
      xcodeGenProjectGenerator: xcodeGen,
      cocoaPodsInstaller: cocoaPods,
    );

    await runner.run([
      'create',
      'DemoApp',
      '--bundle-id',
      'com.example.demo',
      '--path',
      root.path,
    ]);

    expect(xcodeGen.projectDirectory, '${root.path}/DemoApp');
    expect(xcodeGen.specPath, '${root.path}/DemoApp/project.yml');
    expect(xcodeGen.dryRun, isFalse);
    expect(cocoaPods.projectDirectory, '${root.path}/DemoApp');
    expect(cocoaPods.dryRun, isFalse);
    expect(File('${root.path}/DemoApp/project.yml').existsSync(), isTrue);
    expect(File('${root.path}/DemoApp/Podfile').existsSync(), isTrue);
    expect(output.toString(), contains('Generated Xcode project'));
    expect(output.toString(), contains('Installed CocoaPods'));
  });

  test('generate module dry-run prints planned files', () async {
    final root = await Directory.systemTemp.createTemp('swift_get_module_');
    final output = StringBuffer();
    final runner = SwiftGetCommandRunner(output: output);

    await runner.run([
      'generate',
      'module',
      'Login',
      '--project',
      root.path,
      '--dry-run',
    ]);

    expect(output.toString(), contains('Would generate'));
    expect(output.toString(), contains('Login/LoginViewController.swift'));
    expect(output.toString(), contains('Login/LoginService.swift'));
  });
}
