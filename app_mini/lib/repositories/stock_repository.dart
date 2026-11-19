import 'package:sqflite/sqflite.dart';

import '../core/database/local_database.dart';
import '../core/insufficient_stock_exception.dart';
import '../core/quantity_utils.dart';
import '../daos/catalog_item_dao.dart';
import '../daos/stock_movement_dao.dart';
import '../daos/supplier_dao.dart';
import '../models/catalog_item_model.dart';
import '../models/stock_movement_model.dart';
import 'expense_repository.dart';

/* Business logic for stock. The balance is never stored: it is the SUM of
the append-only stock_movement ledger. Movements are never edited or
deleted; mistakes are fixed with a counter-movement.

A PURCHASE creates its expense here (same transaction). The initial stock of
a new product is booked as an expense too, but that happens in
CatalogRepository.createItem, together with the product. Adjustments (exit,
loss) never create an expense.

Every write runs inside runInTransaction and reads the balance inside it. */
class StockRepository {
  StockRepository(
    this._database,
    this._stockMovementDao,
    this._catalogItemDao,
    this._supplierDao,
    this._expenseRepository,
  );

  final LocalDatabase _database;
  final StockMovementDao _stockMovementDao;
  final CatalogItemDao _catalogItemDao;
  final SupplierDao _supplierDao;
  final ExpenseRepository _expenseRepository;

  // reads

  Future<List<StockBalanceRow>> getBalances({
    required int businessUnitId,
    String? search,
    int? categoryId,
  }) {
    return _stockMovementDao.getBalances(
      businessUnitId: businessUnitId,
      search: search,
      categoryId: categoryId,
    );
  }

  /// Global history of the store (read-only), newest first, paged.
  Future<List<StockMovementRow>> getHistory({
    required int businessUnitId,
    int? catalogItemId,
    String? movementType,
    int limit = 100,
    int offset = 0,
  }) {
    return _stockMovementDao.getHistory(
      businessUnitId: businessUnitId,
      catalogItemId: catalogItemId,
      movementType: movementType,
      limit: limit,
      offset: offset,
    );
  }

  Future<int> getBalance(int catalogItemId) {
    return _stockMovementDao.getBalance(catalogItemId);
  }

  // writes

  /* Purchase: creates the expense, the movement and updates the item's
  reference cost, all or nothing. [expenseDescription] arrives already
  localized from the UI (it is stored in the language active at the time). */
  Future<StockMovementModel> registerPurchase({
    required int businessUnitId,
    required int catalogItemId,
    required int quantityMilli,
    required int unitCostCents,
    int? supplierId,
    required DateTime purchaseDate,
    required String expenseDescription,
    String? notes,
  }) {
    if (quantityMilli <= 0) {
      throw ArgumentError('Quantity must be greater than zero.');
    }
    if (unitCostCents <= 0) {
      throw ArgumentError('Unit cost must be greater than zero.');
    }
    // Quantity x unit cost, rounded to the cent.
    final totalCents =
        QuantityUtils.lineSubtotalCents(quantityMilli, unitCostCents);
    if (totalCents <= 0) {
      throw ArgumentError('Purchase total must be greater than zero.');
    }

    return _database.runInTransaction((txn) async {
      final item = await _loadProduct(txn, businessUnitId, catalogItemId);
      _requireReceivable(item);

      if (supplierId != null) {
        final supplier = await _supplierDao.getSupplierById(
          supplierId,
          txn: txn,
        );
        if (supplier == null ||
            supplier.deleted ||
            supplier.businessUnitId != businessUnitId) {
          throw StateError('Supplier not found in the active store.');
        }
      }

      final expense = await _expenseRepository.createExpense(
        businessUnitId: item.businessUnitId,
        supplierId: supplierId,
        description: expenseDescription,
        amountCents: totalCents,
        expenseDate: purchaseDate,
        txn: txn,
      );

      final movement = await _insert(
        txn,
        StockMovementModel(
          businessUnitId: item.businessUnitId,
          catalogItemId: catalogItemId,
          movementType: StockMovementModel.typePurchase,
          quantityMilli: quantityMilli,
          unitCostCents: unitCostCents,
          expenseId: expense.idExpense,
          notes: _cleanNotes(notes),
          createdAt: DateTime.now(),
        ),
      );

      await _catalogItemDao.updateCostPrice(
        catalogItemId,
        unitCostCents,
        txn: txn,
      );
      return movement;
    });
  }


  /* Manual correction. [quantity] is the positive magnitude; the sign comes
  from [movementType]. Outgoing types need a note and can never take the
  balance below zero (checked inside the transaction). No expense. */
  Future<StockMovementModel> registerAdjustment({
    required int businessUnitId,
    required int catalogItemId,
    required String movementType,
    required int quantityMilli,
    String? notes,
  }) {
    const allowed = {
      StockMovementModel.typeAdjustmentIn,
      StockMovementModel.typeAdjustmentOut,
      StockMovementModel.typeLoss,
    };
    if (!allowed.contains(movementType)) {
      throw ArgumentError('Invalid adjustment type: $movementType.');
    }
    if (quantityMilli <= 0) {
      throw ArgumentError('Quantity must be greater than zero.');
    }
    final isOutgoing = movementType != StockMovementModel.typeAdjustmentIn;
    final cleanNotes = _cleanNotes(notes);
    if (isOutgoing && cleanNotes == null) {
      throw ArgumentError('A note is required for outgoing adjustments.');
    }

    return _database.runInTransaction((txn) async {
      final item = await _loadProduct(txn, businessUnitId, catalogItemId);

      if (isOutgoing) {
        final balance = await _stockMovementDao.getBalance(
          catalogItemId,
          txn: txn,
        );
        if (quantityMilli > balance) {
          throw InsufficientStockException(
            itemName: item.name,
            balanceMilli: balance,
            requestedMilli: quantityMilli,
          );
        }
      }

      return _insert(
        txn,
        StockMovementModel(
          businessUnitId: item.businessUnitId,
          catalogItemId: catalogItemId,
          movementType: movementType,
          quantityMilli: isOutgoing ? -quantityMilli : quantityMilli,
          notes: cleanNotes,
          createdAt: DateTime.now(),
        ),
      );
    });
  }

  // helpers

  Future<CatalogItemModel> _loadProduct(
    Transaction txn,
    int businessUnitId,
    int catalogItemId,
  ) async {
    final item = await _catalogItemDao.getItemById(catalogItemId, txn: txn);
    if (item == null) {
      throw StateError('Catalog item not found.');
    }
    if (item.businessUnitId != businessUnitId) {
      throw StateError('Item does not belong to the active store.');
    }
    if (!item.isProduct) {
      throw StateError('Only products can have stock movements.');
    }
    return item;
  }

  /// Purchases only go to live (active, not deleted) products.
  void _requireReceivable(CatalogItemModel item) {
    if (item.deleted) {
      throw StateError('Cannot add stock to a deleted item.');
    }
    if (!item.active) {
      throw StateError('Cannot add stock to an inactive item.');
    }
  }
  
  Future<StockMovementModel> _insert(
    Transaction txn,
    StockMovementModel movement,
  ) async {
    final id = await _stockMovementDao.insertMovement(movement, txn: txn);
    return movement.copyWith(idStockMovement: id);
  }

  String? _cleanNotes(String? notes) {
    final trimmed = notes?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }
}