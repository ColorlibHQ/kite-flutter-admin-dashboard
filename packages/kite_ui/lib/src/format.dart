import 'package:intl/intl.dart';

/// Formatting helpers.
///
/// Money is always two decimals with a thousands separator — `$699.0` in a
/// table of currency reads as a bug, because it is one.
abstract final class KiteFormat {
  static String money(
    Object? value, {
    String? locale,
    String currency = 'USD',
  }) {
    final n = value is num ? value : num.tryParse('$value');
    return n == null
        ? '—'
        : NumberFormat.simpleCurrency(
            locale: locale,
            name: currency,
            decimalDigits: 2,
          ).format(n);
  }

  static String compactMoney(
    Object? value, {
    String? locale,
    String currency = 'USD',
  }) {
    final n = value is num ? value : num.tryParse('$value');
    return n == null
        ? '—'
        : NumberFormat.compactCurrency(
            locale: locale,
            name: currency,
          ).format(n);
  }

  static String count(Object? value, {String? locale}) {
    final n = value is num ? value : num.tryParse('$value');
    return n == null ? '—' : NumberFormat.decimalPattern(locale).format(n);
  }
}
