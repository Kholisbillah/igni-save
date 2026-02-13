import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Formatting text input with thousand separators (dots) for IDR currency style.
/// Example: 20000 -> 20.000
class CurrencyInputFormatter extends TextInputFormatter {
  static const separator = '.';

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // If the new value is empty, return it.
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Only allow digits
    final cleanText = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    // If the cleaned text is empty (e.g. user typed only non-digits), return empty
    if (cleanText.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Parse the value
    final value = int.tryParse(cleanText) ?? 0;

    // Format with thousand separators
    final formatter = NumberFormat('#,###', 'id_ID');
    final newText = formatter.format(value);

    // Calculate new cursor position
    // We need to adjust the cursor based on how many separators were added/removed
    // Simple approach: position at end. Better approach: keep relative position.

    // Attempting to keep relative cursor position is complex with formatting.
    // However, basic implementation often just puts cursor at end for simplified numeric inputs.
    // Let's try to improve typical typing experience.

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }

  /// Helper to parse the formatted string back to a double
  static double parse(String formattedString) {
    if (formattedString.isEmpty) return 0.0;
    final cleanString = formattedString.replaceAll(RegExp(r'[^\d]'), '');
    return double.tryParse(cleanString) ?? 0.0;
  }
}
