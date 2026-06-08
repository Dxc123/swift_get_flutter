final class TemplateRenderer {
  const TemplateRenderer();

  static final _variable = RegExp(r'{{\s*([A-Za-z0-9_]+)\s*}}');

  String render(String template, Map<String, String> values) {
    return template.replaceAllMapped(_variable, (match) {
      final key = match.group(1)!;
      final value = values[key];
      if (value == null) {
        throw FormatException('Unknown template variable', key);
      }
      return value;
    });
  }
}
