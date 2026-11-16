/* Pure data class representing a row in the `catalog_item` table: a
product or a service. Strict scope: belongs to exactly one store.
`updated_at` is omitted from [toMap] (set by trg_catalog_item_updated). */
class CatalogItemModel {
  const CatalogItemModel({
    this.idCatalogItem,
    required this.businessUnitId,
    required this.itemType,
    this.code,
    required this.name,
    this.description,
    this.categoryId,
    this.unit = 'UN',
    required this.salePriceCents,
    this.costPriceCents = 0,
    this.trackStock = false,
    this.minStockMilli = 0,
    this.active = true,
    this.deleted = false,
    required this.createdAt,
    this.updatedAt,
  });

  static const String typeProduct = 'PRODUCT';
  static const String typeService = 'SERVICE';

  final int? idCatalogItem;
  final int businessUnitId;
  final String itemType; // 'PRODUCT' | 'SERVICE'
  final String? code;
  final String name;
  final String? description;
  final int? categoryId;
  final String unit;
  final int salePriceCents;

  /// Reference cost. From Phase 3 on it follows the last purchase cost.
  final int costPriceCents;
  final bool trackStock;
  /// Alert threshold in thousandths of the unit (2500 = 2.5).
  final int minStockMilli;
  final bool active;
  final bool deleted;
  final DateTime createdAt;
  final DateTime? updatedAt;

  bool get isProduct => itemType == typeProduct;
  bool get isService => itemType == typeService;
  int get marginCents => salePriceCents - costPriceCents;

  factory CatalogItemModel.fromMap(Map<String, Object?> map) {
    return CatalogItemModel(
      idCatalogItem: map['id_catalog_item'] as int?,
      businessUnitId: map['business_unit_id'] as int,
      itemType: map['item_type'] as String,
      code: map['code'] as String?,
      name: map['name'] as String,
      description: map['description'] as String?,
      categoryId: map['category_id'] as int?,
      unit: map['unit'] as String,
      salePriceCents: map['sale_price_cents'] as int,
      costPriceCents: map['cost_price_cents'] as int,
      trackStock: (map['track_stock'] as int) == 1,
      minStockMilli: map['min_stock_milli'] as int,
      active: (map['active'] as int) == 1,
      deleted: (map['deleted'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  Map<String, Object?> toMap() {
    return {
      if (idCatalogItem != null) 'id_catalog_item': idCatalogItem,
      'business_unit_id': businessUnitId,
      'item_type': itemType,
      'code': code,
      'name': name,
      'description': description,
      'category_id': categoryId,
      'unit': unit,
      'sale_price_cents': salePriceCents,
      'cost_price_cents': costPriceCents,
      'track_stock': trackStock ? 1 : 0,
      'min_stock_milli': minStockMilli,
      'active': active ? 1 : 0,
      'deleted': deleted ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  CatalogItemModel copyWith({
    int? idCatalogItem,
    int? businessUnitId,
    String? itemType,
    String? code,
    bool clearCode = false,
    String? name,
    String? description,
    bool clearDescription = false,
    int? categoryId,
    bool clearCategoryId = false,
    String? unit,
    int? salePriceCents,
    int? costPriceCents,
    bool? trackStock,
    int? minStockMilli,
    bool? active,
    bool? deleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CatalogItemModel(
      idCatalogItem: idCatalogItem ?? this.idCatalogItem,
      businessUnitId: businessUnitId ?? this.businessUnitId,
      itemType: itemType ?? this.itemType,
      code: clearCode ? null : (code ?? this.code),
      name: name ?? this.name,
      description:
          clearDescription ? null : (description ?? this.description),
      categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
      unit: unit ?? this.unit,
      salePriceCents: salePriceCents ?? this.salePriceCents,
      costPriceCents: costPriceCents ?? this.costPriceCents,
      trackStock: trackStock ?? this.trackStock,
      minStockMilli: minStockMilli ?? this.minStockMilli,
      active: active ?? this.active,
      deleted: deleted ?? this.deleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}