import 'package:intl/intl.dart';

/// Formatting helpers.
///
/// Money is always two decimals with a thousands separator — `$699.0` in a
/// table of currency reads as a bug, because it is one.
abstract final class KiteFormat {
  static final _money = NumberFormat.currency(symbol: r'$', decimalDigits: 2);
  static final _compactMoney = NumberFormat.compactCurrency(symbol: r'$');
  static final _int = NumberFormat.decimalPattern();

  static String money(Object? value) {
    final n = value is num ? value : num.tryParse('$value');
    return n == null ? '—' : _money.format(n);
  }

  static String compactMoney(Object? value) {
    final n = value is num ? value : num.tryParse('$value');
    return n == null ? '—' : _compactMoney.format(n);
  }

  static String count(Object? value) {
    final n = value is num ? value : num.tryParse('$value');
    return n == null ? '—' : _int.format(n);
  }
}
