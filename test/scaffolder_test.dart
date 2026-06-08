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
        contains('DemoApp/Modules/Main/MainViewController.swift'),
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
        plan.files.map((file) => file.relativePath),
        contains('DemoApp/Info.plist'),
      );
      expect(
        plan.files.map((file) => file.relativePath),
        contains('DemoApp/Assets.xcassets/Contents.json'),
      );
      expect(
        plan.files.map((file) => file.relativePath),
        contains('DemoApp/Assets.xcassets/AppIcon.appiconset/Contents.json'),
      );
      expect(
        plan.files.map((file) => file.relativePath),
        contains('DemoApp/Assets.xcassets/AccentColor.colorset/Contents.json'),
      );
      expect(
        plan.files.map((file) => file.relativePath),
        contains('DemoApp/Base.lproj/LaunchScreen.storyboard'),
      );
      expect(
        plan.files.map((file) => file.relativePath),
        contains('DemoApp/Base.lproj/Main.storyboard'),
      );
      expect(
        plan.files.any((file) => file.contents.contains('import SnapKit')),
        isTrue,
      );
    });

    test('plans a main tab container with Home and Profile tabs', () {
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
      final mainViewController = plan.files
          .singleWhere(
            (file) =>
                file.relativePath ==
                'DemoApp/Modules/Main/MainViewController.swift',
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
      final homeView = plan.files
          .singleWhere(
            (file) =>
                file.relativePath == 'DemoApp/Modules/Home/HomeView.swift',
          )
          .contents;
      final profileView = plan.files
          .singleWhere(
            (file) =>
                file.relativePath ==
                'DemoApp/Modules/Profile/ProfileView.swift',
          )
          .contents;

      expect(appCoordinator, contains('MainViewController()'));
      expect(appCoordinator, isNot(contains('UITabBarController')));
      expect(appCoordinator, isNot(contains('HomeViewController')));
      expect(appCoordinator, isNot(contains('ProfileViewController')));
      expect(
        mainViewController,
        contains('final class MainViewController: UITabBarController'),
      );
      expect(mainViewController, contains('view.backgroundColor = .white'));
      expect(mainViewController, contains('HomeViewController'));
      expect(mainViewController, contains('ProfileViewController'));
      expect(mainViewController, contains('UIImage(systemName: "house")'));
      expect(mainViewController, contains('UIImage(systemName: "person")'));
      expect(homeView, contains('backgroundColor = .white'));
      expect(profileView, contains('backgroundColor = .white'));
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
        expect(projectSpec, contains('path: DemoApp/Info.plist'));
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
