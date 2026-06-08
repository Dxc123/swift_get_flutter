import 'dart:io';

final class CocoaPodsResult {
  const CocoaPodsResult({required this.message, required this.installed});

  final String message;
  final bool installed;
}

abstract interface class CocoaPodsInstaller {
  Future<CocoaPodsResult> install({
    required String projectDirectory,
    bool dryRun = false,
  });
}

final class ProcessCocoaPodsInstaller implements CocoaPodsInstaller {
  const ProcessCocoaPodsInstaller();

  @override
  Future<CocoaPodsResult> install({
    required String projectDirectory,
    bool dryRun = false,
  }) async {
    if (dryRun) {
      return CocoaPodsResult(
        message: 'Would run pod install in $projectDirectory',
        installed: false,
      );
    }

    final result = await Process.run('pod', [
      'install',
    ], workingDirectory: projectDirectory);

    if (result.exitCode != 0) {
      final stderrText = (result.stderr as Object).toString().trim();
      final stdoutText = (result.stdout as Object).toString().trim();
      final details = [
        if (stderrText.isNotEmpty) stderrText,
        if (stdoutText.isNotEmpty) stdoutText,
      ].join('\n');
      throw ProcessException(
        'pod',
        ['install'],
        details.isEmpty
            ? 'CocoaPods failed. Install it with `sudo gem install cocoapods` or `brew install cocoapods` and try again.'
            : details,
        result.exitCode,
      );
    }

    return const CocoaPodsResult(
      message: 'Installed CocoaPods dependencies',
      installed: true,
    );
  }
}
