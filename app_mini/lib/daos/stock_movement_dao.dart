import 'package:sqflite/sqflite.dart';

import '../core/database/local_database.dart';
import '../models/stock_movement_model.dart';

/* stock_movement_dao
Pure SQL access to the stock ledger. Insert-only: there is deliberately no
update or delete. No business rules here. */
class StockMovementDao {
  StockMovementDao(this._localDatabase);

  final LocalDatabase _localDatabase;

  Future<int> insertMovement(
    StockMovementModel movement, {
    Transaction? txn,
  }) async {
    final executor = txn ?? await _localDatabase.database;
    return executor.insert('stock_movement', movement.toMap());
  }

  /// Current balance of one item in thousandths of the unit:
  /// SUM(quantity_milli), 0 when it has no movements.
  Future<int> getBalance(int catalogItemId, {Transaction? txn}) async {
    final executor = txn ?? await _localDatabase.database;
    final rows = await executor.rawQuery(
      'SELECT COALESCE(SUM(quantity_milli), 0) AS balance_milli '
      'FROM stock_movement WHERE catalog_item_id = ?',
      [catalogItemId],
    );
    return (rows.first['balance_milli'] as num).toInt();
  }

  Future<int> countMovements(int catalogItemId, {Transaction? txn}) async {
    final executor = txn ?? await _localDatabase.database;
    final rows = await executor.rawQuery(
      'SELECT COUNT(*) AS total FROM stock_movement WHERE catalog_item_id = ?',
      [catalogItemId],
    );
    return (rows.first['total'] as num).toInt();
  }

  /// Most recent first. Ties on created_at are broken by id.
  Future<List<StockMovementModel>> getMovementsByItem(
    int catalogItemId, {
    Transaction? txn,
  }) async {
    final executor = txn ?? await _localDatabase.database;
    final rows = await executor.query(
      'stock_movement',
      where: 'catalog_item_id = ?',
      whereArgs: [catalogItemId],
      orderBy: 'created_at DESC, id_stock_movement DESC',
    );
    return rows.map(StockMovementModel.fromMap).toList();
  }

  /// Every movement tied to a sale (SALE and SALE_REVERSAL), oldest first.
  Future<List<StockMovementModel>> getMovementsBySale(
    int saleId, {
    Transaction? txn,
  }) async {
    final executor = txn ?? await _localDatabase.database;
    final rows = await executor.query(
      'stock_movement',
      where: 'sale_id = ?',
      whereArgs: [saleId],
      orderBy: 'id_stock_movement ASC',
    );
    return rows.map(StockMovementModel.fromMap).toList();
  }

  /* Products of the store with their balance. Included: live items with
  tracking on, live items that have movements (tracking was switched off
  later), and deleted items that still hold stock. businessUnitId is strict
  scope (mandatory). */
  Future<List<StockBalanceRow>> getBalances({
    required int businessUnitId,
    String? search,
    Transaction? txn,
  }) async {
    final executor = txn ?? await _localDatabase.database;
    final args = <Object?>[businessUnitId];
    var searchClause = '';
    if (search != null && search.trim().isNotEmpty) {
      searchClause = ' AND (ci.name LIKE ? OR ci.code LIKE ?)';
      final pattern = '%${search.trim()}%';
      args..add(pattern)..add(pattern);
    }

    final rows = await executor.rawQuery('''
      SELECT ci.*,
             COALESCE(SUM(sm.quantity_milli), 0) AS balance_milli,
             COUNT(sm.id_stock_movement) AS movement_count
      FROM catalog_item ci
      LEFT JOIN stock_movement sm ON sm.catalog_item_id = ci.id_catalog_item
      WHERE ci.business_unit_id = ? AND ci.item_type = 'PRODUCT'$searchClause
      GROUP BY ci.id_catalog_item
      HAVING (ci.deleted = 0
              AND (ci.track_stock = 1 OR COUNT(sm.id_stock_movement) > 0))
          OR (ci.deleted = 1 AND COALESCE(SUM(sm.quantity_milli), 0) > 0)
      ORDER BY ci.name COLLATE NOCASE ASC
    ''', args);

    return rows.map(StockBalanceRow.fromMap).toList();
  }
}