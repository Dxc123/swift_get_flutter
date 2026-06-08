import 'package:swift_get_flutter/src/name_validator.dart';
import 'package:test/test.dart';

void main() {
  group('NameValidator', () {
    test('accepts valid Swift type names', () {
      expect(() => NameValidator.validateTypeName('Login'), returnsNormally);
      expect(() => NameValidator.validateTypeName('UserProfile'), returnsNormally);
      expect(() => NameValidator.validateTypeName('_Debug'), returnsNormally);
    });

    test('rejects invalid Swift type names', () {
      expect(() => NameValidator.validateTypeName('login-page'), throwsFormatException);
      expect(() => NameValidator.validateTypeName('1Login'), throwsFormatException);
      expect(() => NameValidator.validateTypeName('class'), throwsFormatException);
    });

    test('validates bundle identifiers', () {
      expect(() => NameValidator.validateBundleId('com.example.demo'), returnsNormally);
      expect(() => NameValidator.validateBundleId('demo'), throwsFormatException);
      expect(() => NameValidator.validateBundleId('com.1demo.app'), throwsFormatException);
    });
  });
}
