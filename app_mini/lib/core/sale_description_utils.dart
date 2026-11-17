/* Builds the generated sale description from item names only (no
quantities, those are visible in the sale detail). Repeated names are shown
once. With more than [maxVisibleNames] distinct names the rest is summarized:
"Cable, Delivery, Soap +2". */
class SaleDescriptionUtils {
  SaleDescriptionUtils._();

  static const int maxVisibleNames = 3;

  static String fromNames(Iterable<String> names) {
    final unique = <String>[];
    for (final name in names) {
      final trimmed = name.trim();
      if (trimmed.isEmpty) continue;
      final lower = trimmed.toLowerCase();
      if (!unique.any((u) => u.toLowerCase() == lower)) unique.add(trimmed);
    }

    if (unique.length <= maxVisibleNames) return unique.join(', ');

    final hidden = unique.length - maxVisibleNames;
    return '${unique.take(maxVisibleNames).join(', ')} +$hidden';
  }
}