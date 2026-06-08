import 'dart:io';

import 'package:swift_get_flutter/src/commands/swift_get_command_runner.dart';
import 'package:swift_get_flutter/src/xcode/cocoapods_installer.dart';
import 'package:swift_get_flutter/src/xcode/xcodegen_project_generator.dart';
import 'package:test/test.dart';

final class StubXcodeGenProjectGenerator implements XcodeGenProjectGenerator {
  @override
  Future<XcodeGenResult> generate({
    required String projectDirectory,
    required String specPath,
    bool dryRun = false,
  }) async {
    return const XcodeGenResult(
      message: 'Generated Xcode project',
      generated: true,
    );
  }
}

final class StubCocoaPodsInstaller implements CocoaPodsInstaller {
  @override
  Future<CocoaPodsResult> install({
    required String projectDirectory,
    bool dryRun = false,
  }) async {
    return const CocoaPodsResult(
      message: 'Installed CocoaPods',
      installed: true,
    );
  }
}

void main() {
  test('create writes a UIKit project scaffold', () async {
    final root = await Directory.systemTemp.createTemp(
      'swift_get_integration_create_',
    );
    final output = StringBuffer();

    await SwiftGetCommandRunner(
      output: output,
      xcodeGenProjectGenerator: StubXcodeGenProjectGenerator(),
      cocoaPodsInstaller: StubCocoaPodsInstaller(),
    ).run([
      'create',
      'DemoApp',
      '--bundle-id',
      'com.example.demo',
      '--path',
      root.path,
    ]);

    final appRoot = Directory('${root.path}/DemoApp');
    expect(
      File('${appRoot.path}/DemoApp/App/AppDelegate.swift').existsSync(),
      isTrue,
    );
    expect(
      File('${appRoot.path}/DemoApp/App/AppCoordinator.swift').existsSync(),
      isTrue,
    );
    expect(
      File(
        '${appRoot.path}/DemoApp/Modules/Home/HomeView.swift',
      ).readAsStringSync(),
      contains('import SnapKit'),
    );
    expect(
      File(
        '${appRoot.path}/DemoApp/Modules/Profile/ProfileView.swift',
      ).readAsStringSync(),
      contains('import SnapKit'),
    );
    expect(File('${appRoot.path}/project.yml').existsSync(), isTrue);
    expect(File('${appRoot.path}/Podfile').existsSync(), isTrue);
  });

  test('generate module writes module files', () async {
    final root = await Directory.systemTemp.createTemp(
      'swift_get_integration_module_',
    );
    final output = StringBuffer();

    await SwiftGetCommandRunner(
      output: output,
    ).run(['generate', 'module', 'Login', '--project', root.path]);

    expect(
      File('${root.path}/Login/LoginViewController.swift').existsSync(),
      isTrue,
    );
    expect(File('${root.path}/Login/LoginService.swift').existsSync(), isTrue);
  });

  test(
    'generate page under module writes page files without service',
    () async {
      final root = await Directory.systemTemp.createTemp(
        'swift_get_integration_page_',
      );
      final output = StringBuffer();

      await SwiftGetCommandRunner(output: output).run([
        'generate',
        'page',
        'Profile',
        '--project',
        root.path,
        '--module',
        'Account',
      ]);

      expect(
        File(
          '${root.path}/Account/Profile/ProfileViewController.swift',
        ).existsSync(),
        isTrue,
      );
      expect(
        File('${root.path}/Account/Profile/ProfileService.swift').existsSync(),
        isFalse,
      );
    },
  );
}
