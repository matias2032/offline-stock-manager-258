import 'catalog_item_model.dart';
import '../core/stock_rules.dart';

/* Pure data class representing a row in the `sale_item` table: one line of
a sale. It is an immutable snapshot (no updated_at): editing the catalog item
later never changes past sales. Quantity is in thousandths of the unit
(2500 = 2.5); prices are cents per ONE unit.

A line is either a catalog line (PRODUCT / SERVICE snapshot, with
[catalogItemId]) or a CUSTOM line typed by the seller (no catalog item, no
stock, no cost). */
class SaleItemModel {
  const SaleItemModel({
    this.idSaleItem,
    required this.saleId,
    this.catalogItemId,
    required this.itemNameSnapshot,
    required this.itemTypeSnapshot,
    this.unitSnapshot = 'UN',
    required this.quantityMilli,
    required this.unitPriceCents,
    this.unitCostCents = 0,
    required this.subtotalCents,
    required this.createdAt,
  });

  static const String typeCustom = 'CUSTOM';

  final int? idSaleItem;
  final int saleId;

  /// Null only for CUSTOM lines.
  final int? catalogItemId;
  final String itemNameSnapshot;
  final String itemTypeSnapshot; // 'PRODUCT' | 'SERVICE' | 'CUSTOM'
  final String unitSnapshot;
  final int quantityMilli;
  final int unitPriceCents;

  /// Reference cost at the moment of the sale (0 for services and custom).
  final int unitCostCents;
  final int subtotalCents;
  final DateTime createdAt;

  bool get isProduct => itemTypeSnapshot == CatalogItemModel.typeProduct;
  bool get isCustom => itemTypeSnapshot == typeCustom;

  factory SaleItemModel.fromMap(Map<String, Object?> map) {
    return SaleItemModel(
      idSaleItem: map['id_sale_item'] as int?,
      saleId: map['sale_id'] as int,
      catalogItemId: map['catalog_item_id'] as int?,
      itemNameSnapshot: map['item_name_snapshot'] as String,
      itemTypeSnapshot: map['item_type_snapshot'] as String,
      unitSnapshot: map['unit_snapshot'] as String,
      quantityMilli: map['quantity_milli'] as int,
      unitPriceCents: map['unit_price_cents'] as int,
      unitCostCents: map['unit_cost_cents'] as int,
      subtotalCents: map['subtotal_cents'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, Object?> toMap() {
    return {
      if (idSaleItem != null) 'id_sale_item': idSaleItem,
      'sale_id': saleId,
      'catalog_item_id': catalogItemId,
      'item_name_snapshot': itemNameSnapshot,
      'item_type_snapshot': itemTypeSnapshot,
      'unit_snapshot': unitSnapshot,
      'quantity_milli': quantityMilli,
      'unit_price_cents': unitPriceCents,
      'unit_cost_cents': unitCostCents,
      'subtotal_cents': subtotalCents,
      'created_at': createdAt.toIso8601String(),
    };
  }

  SaleItemModel copyWith({int? idSaleItem, int? saleId}) {
    return SaleItemModel(
      idSaleItem: idSaleItem ?? this.idSaleItem,
      saleId: saleId ?? this.saleId,
      catalogItemId: catalogItemId,
      itemNameSnapshot: itemNameSnapshot,
      itemTypeSnapshot: itemTypeSnapshot,
      unitSnapshot: unitSnapshot,
      quantityMilli: quantityMilli,
      unitPriceCents: unitPriceCents,
      unitCostCents: unitCostCents,
      subtotalCents: subtotalCents,
      createdAt: createdAt,
    );
  }
}

/* One line requested by the UI when creating a sale. Two kinds:
 - catalog line: [catalogItemId] set; [unitPriceCents] null means "use the
   catalog price", otherwise it is the price actually charged;
 - custom line (SaleLineInput.custom): [customName] + price, no catalog item,
   no stock.
The repository validates everything and ignores any total from the UI. */
class SaleLineInput {
  const SaleLineInput({
    this.catalogItemId,
    this.customName,
    required this.quantityMilli,
    this.unitPriceCents,
  });

  /// A free-text line: name and price typed by the seller, no stock.
  const SaleLineInput.custom({
    required String name,
    required this.quantityMilli,
    required int price,
  })  : catalogItemId = null,
        customName = name,
        unitPriceCents = price;

  final int? catalogItemId;
  final String? customName;
  final int quantityMilli;
  final int? unitPriceCents;

  bool get isCustom => catalogItemId == null;
}

/* Read model for the item picker: a live catalog item plus, for products,
its current balance in thousandths (null for services, which have no stock). */
class SellableItem {
  const SellableItem({required this.item, this.balanceMilli});

  final CatalogItemModel item;
  final int? balanceMilli;

  bool get tracksStock => balanceMilli != null;
  bool get isOutOfStock =>
      balanceMilli != null && StockRules.isOutOfStock(balanceMilli!);
  bool get isLowStock =>
      balanceMilli != null && StockRules.isLow(balanceMilli!);
}