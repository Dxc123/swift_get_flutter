import 'dart:io';

import 'package:path/path.dart' as p;

final class XcodeGenResult {
  const XcodeGenResult({required this.message, required this.generated});

  final String message;
  final bool generated;
}

abstract interface class XcodeGenProjectGenerator {
  Future<XcodeGenResult> generate({
    required String projectDirectory,
    required String specPath,
    bool dryRun = false,
  });
}

final class ProcessXcodeGenProjectGenerator
    implements XcodeGenProjectGenerator {
  const ProcessXcodeGenProjectGenerator();

  @override
  Future<XcodeGenResult> generate({
    required String projectDirectory,
    required String specPath,
    bool dryRun = false,
  }) async {
    final projectName = p.basename(projectDirectory);
    if (dryRun) {
      return XcodeGenResult(
        message:
            'Would run xcodegen generate --spec $specPath --project $projectDirectory',
        generated: false,
      );
    }

    final result = await Process.run('xcodegen', [
      'generate',
      '--spec',
      specPath,
      '--project',
      projectDirectory,
    ], workingDirectory: projectDirectory);

    if (result.exitCode != 0) {
      final stderrText = (result.stderr as Object).toString().trim();
      final stdoutText = (result.stdout as Object).toString().trim();
      final details = [
        if (stderrText.isNotEmpty) stderrText,
        if (stdoutText.isNotEmpty) stdoutText,
      ].join('\n');
      throw ProcessException(
        'xcodegen',
        ['generate', '--spec', specPath, '--project', projectDirectory],
        details.isEmpty
            ? 'XcodeGen failed. Install it with `brew install xcodegen` and try again.'
            : details,
        result.exitCode,
      );
    }

    return XcodeGenResult(
      message: 'Generated $projectName.xcodeproj with XcodeGen',
      generated: true,
    );
  }
}
