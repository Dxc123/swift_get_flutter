import '../name_validator.dart';
import '../template_renderer.dart';
import 'scaffold_plan.dart';

final class ProjectTemplateContext {
  const ProjectTemplateContext({
    required this.appName,
    required this.bundleId,
    required this.organizationName,
    required this.destination,
  });

  final String appName;
  final String bundleId;
  final String organizationName;
  final String destination;
}

final class ProjectScaffolder {
  const ProjectScaffolder();

  static const _renderer = TemplateRenderer();

  ScaffoldPlan plan(ProjectTemplateContext context) {
    NameValidator.validateTypeName(context.appName);
    NameValidator.validateBundleId(context.bundleId);

    final values = {
      'appName': context.appName,
      'bundleId': context.bundleId,
      'organizationName': context.organizationName,
    };

    return ScaffoldPlan(
      root: context.destination,
      files: [
        for (final template in _templates)
          PlannedFile(
            relativePath: _renderer.render(template.relativePath, values),
            contents: _renderer.render(template.contents, values),
          ),
      ],
      projectEdits: const [
        'Create app target',
        'Create test target',
        'Install SnapKit with CocoaPods',
      ],
    );
  }
}

const _templates = [
  PlannedFile(
    relativePath: '{{appName}}/App/AppDelegate.swift',
    contents: _appDelegate,
  ),
  PlannedFile(
    relativePath: '{{appName}}/App/SceneDelegate.swift',
    contents: _sceneDelegate,
  ),
  PlannedFile(
    relativePath: '{{appName}}/App/AppCoordinator.swift',
    contents: _appCoordinator,
  ),
  PlannedFile(
    relativePath: '{{appName}}/Modules/Main/MainViewController.swift',
    contents: _mainViewController,
  ),
  PlannedFile(
    relativePath: '{{appName}}/Modules/Home/HomeViewController.swift',
    contents: _homeViewController,
  ),
  PlannedFile(
    relativePath: '{{appName}}/Modules/Home/HomeView.swift',
    contents: _homeView,
  ),
  PlannedFile(
    relativePath: '{{appName}}/Modules/Home/HomeViewModel.swift',
    contents: _homeViewModel,
  ),
  PlannedFile(
    relativePath: '{{appName}}/Modules/Profile/ProfileViewController.swift',
    contents: _profileViewController,
  ),
  PlannedFile(
    relativePath: '{{appName}}/Modules/Profile/ProfileView.swift',
    contents: _profileView,
  ),
  PlannedFile(
    relativePath: '{{appName}}/Modules/Profile/ProfileViewModel.swift',
    contents: _profileViewModel,
  ),
  PlannedFile(relativePath: '{{appName}}/Info.plist', contents: _infoPlist),
  PlannedFile(
    relativePath: '{{appName}}/Assets.xcassets/Contents.json',
    contents: _assetCatalogContents,
  ),
  PlannedFile(
    relativePath:
        '{{appName}}/Assets.xcassets/AppIcon.appiconset/Contents.json',
    contents: _appIconContents,
  ),
  PlannedFile(
    relativePath:
        '{{appName}}/Assets.xcassets/AccentColor.colorset/Contents.json',
    contents: _accentColorContents,
  ),
  PlannedFile(
    relativePath: '{{appName}}/Base.lproj/LaunchScreen.storyboard',
    contents: _launchScreenStoryboard,
  ),
  PlannedFile(
    relativePath: '{{appName}}/Base.lproj/Main.storyboard',
    contents: _mainStoryboard,
  ),
  PlannedFile(
    relativePath: '{{appName}}Tests/{{appName}}Tests.swift',
    contents: _tests,
  ),
  PlannedFile(relativePath: 'project.yml', contents: _projectYml),
  PlannedFile(relativePath: 'Podfile', contents: _podfile),
  PlannedFile(relativePath: 'README.md', contents: _readme),
];

const _appDelegate = '''
import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        true
    }
}
''';

const _sceneDelegate = '''
import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var coordinator: AppCoordinator?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        let coordinator = AppCoordinator(window: window)
        coordinator.start()
        window.makeKeyAndVisible()
        self.window = window
        self.coordinator = coordinator
    }
}
''';

const _appCoordinator = '''
import UIKit

protocol Coordinator: AnyObject {
    func start()
}

final class AppCoordinator: Coordinator {
    private let window: UIWindow

    init(window: UIWindow) {
        self.window = window
    }

    func start() {
        window.rootViewController = MainViewController()
    }
}
''';

const _mainViewController = '''
import UIKit

final class MainViewController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        viewControllers = [
            makeHomeNavigationController(),
            makeProfileNavigationController()
        ]
    }

    private func makeHomeNavigationController() -> UINavigationController {
        let viewModel = HomeViewModel()
        let viewController = HomeViewController(viewModel: viewModel)
        viewController.tabBarItem = UITabBarItem(
            title: viewModel.title,
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )
        return UINavigationController(rootViewController: viewController)
    }

    private func makeProfileNavigationController() -> UINavigationController {
        let viewModel = ProfileViewModel()
        let viewController = ProfileViewController(viewModel: viewModel)
        viewController.tabBarItem = UITabBarItem(
            title: viewModel.title,
            image: UIImage(systemName: "person"),
            selectedImage: UIImage(systemName: "person.fill")
        )
        return UINavigationController(rootViewController: viewController)
    }
}
''';

const _homeViewController = '''
import UIKit

final class HomeViewController: UIViewController {
    private let rootView = HomeView()
    private let viewModel: HomeViewModel

    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = rootView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.title
    }
}
''';

const _homeView = '''
import UIKit
import SnapKit

final class HomeView: UIView {
    private let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        titleLabel.text = "首页"
        titleLabel.font = .preferredFont(forTextStyle: .largeTitle)
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
''';

const _homeViewModel = '''
import Foundation

final class HomeViewModel {
    let title = "首页"
}
''';

const _profileViewController = '''
import UIKit

final class ProfileViewController: UIViewController {
    private let rootView = ProfileView()
    private let viewModel: ProfileViewModel

    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = rootView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.title
    }
}
''';

const _profileView = '''
import UIKit
import SnapKit

final class ProfileView: UIView {
    private let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        titleLabel.text = "我的"
        titleLabel.font = .preferredFont(forTextStyle: .largeTitle)
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
''';

const _profileViewModel = '''
import Foundation

final class ProfileViewModel {
    let title = "我的"
}
''';

const _infoPlist = '''
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleIdentifier</key>
    <string>{{bundleId}}</string>
    <key>UILaunchStoryboardName</key>
    <string>LaunchScreen</string>
    <key>UIApplicationSceneManifest</key>
    <dict>
        <key>UISceneConfigurations</key>
        <dict>
            <key>UIWindowSceneSessionRoleApplication</key>
            <array>
                <dict>
                    <key>UISceneConfigurationName</key>
                    <string>Default Configuration</string>
                    <key>UISceneDelegateClassName</key>
                    <string>\$(PRODUCT_MODULE_NAME).SceneDelegate</string>
                </dict>
            </array>
        </dict>
        <key>UIApplicationSupportsMultipleScenes</key>
        <false/>
    </dict>
</dict>
</plist>
''';

const _assetCatalogContents = '''
{
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
''';

const _appIconContents = '''
{
  "images" : [
    {
      "idiom" : "universal",
      "platform" : "ios",
      "size" : "1024x1024"
    },
    {
      "appearances" : [
        {
          "appearance" : "luminosity",
          "value" : "dark"
        }
      ],
      "idiom" : "universal",
      "platform" : "ios",
      "size" : "1024x1024"
    },
    {
      "appearances" : [
        {
          "appearance" : "luminosity",
          "value" : "tinted"
        }
      ],
      "idiom" : "universal",
      "platform" : "ios",
      "size" : "1024x1024"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
''';

const _accentColorContents = '''
{
  "colors" : [
    {
      "idiom" : "universal"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
''';

const _launchScreenStoryboard = '''
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<document type="com.apple.InterfaceBuilder3.CocoaTouch.Storyboard.XIB" version="3.0" toolsVersion="13122.16" targetRuntime="iOS.CocoaTouch" propertyAccessControl="none" useAutolayout="YES" launchScreen="YES" useTraitCollections="YES" useSafeAreas="YES" colorMatched="YES" initialViewController="01J-lp-oVM">
    <dependencies>
        <plugIn identifier="com.apple.InterfaceBuilder.IBCocoaTouchPlugin" version="13104.12"/>
        <capability name="Safe area layout guides" minToolsVersion="9.0"/>
        <capability name="documents saved in the Xcode 8 format" minToolsVersion="8.0"/>
    </dependencies>
    <scenes>
        <!--View Controller-->
        <scene sceneID="EHf-IW-A2E">
            <objects>
                <viewController id="01J-lp-oVM" sceneMemberID="viewController">
                    <view key="view" contentMode="scaleToFill" id="Ze5-6b-2t3">
                        <rect key="frame" x="0.0" y="0.0" width="375" height="667"/>
                        <autoresizingMask key="autoresizingMask" widthSizable="YES" heightSizable="YES"/>
                        <color key="backgroundColor" white="1" alpha="1" colorSpace="custom" customColorSpace="genericGamma22GrayColorSpace"/>
                        <viewLayoutGuide key="safeArea" id="6Tk-OE-BBY"/>
                    </view>
                </viewController>
                <placeholder placeholderIdentifier="IBFirstResponder" id="iYj-Kq-Ea1" userLabel="First Responder" sceneMemberID="firstResponder"/>
            </objects>
            <point key="canvasLocation" x="53" y="375"/>
        </scene>
    </scenes>
</document>
''';

const _mainStoryboard = '''
<?xml version="1.0" encoding="UTF-8"?>
<document type="com.apple.InterfaceBuilder3.CocoaTouch.Storyboard.XIB" version="3.0" toolsVersion="13122.16" targetRuntime="iOS.CocoaTouch" propertyAccessControl="none" useAutolayout="YES" useTraitCollections="YES" useSafeAreas="YES" colorMatched="YES">
    <dependencies>
        <plugIn identifier="com.apple.InterfaceBuilder.IBCocoaTouchPlugin" version="13104.12"/>
        <capability name="Safe area layout guides" minToolsVersion="9.0"/>
        <capability name="documents saved in the Xcode 8 format" minToolsVersion="8.0"/>
    </dependencies>
    <scenes/>
</document>
''';

const _tests = '''
import XCTest
@testable import {{appName}}

final class {{appName}}Tests: XCTestCase {
    func testHomeTitle() {
        XCTAssertEqual(HomeViewModel().title, "首页")
    }

    func testProfileTitle() {
        XCTAssertEqual(ProfileViewModel().title, "我的")
    }
}
''';

const _projectYml = r'''
name: {{appName}}
options:
  bundleIdPrefix: {{bundleId}}
  deploymentTarget:
    iOS: 15.0
settings:
  base:
    SWIFT_VERSION: 5.0
targets:
  {{appName}}:
    type: application
    platform: iOS
    sources:
      - {{appName}}
    info:
      path: {{appName}}/Info.plist
    settings:
      base:
        PRODUCT_BUNDLE_IDENTIFIER: {{bundleId}}
        ASSETCATALOG_COMPILER_APPICON_NAME: AppIcon
        PRODUCT_NAME: $(TARGET_NAME)
        TARGETED_DEVICE_FAMILY: "1,2"
  {{appName}}Tests:
    type: bundle.unit-test
    platform: iOS
    sources:
      - {{appName}}Tests
    dependencies:
      - target: {{appName}}
    settings:
      base:
        PRODUCT_BUNDLE_IDENTIFIER: {{bundleId}}.tests
        TEST_HOST: $(BUILT_PRODUCTS_DIR)/{{appName}}.app/{{appName}}
''';

const _podfile = '''
platform :ios, '15.0'
use_frameworks!

target '{{appName}}' do
  pod 'SnapKit', '~> 5.7'

  target '{{appName}}Tests' do
    inherit! :search_paths
  end
end
''';

const _readme = '''
# {{appName}}

Generated by swift-get.

- Architecture: UIKit + MVVM + Coordinator
- Default main page: MainViewController tab container with 首页 and 我的
- Background: white
- Layout: SnapKit via CocoaPods
- Deployment target: iOS 15+
- Open {{appName}}.xcworkspace after creation

## Structure

```text
{{appName}}/
  App/
    AppDelegate.swift
    SceneDelegate.swift
    AppCoordinator.swift
  Modules/
    Main/
      MainViewController.swift
    Home/
      HomeViewController.swift
      HomeView.swift
      HomeViewModel.swift
    Profile/
      ProfileViewController.swift
      ProfileView.swift
      ProfileViewModel.swift
    Info.plist
    Assets.xcassets/
    Base.lproj/
```
''';
