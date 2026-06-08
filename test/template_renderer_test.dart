import 'package:swift_get_flutter/src/template_renderer.dart';
import 'package:test/test.dart';

void main() {
  group('TemplateRenderer', () {
    test('renders known variables', () {
      final output = const TemplateRenderer().render(
        'final class {{moduleName}}ViewController {}',
        {'moduleName': 'Login'},
      );

      expect(output, 'final class LoginViewController {}');
    });

    test('throws for unknown variables', () {
      expect(
        () => const TemplateRenderer().render('{{missing}}', const {}),
        throwsFormatException,
      );
    });
  });
}
