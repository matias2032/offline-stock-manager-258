/* Pure data class representing a row in the `catalog_item` table: a
product or a service. Strict scope: belongs to exactly one store.
`updated_at` is omitted from [toMap] (set by trg_catalog_item_updated).

Every product always has stock (the balance lives in stock_movement) and
there is a single cost: [costPriceCents]. Services have no stock, no cost
and no category. */
class CatalogItemModel {
  const CatalogItemModel({
    this.idCatalogItem,
    required this.businessUnitId,
    required this.itemType,
    required this.name,
    this.description,
    this.categoryId,
    this.unit = 'UN',
    required this.salePriceCents,
    this.costPriceCents = 0,
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
  final String name;
  final String? description;
  final int? categoryId;
  final String unit;
  final int salePriceCents;

  /// The only cost of a product. Purchases update it; sales snapshot it.
  final int costPriceCents;
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
      name: map['name'] as String,
      description: map['description'] as String?,
      categoryId: map['category_id'] as int?,
      unit: map['unit'] as String,
      salePriceCents: map['sale_price_cents'] as int,
      costPriceCents: map['cost_price_cents'] as int,
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
      'name': name,
      'description': description,
      'category_id': categoryId,
      'unit': unit,
      'sale_price_cents': salePriceCents,
      'cost_price_cents': costPriceCents,
      'active': active ? 1 : 0,
      'deleted': deleted ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  CatalogItemModel copyWith({
    int? idCatalogItem,
    int? businessUnitId,
    String? itemType,
    String? name,
    String? description,
    bool clearDescription = false,
    int? categoryId,
    bool clearCategoryId = false,
    String? unit,
    int? salePriceCents,
    int? costPriceCents,
    bool? active,
    bool? deleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CatalogItemModel(
      idCatalogItem: idCatalogItem ?? this.idCatalogItem,
      businessUnitId: businessUnitId ?? this.businessUnitId,
      itemType: itemType ?? this.itemType,
      name: name ?? this.name,
      description:
          clearDescription ? null : (description ?? this.description),
      categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
      unit: unit ?? this.unit,
      salePriceCents: salePriceCents ?? this.salePriceCents,
      costPriceCents: costPriceCents ?? this.costPriceCents,
      active: active ?? this.active,
      deleted: deleted ?? this.deleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}