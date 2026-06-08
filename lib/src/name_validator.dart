final class NameValidator {
  static final _swiftTypeName = RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$');
  static final _bundlePart = RegExp(r'^[A-Za-z][A-Za-z0-9-]*$');

  static const _reservedWords = {
    'associatedtype',
    'class',
    'deinit',
    'enum',
    'extension',
    'fileprivate',
    'func',
    'import',
    'init',
    'inout',
    'internal',
    'let',
    'open',
    'operator',
    'private',
    'protocol',
    'public',
    'static',
    'struct',
    'subscript',
    'typealias',
    'var',
  };

  static void validateTypeName(String name) {
    if (!_swiftTypeName.hasMatch(name) || _reservedWords.contains(name)) {
      throw FormatException('Invalid Swift type name', name);
    }
  }

  static void validateBundleId(String bundleId) {
    final parts = bundleId.split('.');
    if (parts.length < 2 || parts.any((part) => !_bundlePart.hasMatch(part))) {
      throw FormatException('Invalid bundle id', bundleId);
    }
  }
}
