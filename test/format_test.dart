import 'package:flutter_test/flutter_test.dart';
import 'package:kite/kite_ui/format.dart';

void main() {
  group('KiteFormat.money', () {
    test('always shows two decimals', () {
      // The bug this guards: $699.0 in a column of currency reads as broken.
      expect(KiteFormat.money(699), r'$699.00');
      expect(KiteFormat.money(195.9), r'$195.90');
    });

    test('groups thousands', () {
      expect(KiteFormat.money(1264.55), r'$1,264.55');
    });

    test('parses numeric strings', () {
      expect(KiteFormat.money('42.5'), r'$42.50');
    });

    test('renders an em dash for values that are not numbers', () {
      expect(KiteFormat.money(null), '—');
      expect(KiteFormat.money('not a number'), '—');
    });
  });

  test('KiteFormat.count groups thousands', () {
    expect(KiteFormat.count(3412), '3,412');
  });
}
