import 'package:intl/intl.dart';

/// Currency formatter utility for IDR and USD
class CurrencyFormatter {
  CurrencyFormatter._();

  static final _idrFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  /// Format currency based on currency code
  static String format(double amount, String currencyCode) {
    try {
      // Handle IDR specifically for no decimal places
      if (currencyCode.toUpperCase() == 'IDR') {
        return _idrFormat.format(amount);
      }

      return NumberFormat.simpleCurrency(
        name: currencyCode.toUpperCase(),
      ).format(amount);
    } catch (e) {
      // Fallback
      return '$currencyCode $amount';
    }
  }

  /// Format currency in compact form (e.g., Rp1.2M, $1.2K)
  static String formatCompact(double amount, String currencyCode) {
    try {
      return NumberFormat.compactSimpleCurrency(
        name: currencyCode.toUpperCase(),
      ).format(amount);
    } catch (e) {
      return '$currencyCode ${NumberFormat.compact().format(amount)}';
    }
  }

  /// Format without currency symbol
  static String formatNumber(double amount, String currencyCode) {
    final isIdr = currencyCode.toUpperCase() == 'IDR';
    final formatter = isIdr
        ? NumberFormat('#,##0', 'id_ID')
        : NumberFormat('#,##0.00', 'en_US');
    return formatter.format(amount);
  }

  /// Get currency symbol
  static String getSymbol(String currencyCode) {
    try {
      return NumberFormat.simpleCurrency(
        name: currencyCode.toUpperCase(),
      ).currencySymbol;
    } catch (e) {
      return currencyCode;
    }
  }

  /// Parse formatted currency string back to double
  static double parse(String formattedAmount, String currencyCode) {
    try {
      final cleanedAmount = formattedAmount
          .replaceAll(RegExp(r'[^\d.,]'), '')
          .replaceAll('.', '')
          .replaceAll(',', '.');
      return double.tryParse(cleanedAmount) ?? 0.0;
    } catch (e) {
      return 0.0;
    }
  }
}
