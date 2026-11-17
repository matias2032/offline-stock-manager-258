import 'package:sqflite/sqflite.dart';

import '../core/database/local_database.dart';
import '../models/catalog_item_model.dart';

/* catalog_item_dao
Pure CRUD access to the catalog_item table. No business rules. */
class CatalogItemDao {
  CatalogItemDao(this._localDatabase);

  final LocalDatabase _localDatabase;

  Future<int> insertItem(CatalogItemModel item, {Transaction? txn}) async {
    final executor = txn ?? await _localDatabase.database;
    return executor.insert('catalog_item', item.toMap());
  }

  Future<int> updateItem(CatalogItemModel item, {Transaction? txn}) async {
    final executor = txn ?? await _localDatabase.database;
    return executor.update(
      'catalog_item',
      item.toMap(),
      where: 'id_catalog_item = ?',
      whereArgs: [item.idCatalogItem],
    );
  }

  Future<int> softDeleteItem(int idCatalogItem, {Transaction? txn}) async {
    final executor = txn ?? await _localDatabase.database;
    return executor.update(
      'catalog_item',
      {'deleted': 1},
      where: 'id_catalog_item = ?',
      whereArgs: [idCatalogItem],
    );
  }

  Future<int> setActive(
    int idCatalogItem,
    bool active, {
    Transaction? txn,
  }) async {
    final executor = txn ?? await _localDatabase.database;
    return executor.update(
      'catalog_item',
      {'active': active ? 1 : 0},
      where: 'id_catalog_item = ?',
      whereArgs: [idCatalogItem],
    );
  }

  /// Updates only the reference cost (used by stock purchases, inside their transaction).
  Future<int> updateCostPrice(
    int idCatalogItem,
    int costPriceCents, {
    Transaction? txn,
  }) async {
    final executor = txn ?? await _localDatabase.database;
    return executor.update(
      'catalog_item',
      {'cost_price_cents': costPriceCents},
      where: 'id_catalog_item = ?',
      whereArgs: [idCatalogItem],
    );
  }

  /// Detaches every item from a category (used when the category is deleted).
  Future<int> clearCategory(int categoryId, {Transaction? txn}) async {
    final executor = txn ?? await _localDatabase.database;
    return executor.update(
      'catalog_item',
      {'category_id': null},
      where: 'category_id = ?',
      whereArgs: [categoryId],
    );
  }

  Future<CatalogItemModel?> getItemById(
    int idCatalogItem, {
    Transaction? txn,
  }) async {
    final executor = txn ?? await _localDatabase.database;
    final rows = await executor.query(
      'catalog_item',
      where: 'id_catalog_item = ?',
      whereArgs: [idCatalogItem],
    );
    if (rows.isEmpty) return null;
    return CatalogItemModel.fromMap(rows.first);
  }

  /* businessUnitId is strict scope (mandatory). Filters combine with AND.
  [search] matches the name (case-insensitive). */
  Future<List<CatalogItemModel>> getAllItems({
    required int businessUnitId,
    String? itemType,
    int? categoryId,
    String? search,
    bool onlyActive = false,
    bool includeDeleted = false,
    Transaction? txn,
  }) async {
    final executor = txn ?? await _localDatabase.database;

    final conditions = <String>['business_unit_id = ?'];
    final args = <Object?>[businessUnitId];

    if (!includeDeleted) conditions.add('deleted = 0');
    if (onlyActive) conditions.add('active = 1');
    if (itemType != null) {
      conditions.add('item_type = ?');
      args.add(itemType);
    }
    if (categoryId != null) {
      conditions.add('category_id = ?');
      args.add(categoryId);
    }
    if (search != null && search.trim().isNotEmpty) {
      conditions.add('name LIKE ?');
      args.add('%${search.trim()}%');
    }

    final rows = await executor.query(
      'catalog_item',
      where: conditions.join(' AND '),
      whereArgs: args,
      orderBy: 'name COLLATE NOCASE ASC',
    );
    return rows.map(CatalogItemModel.fromMap).toList();
  }

}