import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:swift_get_flutter/src/commands/swift_get_command_runner.dart';

Future<void> main(List<String> arguments) async {
  try {
    final code = await SwiftGetCommandRunner().run(arguments);
    exitCode = code ?? 0;
  } on UsageException catch (error) {
    stderr.writeln(error.message);
    stderr.writeln(error.usage);
    exitCode = 64;
  } on Object catch (error) {
    stderr.writeln('swift-get: $error');
    exitCode = 1;
  }
}
