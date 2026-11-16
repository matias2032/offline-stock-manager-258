import 'catalog_item_model.dart';

/* Pure data class representing a row in the `stock_movement` table.
The table is an append-only ledger: there is no updated_at and no
copy-and-edit flow. `quantity` is signed (+ in, - out). */
class StockMovementModel {
  const StockMovementModel({
    this.idStockMovement,
    required this.businessUnitId,
    required this.catalogItemId,
    required this.movementType,
    required this.quantityMilli,
    this.unitCostCents,
    this.saleId,
    this.expenseId,
    this.notes,
    required this.createdAt,
  });

  static const String typeInitial = 'INITIAL';
  static const String typePurchase = 'PURCHASE';
  static const String typeSale = 'SALE';
  static const String typeSaleReversal = 'SALE_REVERSAL';
  static const String typeAdjustmentIn = 'ADJUSTMENT_IN';
  static const String typeAdjustmentOut = 'ADJUSTMENT_OUT';
  static const String typeLoss = 'LOSS';

  final int? idStockMovement;
  final int businessUnitId;
  final int catalogItemId;
  final String movementType;
  /// Signed, in thousandths of the unit (+ in, - out). 2500 = 2.5.
  final int quantityMilli;
  final int? unitCostCents;
  final int? saleId;
  final int? expenseId;
  final String? notes;
  final DateTime createdAt;

  bool get isIncoming => quantityMilli > 0;

  factory StockMovementModel.fromMap(Map<String, Object?> map) {
    return StockMovementModel(
      idStockMovement: map['id_stock_movement'] as int?,
      businessUnitId: map['business_unit_id'] as int,
      catalogItemId: map['catalog_item_id'] as int,
      movementType: map['movement_type'] as String,
      quantityMilli: map['quantity_milli'] as int,
      unitCostCents: map['unit_cost_cents'] as int?,
      saleId: map['sale_id'] as int?,
      expenseId: map['expense_id'] as int?,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, Object?> toMap() {
    return {
      if (idStockMovement != null) 'id_stock_movement': idStockMovement,
      'business_unit_id': businessUnitId,
      'catalog_item_id': catalogItemId,
      'movement_type': movementType,
            'quantity_milli': quantityMilli,
      'unit_cost_cents': unitCostCents,
      'sale_id': saleId,
      'expense_id': expenseId,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  StockMovementModel copyWith({int? idStockMovement}) {
    return StockMovementModel(
      idStockMovement: idStockMovement ?? this.idStockMovement,
      businessUnitId: businessUnitId,
      catalogItemId: catalogItemId,
      movementType: movementType,
            quantityMilli: quantityMilli,
      unitCostCents: unitCostCents,
      saleId: saleId,
      expenseId: expenseId,
      notes: notes,
      createdAt: createdAt,
    );
  }
}

/* Read model: a catalog item plus its current balance (SUM of movements).
Built by a JOIN query, never stored. */
class StockBalanceRow {
  const StockBalanceRow({
    required this.item,
    required this.balanceMilli,
    required this.movementCount,
  });

  final CatalogItemModel item;
  /// SUM of movements, in thousandths of the unit.
  final int balanceMilli;
  final int movementCount;

  /// Below (or at) the alert threshold. Only when tracking is on and a minimum is set.
  bool get isLow =>
      item.trackStock &&
      item.minStockMilli > 0 &&
      balanceMilli <= item.minStockMilli;

  /// Tracking is on but nothing was ever registered.
  bool get needsInitialStock => item.trackStock && movementCount == 0;

  /// Purchases and initial stock are only accepted by live, tracked products.
  bool get canReceiveStock =>
      item.isProduct && item.trackStock && item.active && !item.deleted;

  factory StockBalanceRow.fromMap(Map<String, Object?> map) {
    return StockBalanceRow(
      item: CatalogItemModel.fromMap(map),
            balanceMilli: (map['balance_milli'] as num).toInt(),
      movementCount: (map['movement_count'] as num).toInt(),
    );
  }
}