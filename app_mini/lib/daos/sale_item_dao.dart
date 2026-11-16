import 'package:sqflite/sqflite.dart';

import '../core/database/local_database.dart';
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
}