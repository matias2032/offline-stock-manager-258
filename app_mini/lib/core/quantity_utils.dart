/* Quantity helpers. Quantities are stored as integers in thousandths of the
unit ("milli"): 2.5 m -> 2500, 3 kg -> 3000. This avoids floating point, where
0.1 + 0.2 != 0.3 would break balance checks. At most 3 decimals are accepted.
Same idea as MoneyUtils (cents). */
class QuantityUtils {
  QuantityUtils._();

  static const int scale = 1000;

  static final RegExp _pattern = RegExp(r'^\d+(\.\d{1,3})?$');

  /// "2,5" or "2.5" -> 2500. Returns null for invalid text, negatives or
  /// more than 3 decimals.
  static int? tryParseToMilli(String text) {
    final clean = text.trim().replaceAll(',', '.');
    if (!_pattern.hasMatch(clean)) return null;
    final parts = clean.split('.');
    final whole = int.parse(parts[0]);
    final fraction =
        parts.length == 2 ? int.parse(parts[1].padRight(3, '0')) : 0;
    return whole * scale + fraction;
  }

  /// Invalid text -> 0 (callers validate "> 0" separately).
  static int parseToMilli(String text) => tryParseToMilli(text) ?? 0;

  /// 2500 -> "2.5", 3000 -> "3", 1250 -> "1.25", -500 -> "-0.5".
  static String format(int milli) {
    final negative = milli < 0;
    final abs = milli.abs();
    final whole = abs ~/ scale;
    final fraction = abs % scale;
    var text = '$whole';
    if (fraction != 0) {
      final digits =
          fraction.toString().padLeft(3, '0').replaceFirst(RegExp(r'0+$'), '');
      text += '.$digits';
    }
    return negative ? '-$text' : text;
  }

  /// For pre-filling a text field.
  static String toInputText(int milli) => format(milli);

  /* quantity x unit price, in cents, rounded to the nearest cent.
  Integer math only: (milli * cents + 500) ~/ 1000. */
  static int lineSubtotalCents(int quantityMilli, int unitPriceCents) {
    return (quantityMilli * unitPriceCents + 500) ~/ scale;
  }
}