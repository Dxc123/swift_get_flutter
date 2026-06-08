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
        'Add SnapKit Swift Package reference',
      ],
    );
  }
}

const _templates = [
  PlannedFile(relativePath: '{{appName}}/App/AppDelegate.swift', contents: _appDelegate),
  PlannedFile(relativePath: '{{appName}}/App/SceneDelegate.swift', contents: _sceneDelegate),
  PlannedFile(relativePath: '{{appName}}/App/AppCoordinator.swift', contents: _appCoordinator),
  PlannedFile(relativePath: '{{appName}}/Modules/Home/HomeViewController.swift', contents: _homeViewController),
  PlannedFile(relativePath: '{{appName}}/Modules/Home/HomeView.swift', contents: _homeView),
  PlannedFile(relativePath: '{{appName}}/Modules/Home/HomeViewModel.swift', contents: _homeViewModel),
  PlannedFile(relativePath: '{{appName}}/Resources/Info.plist', contents: _infoPlist),
  PlannedFile(relativePath: '{{appName}}Tests/{{appName}}Tests.swift', contents: _tests),
  PlannedFile(relativePath: '{{appName}}.xcodeproj/project.pbxproj', contents: _pbxproj),
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
        let navigationController = UINavigationController()
        let coordinator = AppCoordinator(navigationController: navigationController)
        coordinator.start()
        window.rootViewController = navigationController
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
    private let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let viewModel = HomeViewModel()
        let viewController = HomeViewController(viewModel: viewModel)
        navigationController.setViewControllers([viewController], animated: false)
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
        backgroundColor = .systemBackground
        titleLabel.text = "Home"
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
    let title = "Home"
}
''';

const _infoPlist = '''
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleIdentifier</key>
    <string>{{bundleId}}</string>
    <key>UIApplicationSceneManifest</key>
    <dict>
        <key>UIApplicationSupportsMultipleScenes</key>
        <false/>
    </dict>
</dict>
</plist>
''';

const _tests = '''
import XCTest
@testable import {{appName}}

final class {{appName}}Tests: XCTestCase {
    func testHomeTitle() {
        XCTAssertEqual(HomeViewModel().title, "Home")
    }
}
''';

const _pbxproj = r'''
// !$*UTF8*$!
{
    archiveVersion = 1;
    objectVersion = 56;
    classes = {};
    objects = {};
    rootObject = 000000000000000000000000;
}
''';

const _readme = '''
# {{appName}}

Generated by swift-get.

- Architecture: UIKit + MVVM + Coordinator
- Layout: SnapKit
- Deployment target: iOS 15+
''';
