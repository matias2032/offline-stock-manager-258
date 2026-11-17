import 'stock_movement_model.dart';

/* Read models for the reports (stock value, margin per item, losses).
Nothing here is stored: everything is derived from the stock ledger and the
sale line snapshots, and none of it enters the statement balance (which stays
cash-based). */

/// One product with stock on hand and what that stock is worth at reference cost.
class StockValueRow {
  const StockValueRow({required this.row, required this.valueCents});

  final StockBalanceRow row;
  final int valueCents;

  /// Items without a reference cost are valued at 0 and flagged in the UI.
  bool get hasCost => row.item.costPriceCents > 0;
}

class StockReport {
  const StockReport({
    required this.valueRows,
    required this.lowStockCount,
    required this.totalValueCents,
  });

  /// Products with balance > 0, most valuable first.
  final List<StockValueRow> valueRows;

  /* How many products are at or below the fixed alert threshold: the same
  count as the "Low stock" filter of the Stock screen. Only the number is
  kept (it feeds the dashboard card); the list itself lives in Stock. */
  final int lowStockCount;

  final int totalValueCents;

  int get itemsWithoutCost => valueRows.where((r) => !r.hasCost).length;

  bool get isEmpty => valueRows.isEmpty && lowStockCount == 0;
}

/// Sales of one catalog item in a period, from the sale_item snapshots.
class ItemMarginRow {
  const ItemMarginRow({
    required this.catalogItemId,
    required this.itemName,
    required this.itemType,
    required this.unit,
    required this.quantityMilli,
    required this.revenueCents,
    required this.costCents,
    required this.hasMissingCost,
  });

  final int catalogItemId;
  final String itemName;
  final String itemType;
  final String unit;
  final int quantityMilli;
  final int revenueCents;
  final int costCents;

  /// A product was sold with a cost of 0 in the snapshot, so its margin is overstated.
  final bool hasMissingCost;

  int get marginCents => revenueCents - costCents;

  /// Null when there is no revenue to divide by.
  double? get marginPercent =>
      revenueCents > 0 ? marginCents * 100 / revenueCents : null;

  factory ItemMarginRow.fromMap(Map<String, Object?> map) {
    return ItemMarginRow(
      catalogItemId: map['catalog_item_id'] as int,
      itemName: map['item_name'] as String,
      itemType: map['item_type'] as String,
      unit: map['unit'] as String,
      quantityMilli: (map['quantity_milli'] as num).toInt(),
      revenueCents: (map['revenue_cents'] as num).toInt(),
      costCents: (map['cost_cents'] as num).toInt(),
      hasMissingCost: (map['missing_cost_lines'] as num).toInt() > 0,
    );
  }
}

class MarginReport {
  const MarginReport({
    required this.rows,
    required this.totalRevenueCents,
    required this.totalCostCents,
    required this.customSales,
  });

  /// Highest margin first. Catalog items only.
  final List<ItemMarginRow> rows;
  final int totalRevenueCents;
  final int totalCostCents;

  /// Custom lines of the period: shown apart, never part of the margin totals.
  final CustomSalesSummary customSales;

  int get totalMarginCents => totalRevenueCents - totalCostCents;

  double? get marginPercent =>
      totalRevenueCents > 0 ? totalMarginCents * 100 / totalRevenueCents : null;
}

/* Custom ("avulso") lines sold in a period. They have no cost, so their
margin is unknown: the report shows revenue and line count only. */
class CustomSalesSummary {
  const CustomSalesSummary({
    required this.lineCount,
    required this.revenueCents,
  });

  final int lineCount;
  final int revenueCents;

  bool get isEmpty => lineCount == 0;
}

/// Losses (LOSS movements) of one product in a period, valued at cost.
class ItemLossRow {
  const ItemLossRow({
    required this.catalogItemId,
    required this.itemName,
    required this.unit,
    required this.quantityMilli,
    required this.valueCents,
    required this.hasMissingCost,
  });

  final int catalogItemId;
  final String itemName;
  final String unit;

  /// Positive quantity lost, in thousandths of the unit.
  final int quantityMilli;
  final int valueCents;

  /// At least one loss had no cost at all, so the value is understated.
  final bool hasMissingCost;

  factory ItemLossRow.fromMap(Map<String, Object?> map) {
    return ItemLossRow(
      catalogItemId: map['catalog_item_id'] as int,
      itemName: map['item_name'] as String,
      unit: map['unit'] as String,
      quantityMilli: (map['quantity_milli'] as num).toInt(),
      valueCents: (map['value_cents'] as num).toInt(),
      hasMissingCost: (map['missing_cost_lines'] as num).toInt() > 0,
    );
  }
}

class LossReport {
  const LossReport({required this.rows});

  /// Highest value first.
  final List<ItemLossRow> rows;

  int get totalValueCents => rows.fold<int>(0, (sum, r) => sum + r.valueCents);
  int get itemsWithoutCost => rows.where((r) => r.hasMissingCost).length;
  bool get isEmpty => rows.isEmpty;
}