import 'package:flutter_test/flutter_test.dart';
import 'package:gotrek_app/core/utils/validators.dart';

void main() {
  group('Validators.email', () {
    test('accepts a well-formed address', () {
      expect(Validators.email('chiraz@example.com'), isNull);
    });

    test('rejects empty and malformed addresses', () {
      expect(Validators.email(''), isNotNull);
      expect(Validators.email('chiraz@'), isNotNull);
      expect(Validators.email('chiraz.example.com'), isNotNull);
    });
  });

  group('Validators.password', () {
    test('accepts eight or more characters containing a digit', () {
      expect(Validators.password('trekking1'), isNull);
    });

    test('rejects short passwords and ones without a digit', () {
      expect(Validators.password('trek1'), isNotNull);
      expect(Validators.password('trekkingtrip'), isNotNull);
    });
  });

  group('Validators.emailOrPhone', () {
    test('accepts either form', () {
      expect(Validators.emailOrPhone('chiraz@example.com'), isNull);
      expect(Validators.emailOrPhone('+213 655 286 003'), isNull);
    });

    test('rejects anything else', () {
      expect(Validators.emailOrPhone('abc'), isNotNull);
    });
  });

  test('confirmPassword compares against the original', () {
    expect(Validators.confirmPassword('trekking1', 'trekking1'), isNull);
    expect(Validators.confirmPassword('trekking2', 'trekking1'), isNotNull);
  });
}
