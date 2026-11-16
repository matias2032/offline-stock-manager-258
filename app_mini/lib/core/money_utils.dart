import 'package:intl/intl.dart';

/* Money helpers for the new catalog/stock screens. Amounts are always
integer cents; these helpers only convert from/to what the user types
or sees. Existing screens keep their own local helpers untouched. */
class MoneyUtils {
  MoneyUtils._();

  static final NumberFormat _format = NumberFormat('#,##0.00');

  /// "12,50" or "12.50" -> 1250. Invalid text -> 0.
  static int parseToCents(String text) {
    final value = double.tryParse(text.trim().replaceAll(',', '.')) ?? 0;
    return (value * 100).round();
  }

  /// 1250 -> "12.50" (plain, for pre-filling a text field).
  static String toInputText(int cents) => (cents / 100).toStringAsFixed(2);

  /// 1250 -> "12.50" with thousands separators, for display.
  static String format(int cents) => _format.format(cents / 100);
}