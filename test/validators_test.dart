import 'package:flutter_test/flutter_test.dart';
import 'package:foodlink/core/utils/validators.dart';

void main() {
  group('Validators.validatePhoneNumber', () {
    test('accepts valid numbers and separators', () {
      expect(Validators.validatePhoneNumber('+92 300 1234567'), isNull);
      expect(Validators.validatePhoneNumber('0300-1234567'), isNull);
    });

    test('rejects invalid digit counts and plus-only input', () {
      expect(Validators.validatePhoneNumber('++++++++++'), isNotNull);
      expect(Validators.validatePhoneNumber('123456789'), isNotNull);
      expect(Validators.validatePhoneNumber('1234567890123456'), isNotNull);
    });
  });

  group('Validators.validatePositiveFiniteNumber', () {
    test('accepts positive finite values', () {
      expect(Validators.validatePositiveFiniteNumber('12'), isNull);
      expect(Validators.validatePositiveFiniteNumber('0.5'), isNull);
    });

    test('rejects empty, non-finite, zero, and negative values', () {
      for (final value in [
        null,
        '',
        'NaN',
        'Infinity',
        '-Infinity',
        '0',
        '-2',
      ]) {
        expect(
          Validators.validatePositiveFiniteNumber(value),
          isNotNull,
          reason: 'Expected $value to be rejected',
        );
      }
    });
  });
}
