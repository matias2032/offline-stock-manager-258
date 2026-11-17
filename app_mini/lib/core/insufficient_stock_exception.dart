import 'quantity_utils.dart';

/* Typed error for "not enough stock". Carries the data so the UI can show a
message in the active language; [toString] stays in English as a fallback
(it is what screens that only print the error will show). */
class InsufficientStockException implements Exception {
  const InsufficientStockException({
    required this.itemName,
    required this.balanceMilli,
    required this.requestedMilli,
  });

  final String itemName;

  /// Balance at the moment of the check, in thousandths of the unit.
  final int balanceMilli;

  /// Total quantity requested, in thousandths of the unit.
  final int requestedMilli;

  @override
  String toString() =>
      'Insufficient stock for "$itemName": balance is '
      '${QuantityUtils.format(balanceMilli)}, requested '
      '${QuantityUtils.format(requestedMilli)}.';
}