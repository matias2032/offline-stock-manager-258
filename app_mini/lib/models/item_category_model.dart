/* Pure data class representing a row in the `item_category` table.
Strict scope: every category belongs to exactly one store.
`updated_at` is omitted from [toMap] (set by trg_item_category_updated). */
class ItemCategoryModel {
  const ItemCategoryModel({
    this.idItemCategory,
    required this.businessUnitId,
    required this.name,
    this.deleted = false,
    required this.createdAt,
    this.updatedAt,
  });

  final int? idItemCategory;
  final int businessUnitId;
  final String name;
  final bool deleted;
  final DateTime createdAt;
  final DateTime? updatedAt;

  factory ItemCategoryModel.fromMap(Map<String, Object?> map) {
    return ItemCategoryModel(
      idItemCategory: map['id_item_category'] as int?,
      businessUnitId: map['business_unit_id'] as int,
      name: map['name'] as String,
      deleted: (map['deleted'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  Map<String, Object?> toMap() {
    return {
      if (idItemCategory != null) 'id_item_category': idItemCategory,
      'business_unit_id': businessUnitId,
      'name': name,
      'deleted': deleted ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  ItemCategoryModel copyWith({
    int? idItemCategory,
    int? businessUnitId,
    String? name,
    bool? deleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ItemCategoryModel(
      idItemCategory: idItemCategory ?? this.idItemCategory,
      businessUnitId: businessUnitId ?? this.businessUnitId,
      name: name ?? this.name,
      deleted: deleted ?? this.deleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}