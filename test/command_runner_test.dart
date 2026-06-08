import 'dart:io';

import 'package:swift_get_flutter/src/commands/swift_get_command_runner.dart';
import 'package:test/test.dart';

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
    expect(Directory('${root.path}/DemoApp').existsSync(), isFalse);
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
