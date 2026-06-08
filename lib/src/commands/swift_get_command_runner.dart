import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

import '../file_writer.dart';
import '../scaffold/module_scaffolder.dart';
import '../scaffold/project_scaffolder.dart';
import '../scaffold/scaffold_plan.dart';
import '../xcode/cocoapods_installer.dart';
import '../xcode/xcode_project_editor.dart';
import '../xcode/xcodegen_project_generator.dart';

final class SwiftGetCommandRunner extends CommandRunner<int> {
  SwiftGetCommandRunner({
    StringSink? output,
    FileWriter writer = const FileWriter(),
    XcodeProjectEditor xcodeProjectEditor = const XcodeProjectEditor(),
    XcodeGenProjectGenerator xcodeGenProjectGenerator =
        const ProcessXcodeGenProjectGenerator(),
    CocoaPodsInstaller cocoaPodsInstaller = const ProcessCocoaPodsInstaller(),
  }) : _output = output ?? stdout,
       super('swift-get', 'Scaffold Swift UIKit iOS apps and modules.') {
    addCommand(
      CreateCommand(
        output: _output,
        writer: writer,
        xcodeGenProjectGenerator: xcodeGenProjectGenerator,
        cocoaPodsInstaller: cocoaPodsInstaller,
      ),
    );
    addCommand(
      GenerateCommand(
        output: _output,
        writer: writer,
        xcodeProjectEditor: xcodeProjectEditor,
      ),
    );
  }

  final StringSink _output;

  @override
  Future<int?> run(Iterable<String> args) async {
    if (args.isEmpty || args.first == '--help' || args.first == '-h') {
      _output.writeln(usage);
      return 0;
    }
    return super.run(args);
  }
}

final class CreateCommand extends Command<int> {
  CreateCommand({
    required StringSink output,
    required FileWriter writer,
    required XcodeGenProjectGenerator xcodeGenProjectGenerator,
    required CocoaPodsInstaller cocoaPodsInstaller,
  }) : _output = output,
       _writer = writer,
       _xcodeGenProjectGenerator = xcodeGenProjectGenerator,
       _cocoaPodsInstaller = cocoaPodsInstaller {
    argParser
      ..addOption('bundle-id', mandatory: true)
      ..addOption('org', defaultsTo: 'Generated')
      ..addOption('path', defaultsTo: Directory.current.path)
      ..addFlag('force', negatable: false)
      ..addFlag('dry-run', negatable: false);
  }

  final StringSink _output;
  final FileWriter _writer;
  final XcodeGenProjectGenerator _xcodeGenProjectGenerator;
  final CocoaPodsInstaller _cocoaPodsInstaller;

  @override
  String get name => 'create';

  @override
  String get description => 'Create a UIKit MVVM iOS app scaffold.';

  @override
  Future<int> run() async {
    final appName = argResults!.rest.firstOrNull;
    if (appName == null) {
      throw UsageException('Missing required AppName.', usage);
    }

    final destination = p.join(argResults!['path'] as String, appName);
    final plan = const ProjectScaffolder().plan(
      ProjectTemplateContext(
        appName: appName,
        bundleId: argResults!['bundle-id'] as String,
        organizationName: argResults!['org'] as String,
        destination: destination,
      ),
    );

    await _writePlan(plan, action: 'create');
    final xcodeGenResult = await _xcodeGenProjectGenerator.generate(
      projectDirectory: destination,
      specPath: p.join(destination, 'project.yml'),
      dryRun: argResults!['dry-run'] as bool,
    );
    _output.writeln(xcodeGenResult.message);
    final cocoaPodsResult = await _cocoaPodsInstaller.install(
      projectDirectory: destination,
      dryRun: argResults!['dry-run'] as bool,
    );
    _output.writeln(cocoaPodsResult.message);
    return 0;
  }

  Future<void> _writePlan(ScaffoldPlan plan, {required String action}) async {
    final dryRun = argResults!['dry-run'] as bool;
    final paths = await _writer.write(
      plan,
      force: argResults!['force'] as bool,
      dryRun: dryRun,
    );
    _output.writeln(dryRun ? 'Would $action' : '${_capitalize(action)}d');
    for (final path in paths) {
      _output.writeln(path);
    }
  }
}

final class GenerateCommand extends Command<int> {
  GenerateCommand({
    required StringSink output,
    required FileWriter writer,
    required XcodeProjectEditor xcodeProjectEditor,
  }) {
    addSubcommand(
      GenerateModuleCommand(
        output: output,
        writer: writer,
        xcodeProjectEditor: xcodeProjectEditor,
      ),
    );
    addSubcommand(
      GeneratePageCommand(
        output: output,
        writer: writer,
        xcodeProjectEditor: xcodeProjectEditor,
      ),
    );
  }

  @override
  String get name => 'generate';

  @override
  String get description => 'Generate modules and pages.';
}

final class GenerateModuleCommand extends Command<int> {
  GenerateModuleCommand({
    required StringSink output,
    required FileWriter writer,
    required XcodeProjectEditor xcodeProjectEditor,
  }) : _output = output,
       _writer = writer,
       _xcodeProjectEditor = xcodeProjectEditor {
    argParser
      ..addOption('project', defaultsTo: Directory.current.path)
      ..addFlag('force', negatable: false)
      ..addFlag('dry-run', negatable: false);
  }

  final StringSink _output;
  final FileWriter _writer;
  final XcodeProjectEditor _xcodeProjectEditor;

  @override
  String get name => 'module';

  @override
  String get description => 'Generate a feature module.';

  @override
  Future<int> run() => _run(includeService: true);

  Future<int> _run({required bool includeService}) async {
    final moduleName = argResults!.rest.firstOrNull;
    if (moduleName == null) {
      throw UsageException('Missing required module name.', usage);
    }

    final project = argResults!['project'] as String;
    final plan = const ModuleScaffolder().planModule(
      ModuleTemplateContext(
        name: moduleName,
        destination: project,
        includeService: includeService,
      ),
    );

    await _write(plan);
    final edits = await _xcodeProjectEditor.apply(
      projectRoot: _findXcodeProjectRoot(project),
      edits: plan.projectEdits,
      dryRun: argResults!['dry-run'] as bool,
    );
    for (final edit in edits) {
      _output.writeln(edit);
    }
    return 0;
  }

  Future<void> _write(ScaffoldPlan plan) async {
    final dryRun = argResults!['dry-run'] as bool;
    final paths = await _writer.write(
      plan,
      force: argResults!['force'] as bool,
      dryRun: dryRun,
    );
    _output.writeln(dryRun ? 'Would generate' : 'Generated');
    for (final path in paths) {
      _output.writeln(path);
    }
  }
}

final class GeneratePageCommand extends Command<int> {
  GeneratePageCommand({
    required StringSink output,
    required FileWriter writer,
    required XcodeProjectEditor xcodeProjectEditor,
  }) : _output = output,
       _writer = writer,
       _xcodeProjectEditor = xcodeProjectEditor {
    argParser
      ..addOption('project', defaultsTo: Directory.current.path)
      ..addOption('module')
      ..addFlag('force', negatable: false)
      ..addFlag('dry-run', negatable: false);
  }

  final StringSink _output;
  final FileWriter _writer;
  final XcodeProjectEditor _xcodeProjectEditor;

  @override
  String get name => 'page';

  @override
  String get description => 'Generate a lightweight page.';

  @override
  Future<int> run() async {
    final pageName = argResults!.rest.firstOrNull;
    if (pageName == null) {
      throw UsageException('Missing required page name.', usage);
    }

    final project = argResults!['project'] as String;
    final module = argResults!['module'] as String?;
    final destination = module == null ? project : p.join(project, module);
    final plan = const ModuleScaffolder().planModule(
      ModuleTemplateContext(
        name: pageName,
        destination: destination,
        includeService: false,
      ),
    );

    final dryRun = argResults!['dry-run'] as bool;
    final paths = await _writer.write(
      plan,
      force: argResults!['force'] as bool,
      dryRun: dryRun,
    );
    _output.writeln(dryRun ? 'Would generate' : 'Generated');
    for (final path in paths) {
      _output.writeln(path);
    }
    final edits = await _xcodeProjectEditor.apply(
      projectRoot: _findXcodeProjectRoot(project),
      edits: plan.projectEdits,
      dryRun: dryRun,
    );
    for (final edit in edits) {
      _output.writeln(edit);
    }
    return 0;
  }
}

String _capitalize(String value) =>
    value.substring(0, 1).toUpperCase() + value.substring(1);

String _findXcodeProjectRoot(String projectPath) {
  final direct = Directory(projectPath);
  if (direct.path.endsWith('.xcodeproj')) {
    return direct.path;
  }

  if (direct.existsSync()) {
    for (final entity in direct.listSync()) {
      if (entity is Directory && entity.path.endsWith('.xcodeproj')) {
        return entity.path;
      }
    }
  }

  return projectPath;
}
