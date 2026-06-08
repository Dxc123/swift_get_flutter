import 'dart:io';

import 'package:swift_get_flutter/src/scaffold/module_scaffolder.dart';
import 'package:swift_get_flutter/src/scaffold/project_scaffolder.dart';
import 'package:test/test.dart';

void main() {
  group('ProjectScaffolder', () {
    test('plans UIKit project files', () {
      final plan = const ProjectScaffolder().plan(
        ProjectTemplateContext(
          appName: 'DemoApp',
          bundleId: 'com.example.demo',
          organizationName: 'Example',
          destination: '/tmp/DemoApp',
        ),
      );

      expect(plan.files.map((file) => file.relativePath), contains('DemoApp/App/AppDelegate.swift'));
      expect(plan.files.map((file) => file.relativePath), contains('DemoApp/App/SceneDelegate.swift'));
      expect(plan.files.map((file) => file.relativePath), contains('DemoApp/App/AppCoordinator.swift'));
      expect(plan.files.map((file) => file.relativePath), contains('DemoApp/Modules/Home/HomeViewController.swift'));
      expect(plan.files.any((file) => file.contents.contains('import SnapKit')), isTrue);
    });
  });

  group('ModuleScaffolder', () {
    test('plans module MVVM and coordinator files', () {
      final plan = const ModuleScaffolder().planModule(
        const ModuleTemplateContext(
          name: 'Login',
          destination: '/tmp/DemoApp/DemoApp/Modules',
          includeService: true,
        ),
      );

      expect(plan.files.map((file) => file.relativePath), contains('Login/LoginViewController.swift'));
      expect(plan.files.map((file) => file.relativePath), contains('Login/LoginViewModel.swift'));
      expect(plan.files.map((file) => file.relativePath), contains('Login/LoginView.swift'));
      expect(plan.files.map((file) => file.relativePath), contains('Login/LoginCoordinator.swift'));
      expect(plan.files.map((file) => file.relativePath), contains('Login/LoginService.swift'));
    });

    test('plans page files without service', () {
      final plan = const ModuleScaffolder().planModule(
        const ModuleTemplateContext(
          name: 'Profile',
          destination: '/tmp/DemoApp/DemoApp/Modules/Account',
          includeService: false,
        ),
      );

      expect(plan.files.map((file) => file.relativePath), contains('Profile/ProfileViewController.swift'));
      expect(plan.files.map((file) => file.relativePath), isNot(contains('Profile/ProfileService.swift')));
    });
  });

  tearDown(() async {
    final generated = Directory('/tmp/DemoApp');
    if (generated.existsSync()) {
      await generated.delete(recursive: true);
    }
  });
}
