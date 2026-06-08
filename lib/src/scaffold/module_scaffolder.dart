import '../name_validator.dart';
import '../template_renderer.dart';
import 'scaffold_plan.dart';

final class ModuleTemplateContext {
  const ModuleTemplateContext({
    required this.name,
    required this.destination,
    required this.includeService,
  });

  final String name;
  final String destination;
  final bool includeService;
}

final class ModuleScaffolder {
  const ModuleScaffolder();

  static const _renderer = TemplateRenderer();

  ScaffoldPlan planModule(ModuleTemplateContext context) {
    NameValidator.validateTypeName(context.name);

    final values = {'moduleName': context.name};
    final templates = [
      ..._moduleTemplates,
      if (context.includeService) const PlannedFile(relativePath: '{{moduleName}}/{{moduleName}}Service.swift', contents: _service),
    ];

    return ScaffoldPlan(
      root: context.destination,
      files: [
        for (final template in templates)
          PlannedFile(
            relativePath: _renderer.render(template.relativePath, values),
            contents: _renderer.render(template.contents, values),
          ),
      ],
      projectEdits: [
        'Add ${context.name} files to app target',
      ],
    );
  }
}

const _moduleTemplates = [
  PlannedFile(relativePath: '{{moduleName}}/{{moduleName}}ViewController.swift', contents: _viewController),
  PlannedFile(relativePath: '{{moduleName}}/{{moduleName}}View.swift', contents: _view),
  PlannedFile(relativePath: '{{moduleName}}/{{moduleName}}ViewModel.swift', contents: _viewModel),
  PlannedFile(relativePath: '{{moduleName}}/{{moduleName}}Coordinator.swift', contents: _coordinator),
];

const _viewController = '''
import UIKit

final class {{moduleName}}ViewController: UIViewController {
    private let rootView = {{moduleName}}View()
    private let viewModel: {{moduleName}}ViewModel

    init(viewModel: {{moduleName}}ViewModel) {
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

const _view = '''
import UIKit
import SnapKit

final class {{moduleName}}View: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
''';

const _viewModel = '''
import Foundation

final class {{moduleName}}ViewModel {
    let title = "{{moduleName}}"
}
''';

const _coordinator = '''
import UIKit

final class {{moduleName}}Coordinator: Coordinator {
    private let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let viewModel = {{moduleName}}ViewModel()
        let viewController = {{moduleName}}ViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
}
''';

const _service = '''
import Foundation

protocol {{moduleName}}Servicing {}

final class {{moduleName}}Service: {{moduleName}}Servicing {}
''';
