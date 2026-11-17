import 'package:sqflite/sqflite.dart';

import '../core/database/local_database.dart';
import '../models/report_models.dart';
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

  /* Global history of the store, newest first, in a single query (JOIN with
  the item for name/unit and LEFT JOIN with the sale for its reference).
  Optional filters: [catalogItemId] and [movementType]. Paged with
  [limit]/[offset]; ties on created_at are broken by id so pages are stable.
  businessUnitId is strict scope (mandatory). */
  Future<List<StockMovementRow>> getHistory({
    required int businessUnitId,
    int? catalogItemId,
    String? movementType,
    required int limit,
    int offset = 0,
    Transaction? txn,
  }) async {
    final executor = txn ?? await _localDatabase.database;

    final conditions = <String>['sm.business_unit_id = ?'];
    final args = <Object?>[businessUnitId];
    if (catalogItemId != null) {
      conditions.add('sm.catalog_item_id = ?');
      args.add(catalogItemId);
    }
    if (movementType != null) {
      conditions.add('sm.movement_type = ?');
      args.add(movementType);
    }

    final rows = await executor.rawQuery('''
      SELECT sm.*,
             ci.name AS item_name,
             ci.unit AS item_unit,
             s.reference AS sale_reference
      FROM stock_movement sm
      JOIN catalog_item ci ON ci.id_catalog_item = sm.catalog_item_id
      LEFT JOIN sale s ON s.id_sale = sm.sale_id
      WHERE ${conditions.join(' AND ')}
      ORDER BY sm.created_at DESC, sm.id_stock_movement DESC
      LIMIT ? OFFSET ?
    ''', [...args, limit, offset]);

    return rows.map(StockMovementRow.fromMap).toList();
  }

  /* Products of the store with their balance, in a single query. Included:
  every live product, and deleted products that still hold stock.
  [categoryId] and [search] (name) are optional filters.
  businessUnitId is strict scope (mandatory). */
  Future<List<StockBalanceRow>> getBalances({
    required int businessUnitId,
    String? search,
    int? categoryId,
    Transaction? txn,
  }) async {
    final executor = txn ?? await _localDatabase.database;
    final args = <Object?>[businessUnitId];
    var filters = '';
    if (categoryId != null) {
      filters += ' AND ci.category_id = ?';
      args.add(categoryId);
    }
    if (search != null && search.trim().isNotEmpty) {
      filters += ' AND ci.name LIKE ?';
      args.add('%${search.trim()}%');
    }

    final rows = await executor.rawQuery('''
      SELECT ci.*,
             COALESCE(SUM(sm.quantity_milli), 0) AS balance_milli,
             COUNT(sm.id_stock_movement) AS movement_count
      FROM catalog_item ci
      LEFT JOIN stock_movement sm ON sm.catalog_item_id = ci.id_catalog_item
      WHERE ci.business_unit_id = ? AND ci.item_type = 'PRODUCT'$filters
      GROUP BY ci.id_catalog_item
      HAVING ci.deleted = 0 OR COALESCE(SUM(sm.quantity_milli), 0) > 0
      ORDER BY ci.name COLLATE NOCASE ASC
    ''', args);

    return rows.map(StockBalanceRow.fromMap).toList();
  }

    /* Losses (LOSS movements) of the store in the period, grouped by product,
  valued at cost: quantity x the cost saved in the movement, or the current
  product cost when the movement has none. Same rounding as the margin report
  ((milli * cents + 500) / 1000). A loss valued at 0 is counted in
  missing_cost_lines so the UI can flag it. */
  Future<List<ItemLossRow>> getLossesByItem({
    required int businessUnitId,
    required DateTime startDate,
    required DateTime endDate,
    Transaction? txn,
  }) async {
    final executor = txn ?? await _localDatabase.database;
    final rows = await executor.rawQuery(
      '''
      SELECT sm.catalog_item_id AS catalog_item_id,
             ci.name AS item_name,
             ci.unit AS unit,
             SUM(-sm.quantity_milli) AS quantity_milli,
             SUM((-sm.quantity_milli *
                  COALESCE(sm.unit_cost_cents, ci.cost_price_cents) + 500)
                 / 1000) AS value_cents,
             SUM(CASE WHEN COALESCE(sm.unit_cost_cents,
                                    ci.cost_price_cents) = 0
                      THEN 1 ELSE 0 END) AS missing_cost_lines
      FROM stock_movement sm
      JOIN catalog_item ci ON ci.id_catalog_item = sm.catalog_item_id
      WHERE sm.business_unit_id = ?
        AND sm.movement_type = 'LOSS'
        AND sm.created_at >= ?
        AND sm.created_at <= ?
      GROUP BY sm.catalog_item_id
      ORDER BY value_cents DESC
      ''',
      [
        businessUnitId,
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
    );
    return rows.map(ItemLossRow.fromMap).toList();
  }
}