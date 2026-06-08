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

      expect(
        plan.files.map((file) => file.relativePath),
        contains('DemoApp/App/AppDelegate.swift'),
      );
      expect(
        plan.files.map((file) => file.relativePath),
        contains('DemoApp/App/SceneDelegate.swift'),
      );
      expect(
        plan.files.map((file) => file.relativePath),
        contains('DemoApp/App/AppCoordinator.swift'),
      );
      expect(
        plan.files.map((file) => file.relativePath),
        contains('DemoApp/Modules/Home/HomeViewController.swift'),
      );
      expect(
        plan.files.map((file) => file.relativePath),
        contains('DemoApp/Modules/Profile/ProfileViewController.swift'),
      );
      expect(
        plan.files.any((file) => file.contents.contains('import SnapKit')),
        isTrue,
      );
    });

    test('plans a production tab app with Home and Profile tabs', () {
      final plan = const ProjectScaffolder().plan(
        ProjectTemplateContext(
          appName: 'DemoApp',
          bundleId: 'com.example.demo',
          organizationName: 'Example',
          destination: '/tmp/DemoApp',
        ),
      );

      final appCoordinator = plan.files
          .singleWhere(
            (file) => file.relativePath == 'DemoApp/App/AppCoordinator.swift',
          )
          .contents;
      final homeViewModel = plan.files
          .singleWhere(
            (file) =>
                file.relativePath == 'DemoApp/Modules/Home/HomeViewModel.swift',
          )
          .contents;
      final profileViewModel = plan.files
          .singleWhere(
            (file) =>
                file.relativePath ==
                'DemoApp/Modules/Profile/ProfileViewModel.swift',
          )
          .contents;

      expect(appCoordinator, contains('UITabBarController'));
      expect(appCoordinator, contains('HomeViewController'));
      expect(appCoordinator, contains('ProfileViewController'));
      expect(appCoordinator, contains('UIImage(systemName: "house")'));
      expect(appCoordinator, contains('UIImage(systemName: "person")'));
      expect(homeViewModel, contains('let title = "首页"'));
      expect(profileViewModel, contains('let title = "我的"'));
    });

    test(
      'plans CocoaPods and XcodeGen files instead of a handwritten pbxproj',
      () {
        final plan = const ProjectScaffolder().plan(
          ProjectTemplateContext(
            appName: 'DemoApp',
            bundleId: 'com.example.demo',
            organizationName: 'Example',
            destination: '/tmp/DemoApp',
          ),
        );

        final projectSpec = plan.files
            .singleWhere((file) => file.relativePath == 'project.yml')
            .contents;
        final podfile = plan.files
            .singleWhere((file) => file.relativePath == 'Podfile')
            .contents;

        expect(
          plan.files.map((file) => file.relativePath),
          isNot(contains('DemoApp.xcodeproj/project.pbxproj')),
        );
        expect(projectSpec, contains('name: DemoApp'));
        expect(projectSpec, contains('type: application'));
        expect(projectSpec, contains('platform: iOS'));
        expect(
          projectSpec,
          contains('PRODUCT_BUNDLE_IDENTIFIER: com.example.demo'),
        );
        expect(projectSpec, isNot(contains('packages:')));
        expect(projectSpec, isNot(contains('package: SnapKit')));
        expect(podfile, contains("target 'DemoApp' do"));
        expect(podfile, contains("pod 'SnapKit'"));
      },
    );
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

      expect(
        plan.files.map((file) => file.relativePath),
        contains('Login/LoginViewController.swift'),
      );
      expect(
        plan.files.map((file) => file.relativePath),
        contains('Login/LoginViewModel.swift'),
      );
      expect(
        plan.files.map((file) => file.relativePath),
        contains('Login/LoginView.swift'),
      );
      expect(
        plan.files.map((file) => file.relativePath),
        contains('Login/LoginCoordinator.swift'),
      );
      expect(
        plan.files.map((file) => file.relativePath),
        contains('Login/LoginService.swift'),
      );
    });

    test('plans page files without service', () {
      final plan = const ModuleScaffolder().planModule(
        const ModuleTemplateContext(
          name: 'Profile',
          destination: '/tmp/DemoApp/DemoApp/Modules/Account',
          includeService: false,
        ),
      );

      expect(
        plan.files.map((file) => file.relativePath),
        contains('Profile/ProfileViewController.swift'),
      );
      expect(
        plan.files.map((file) => file.relativePath),
        isNot(contains('Profile/ProfileService.swift')),
      );
    });
  });

  tearDown(() async {
    final generated = Directory('/tmp/DemoApp');
    if (generated.existsSync()) {
      await generated.delete(recursive: true);
    }
  });
}
