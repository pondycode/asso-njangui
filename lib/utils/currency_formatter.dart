import 'package:intl/intl.dart';

class CurrencyFormatter {
  static const String _currencySymbol = 'F';
  static const String _locale = 'fr_FR';

  /// Format amount as F currency
  static String format(double amount, {bool showSymbol = true}) {
    final formatter = NumberFormat.currency(
      locale: _locale,
      symbol: showSymbol ? '$_currencySymbol ' : '',
      decimalDigits: 0, // F typically doesn't use decimal places
    );
    return formatter.format(amount);
  }

  /// Format amount as F currency with compact notation (K, M, etc.)
  static String formatCompact(double amount, {bool showSymbol = true}) {
    final formatter = NumberFormat.compactCurrency(
      locale: _locale,
      symbol: showSymbol ? '$_currencySymbol ' : '',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  /// Format amount as simple number without currency symbol
  static String formatNumber(double amount) {
    final formatter = NumberFormat('#,##0', _locale);
    return formatter.format(amount);
  }

  /// Parse currency string to double
  static double? parse(String value) {
    try {
      // Remove currency symbol and spaces
      String cleanValue = value
          .replaceAll(_currencySymbol, '')
          .replaceAll(' ', '')
          .replaceAll(',', '');
      return double.tryParse(cleanValue);
    } catch (e) {
      return null;
    }
  }

  /// Get currency symbol
  static String get symbol => _currencySymbol;

  /// Get locale
  static String get locale => _locale;
}
