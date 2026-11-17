/* Fixed stock rules of the app. There is no per-item "minimum stock": every
product uses the same alert threshold, defined here and only here. Change
[lowStockThresholdMilli] to change it everywhere.

Quantities are in thousandths of the unit (5000 = 5 units). */
class StockRules {
  StockRules._();

  /// Alert when the balance is at or below 5 units.
  static const int lowStockThresholdMilli = 5000;

  /// Balance 0 (or less): shown as "Out of stock" and not sellable.
  static bool isOutOfStock(int balanceMilli) => balanceMilli <= 0;

  /// At or below the alert threshold. Includes out of stock.
  static bool isLow(int balanceMilli) =>
      balanceMilli <= lowStockThresholdMilli;
}