import 'package:sqflite/sqflite.dart';

import '../core/database/local_database.dart';
import '../models/report_models.dart';
import '../models/sale_item_model.dart';

/* sale_item_dao
Pure SQL access to the sale_item table. Insert and read only: lines are an
immutable snapshot, so there is no update or delete. No business rules. */
class SaleItemDao {
  SaleItemDao(this._localDatabase);

  final LocalDatabase _localDatabase;

  Future<int> insertItem(SaleItemModel item, {Transaction? txn}) async {
    final executor = txn ?? await _localDatabase.database;
    return executor.insert('sale_item', item.toMap());
  }

  Future<List<SaleItemModel>> getItemsBySale(
    int saleId, {
    Transaction? txn,
  }) async {
    final executor = txn ?? await _localDatabase.database;
    final rows = await executor.query(
      'sale_item',
      where: 'sale_id = ?',
      whereArgs: [saleId],
      orderBy: 'id_sale_item ASC',
    );
    return rows.map(SaleItemModel.fromMap).toList();
  }

  /* Lines of many sales in few queries (chunked to stay below SQLite's
  variable limit). Used by the sales list to avoid one query per row. */
  Future<List<SaleItemModel>> getItemsBySaleIds(
    List<int> saleIds, {
    Transaction? txn,
  }) async {
    if (saleIds.isEmpty) return [];
    final executor = txn ?? await _localDatabase.database;

    const chunkSize = 500;
    final result = <SaleItemModel>[];
    for (var start = 0; start < saleIds.length; start += chunkSize) {
      final end =
          (start + chunkSize < saleIds.length) ? start + chunkSize : saleIds.length;
      final chunk = saleIds.sublist(start, end);
      final placeholders = List.filled(chunk.length, '?').join(',');
      final rows = await executor.query(
        'sale_item',
        where: 'sale_id IN ($placeholders)',
        whereArgs: chunk,
        orderBy: 'sale_id ASC, id_sale_item ASC',
      );
      result.addAll(rows.map(SaleItemModel.fromMap));
    }
    return result;
  }

  /* Sales of each catalog item between [startDate] and [endDate], grouped by
  item, from the immutable snapshots. Only COMPLETED, non-deleted sales of the
  store count, the same criteria as the dashboard revenue.

  Line cost = (quantity_milli * unit_cost_cents + 500) / 1000 (integer
  division), the same rounding as QuantityUtils.lineSubtotalCents.

  The name/type/unit columns are "bare" columns next to MAX(id_sale_item):
  SQLite then takes them from the row holding that maximum, i.e. the most
  recent snapshot of the item. */
  Future<List<ItemMarginRow>> getMarginByItem({
    required int businessUnitId,
    required DateTime startDate,
    required DateTime endDate,
    Transaction? txn,
  }) async {
    final executor = txn ?? await _localDatabase.database;
    final rows = await executor.rawQuery(
      '''
      SELECT si.catalog_item_id AS catalog_item_id,
             si.item_name_snapshot AS item_name,
             si.item_type_snapshot AS item_type,
             si.unit_snapshot AS unit,
             MAX(si.id_sale_item) AS last_line_id,
             SUM(si.quantity_milli) AS quantity_milli,
             SUM(si.subtotal_cents) AS revenue_cents,
             SUM((si.quantity_milli * si.unit_cost_cents + 500) / 1000)
                 AS cost_cents,
             SUM(CASE WHEN si.item_type_snapshot = 'PRODUCT'
                       AND si.unit_cost_cents = 0 THEN 1 ELSE 0 END)
                 AS missing_cost_lines
      FROM sale_item si
      JOIN sale s ON s.id_sale = si.sale_id
      WHERE s.business_unit_id = ?
        AND si.catalog_item_id IS NOT NULL
        AND s.deleted = 0
        AND s.sale_status = 'COMPLETED'
        AND s.sale_date >= ?
        AND s.sale_date <= ?
      GROUP BY si.catalog_item_id
      ''',
      [
        businessUnitId,
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
    );
    return rows.map(ItemMarginRow.fromMap).toList();
  }

    /* Custom lines (no catalog item) of COMPLETED, non-deleted sales of the
  store in the period: how many and how much they sold. Same sale criteria as
  getMarginByItem. */
  Future<CustomSalesSummary> getCustomSalesSummary({
    required int businessUnitId,
    required DateTime startDate,
    required DateTime endDate,
    Transaction? txn,
  }) async {
    final executor = txn ?? await _localDatabase.database;
    final rows = await executor.rawQuery(
      '''
      SELECT COUNT(*) AS line_count,
             COALESCE(SUM(si.subtotal_cents), 0) AS revenue_cents
      FROM sale_item si
      JOIN sale s ON s.id_sale = si.sale_id
      WHERE s.business_unit_id = ?
        AND si.catalog_item_id IS NULL
        AND s.deleted = 0
        AND s.sale_status = 'COMPLETED'
        AND s.sale_date >= ?
        AND s.sale_date <= ?
      ''',
      [
        businessUnitId,
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
    );
    final row = rows.first;
    return CustomSalesSummary(
      lineCount: (row['line_count'] as num).toInt(),
      revenueCents: (row['revenue_cents'] as num).toInt(),
    );
  }
}

