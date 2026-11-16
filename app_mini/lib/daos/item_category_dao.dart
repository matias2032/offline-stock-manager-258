import 'package:sqflite/sqflite.dart';

import '../core/database/local_database.dart';
import '../models/item_category_model.dart';

/* item_category_dao
Pure CRUD access to the item_category table. No business rules. */
class ItemCategoryDao {
  ItemCategoryDao(this._localDatabase);

  final LocalDatabase _localDatabase;

  Future<int> insertCategory(
    ItemCategoryModel category, {
    Transaction? txn,
  }) async {
    final executor = txn ?? await _localDatabase.database;
    return executor.insert('item_category', category.toMap());
  }

  Future<int> updateCategory(
    ItemCategoryModel category, {
    Transaction? txn,
  }) async {
    final executor = txn ?? await _localDatabase.database;
    return executor.update(
      'item_category',
      category.toMap(),
      where: 'id_item_category = ?',
      whereArgs: [category.idItemCategory],
    );
  }

  Future<int> softDeleteCategory(int idItemCategory, {Transaction? txn}) async {
    final executor = txn ?? await _localDatabase.database;
    return executor.update(
      'item_category',
      {'deleted': 1},
      where: 'id_item_category = ?',
      whereArgs: [idItemCategory],
    );
  }

  Future<ItemCategoryModel?> getCategoryById(
    int idItemCategory, {
    Transaction? txn,
  }) async {
    final executor = txn ?? await _localDatabase.database;
    final rows = await executor.query(
      'item_category',
      where: 'id_item_category = ?',
      whereArgs: [idItemCategory],
    );
    if (rows.isEmpty) return null;
    return ItemCategoryModel.fromMap(rows.first);
  }

  Future<List<ItemCategoryModel>> getAllCategories({
    required int businessUnitId,
    bool includeDeleted = false,
    Transaction? txn,
  }) async {
    final executor = txn ?? await _localDatabase.database;
    final conditions = <String>['business_unit_id = ?'];
    if (!includeDeleted) conditions.add('deleted = 0');
    final rows = await executor.query(
      'item_category',
      where: conditions.join(' AND '),
      whereArgs: [businessUnitId],
      orderBy: 'name COLLATE NOCASE ASC',
    );
    return rows.map(ItemCategoryModel.fromMap).toList();
  }

  /// Case-insensitive; mirrors the partial unique index uq_item_category_name.
  Future<bool> nameExists({
    required int businessUnitId,
    required String name,
    int? excludeId,
    Transaction? txn,
  }) async {
    final executor = txn ?? await _localDatabase.database;
    final conditions = <String>[
      'business_unit_id = ?',
      'deleted = 0',
      'name = ? COLLATE NOCASE',
    ];
    final args = <Object?>[businessUnitId, name];
    if (excludeId != null) {
      conditions.add('id_item_category != ?');
      args.add(excludeId);
    }
    final rows = await executor.query(
      'item_category',
      where: conditions.join(' AND '),
      whereArgs: args,
      limit: 1,
    );
    return rows.isNotEmpty;
  }
}