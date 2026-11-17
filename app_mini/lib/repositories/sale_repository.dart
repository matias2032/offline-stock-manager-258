import 'package:sqflite/sqflite.dart';

import '../core/database/local_database.dart';
import '../core/insufficient_stock_exception.dart';
import '../core/quantity_utils.dart';
import '../core/sale_description_utils.dart';
import '../daos/business_unit_dao.dart';
import '../daos/catalog_item_dao.dart';
import '../daos/sale_dao.dart';
import '../daos/sale_item_dao.dart';
import '../daos/stock_movement_dao.dart';
import '../models/catalog_item_model.dart';
import '../models/sale_item_model.dart';
import '../models/sale_model.dart';
import '../models/stock_movement_model.dart';
import '../models/daily_revenue_point.dart';

/* Business logic for the `sale` module: sale, sale_item, sale_installment and
sale_payment, plus the stock side effects of selling catalog items. This is
the only entry point the UI/providers should use — never the DAOs directly.

Stock rules (see createSaleWithItems / cancelSale):
 - stock goes down when the sale is created (there is no OPEN step);
 - selling above the balance of a tracked item is blocked;
 - cancelling a sale writes SALE_REVERSAL movements, once only. */
class SaleRepository {
  SaleRepository(
    this._database,
    this._saleDao,
    this._businessUnitDao,
    this._saleItemDao,
    this._catalogItemDao,
    this._stockMovementDao,
  );

  final LocalDatabase _database;
  final SaleDao _saleDao;
  final BusinessUnitDao _businessUnitDao;
  final SaleItemDao _saleItemDao;
  final CatalogItemDao _catalogItemDao;
  final StockMovementDao _stockMovementDao;

  // sale

  /* Free sale: manual description and total, no lines, no stock movement. */
  Future<SaleModel> createSale({
    required int businessUnitId,
    required String description,
    required int totalAmountCents,
    String saleType = 'NORMAL',
    int? customerId,
    String? walkInCustomerName,
    DateTime? creditDueDate,
    String? notes,

    /* Optional down payment for a CREDIT sale. If provided (> 0), it is registered as the sale's first payment/installment right away; if
    omitted, the whole total starts out as outstanding debt.*/

    int? initialPaymentCents,
    String initialPaymentMethod = 'CASH',
  }) async {
    final trimmedDescription = description.trim();
    _validateSaleInput(
      description: trimmedDescription,
      totalAmountCents: totalAmountCents,
      saleType: saleType,
      customerId: customerId,
      walkInCustomerName: walkInCustomerName,
      initialPaymentCents: initialPaymentCents,
    );

    return _database.runInTransaction((txn) {
      return _insertSaleInTxn(
        txn,
        businessUnitId: businessUnitId,
        description: trimmedDescription,
        totalAmountCents: totalAmountCents,
        saleType: saleType,
        customerId: customerId,
        walkInCustomerName: walkInCustomerName,
        creditDueDate: creditDueDate,
        notes: notes,
        initialPaymentCents: initialPaymentCents,
        initialPaymentMethod: initialPaymentMethod,
      );
    });
  }

  /* Sale made of lines. Everything happens in one transaction: sale, lines
  (snapshot) and stock movements, all or nothing.

  - The total is the sum of the line subtotals, computed here; the UI never
    sends one.
  - A line is a catalog line (product or service) or a custom line (free
    name + price, no stock). Catalog lines of the same item AND the same
    requested price are merged; custom lines are never merged.
  - Every catalog line is validated against the DB: item exists, same store,
    not deleted, active, quantity > 0.
  - Every product has stock: the balance is checked BEFORE writing anything,
    aggregated per product (two lines of the same product at different
    prices count together). Not enough stock throws
    InsufficientStockException.
  - The description is generated from the names only ("Cable, Delivery"),
    and is what shows in lists and statements. */
  Future<SaleModel> createSaleWithItems({
    required int businessUnitId,
    required List<SaleLineInput> lines,
    String saleType = 'NORMAL',
    int? customerId,
    String? walkInCustomerName,
    DateTime? creditDueDate,
    String? notes,
    int? initialPaymentCents,
    String initialPaymentMethod = 'CASH',
  }) async {
    if (lines.isEmpty) {
      throw ArgumentError('A sale with items needs at least one line.');
    }
    final merged = _mergeLines(lines);

    return _database.runInTransaction((txn) async {
      final prepared = <_PreparedLine>[];
      for (final line in merged) {
        prepared.add(
          line.isCustom
              ? _prepareCustomLine(line)
              : await _prepareCatalogLine(txn, businessUnitId, line),
        );
      }

      await _assertEnoughStock(txn, prepared);

      final totalCents =
          prepared.fold<int>(0, (sum, line) => sum + line.subtotalCents);
      final description =
          SaleDescriptionUtils.fromNames(prepared.map((l) => l.name));

      _validateSaleInput(
        description: description,
        totalAmountCents: totalCents,
        saleType: saleType,
        customerId: customerId,
        walkInCustomerName: walkInCustomerName,
        initialPaymentCents: initialPaymentCents,
      );

      final sale = await _insertSaleInTxn(
        txn,
        businessUnitId: businessUnitId,
        description: description,
        totalAmountCents: totalCents,
        saleType: saleType,
        customerId: customerId,
        walkInCustomerName: walkInCustomerName,
        creditDueDate: creditDueDate,
        notes: notes,
        initialPaymentCents: initialPaymentCents,
        initialPaymentMethod: initialPaymentMethod,
      );

      for (final line in prepared) {
        final item = line.item;

        await _saleItemDao.insertItem(
          SaleItemModel(
            saleId: sale.idSale!,
            catalogItemId: item?.idCatalogItem,
            itemNameSnapshot: line.name,
            itemTypeSnapshot: line.itemType,
            unitSnapshot: line.unit,
            quantityMilli: line.quantityMilli,
            unitPriceCents: line.unitPriceCents,
            unitCostCents: line.unitCostCents,
            subtotalCents: line.subtotalCents,
            createdAt: DateTime.now(),
          ),
          txn: txn,
        );

        // Only products move stock; services and custom lines never do.
        if (item != null && item.isProduct) {
          await _stockMovementDao.insertMovement(
            StockMovementModel(
              businessUnitId: businessUnitId,
              catalogItemId: item.idCatalogItem!,
              movementType: StockMovementModel.typeSale,
              quantityMilli: -line.quantityMilli,
              unitCostCents: line.unitCostCents,
              saleId: sale.idSale,
              createdAt: DateTime.now(),
            ),
            txn: txn,
          );
        }
      }

      return sale;
    });
  }

  /// Custom line: name + price typed by the seller. No item, no stock, no cost.
  _PreparedLine _prepareCustomLine(SaleLineInput line) {
    final name = _cleanOrNull(line.customName);
    if (name == null) {
      throw ArgumentError('Custom line name cannot be empty.');
    }
    final unitPrice = line.unitPriceCents;
    if (unitPrice == null || unitPrice <= 0) {
      throw ArgumentError('Unit price must be greater than zero.');
    }
    final subtotal =
        QuantityUtils.lineSubtotalCents(line.quantityMilli, unitPrice);
    if (subtotal <= 0) {
      throw ArgumentError('Line total must be greater than zero.');
    }

    return _PreparedLine(
      name: name,
      itemType: SaleItemModel.typeCustom,
      unit: 'UN',
      quantityMilli: line.quantityMilli,
      unitPriceCents: unitPrice,
      unitCostCents: 0,
      subtotalCents: subtotal,
    );
  }

  /// Catalog line: validated against the DB, snapshotting name/unit/cost.
  Future<_PreparedLine> _prepareCatalogLine(
    Transaction txn,
    int businessUnitId,
    SaleLineInput line,
  ) async {
    final item = await _catalogItemDao.getItemById(
      line.catalogItemId!,
      txn: txn,
    );
    if (item == null) {
      throw StateError('Catalog item not found.');
    }
    if (item.businessUnitId != businessUnitId) {
      throw StateError('Item does not belong to the active store.');
    }
    if (item.deleted) {
      throw StateError('"${item.name}" was deleted and cannot be sold.');
    }
    if (!item.active) {
      throw StateError('"${item.name}" is inactive and cannot be sold.');
    }

    final unitPrice = line.unitPriceCents ?? item.salePriceCents;
    if (unitPrice <= 0) {
      throw ArgumentError('Unit price must be greater than zero.');
    }
    final subtotal =
        QuantityUtils.lineSubtotalCents(line.quantityMilli, unitPrice);
    if (subtotal <= 0) {
      throw ArgumentError('Line total must be greater than zero.');
    }

    return _PreparedLine(
      item: item,
      name: item.name,
      itemType: item.itemType,
      unit: item.unit,
      quantityMilli: line.quantityMilli,
      unitPriceCents: unitPrice,
      // Snapshot of the single product cost; services carry none.
      unitCostCents: item.isProduct ? item.costPriceCents : 0,
      subtotalCents: subtotal,
    );
  }

  /* Total requested per product vs. its balance, read inside the
  transaction. Runs before anything is written. */
  Future<void> _assertEnoughStock(
    Transaction txn,
    List<_PreparedLine> lines,
  ) async {
    final requested = <int, int>{};
    final names = <int, String>{};
    for (final line in lines) {
      final item = line.item;
      if (item == null || !item.isProduct) continue;
      final id = item.idCatalogItem!;
      requested[id] = (requested[id] ?? 0) + line.quantityMilli;
      names[id] = item.name;
    }

    for (final entry in requested.entries) {
      final balance = await _stockMovementDao.getBalance(entry.key, txn: txn);
      if (entry.value > balance) {
        throw InsufficientStockException(
          itemName: names[entry.key]!,
          balanceMilli: balance,
          requestedMilli: entry.value,
        );
      }
    }
  }

  /* Cancels a sale: sets sale_status to CANCELLED, auto-cancels its unpaid installments and gives back the stock it consumed.
  Existing sale_payment rows are left untouched — they remain as payment history. This does NOT touch the `deleted`column;
  that flag is reserved for a possible future "remove from records" action distinct from cancellation.*/
  Future<SaleModel> cancelSale({
    required int saleId,
    required String cancellationReason,
  }) async {
    final trimmedReason = cancellationReason.trim();
    if (trimmedReason.isEmpty) {
      throw ArgumentError('Cancellation reason cannot be empty.');
    }

    return _database.runInTransaction((txn) async {
      final sale = await _saleDao.getSaleById(saleId, txn: txn);
      if (sale == null) {
        throw StateError('Sale not found.');
      }
      if (sale.saleStatus == 'CANCELLED') {
        throw StateError('Sale is already cancelled.');
      }

      await _saleDao.cancelUnpaidInstallments(saleId, txn: txn);
      await _reverseSaleStock(txn, sale);

      final updatedSale = sale.copyWith(
        saleStatus: 'CANCELLED',
        cancellationReason: trimmedReason,
      );
      await _saleDao.updateSale(updatedSale, txn: txn);
      return updatedSale;
    });
  }

  /* Registers a payment against a CREDIT sale. This is what the credit sale detail screen calls every time the customer pays something —
  each call is itself the "automatic installment generation": it creates one new, already-PAID sale_installment row representing
  this exact tranche, in the order payments are received.*/
  Future<SaleModel> registerPayment({
    required int saleId,
    required int paidAmountCents,
    String paymentMethod = 'CASH',
    String? notes,
  }) async {
    if (paidAmountCents <= 0) {
      throw ArgumentError('Payment amount must be greater than zero.');
    }

    return _database.runInTransaction((txn) async {
      final sale = await _saleDao.getSaleById(saleId, txn: txn);
      if (sale == null) {
        throw StateError('Sale not found.');
      }
      if (!sale.isCredit) {
        throw StateError('Only CREDIT sales accept payments.');
      }
      if (sale.saleStatus == 'CANCELLED') {
        throw StateError('Cannot register a payment on a cancelled sale.');
      }

      return _applyPayment(
        txn: txn,
        sale: sale,
        paidAmountCents: paidAmountCents,
        paymentMethod: paymentMethod,
        notes: notes,
      );
    });
  }

  /* Shared by createSale (initial payment) and registerPayment (every later payment). Must always run inside the caller's transaction, so a
  failure never leaves paid_amount_cents out of sync with the sum of sale_payment rows.*/
  Future<SaleModel> _applyPayment({
    required Transaction txn,
    required SaleModel sale,
    required int paidAmountCents,
    required String paymentMethod,
    String? notes,
  }) async {
    final due = sale.totalAmountCents - sale.paidAmountCents;
    if (paidAmountCents > due) {
      throw ArgumentError(
        'Payment exceeds the total amount still owed on this sale.',
      );
    }

    final nextInstallmentNumber = await _saleDao
            .countInstallmentsBySale(sale.idSale!, txn: txn) +
        1;

    final installmentId = await _saleDao.insertInstallment(
      SaleInstallmentModel(
        saleId: sale.idSale!,
        installmentNumber: nextInstallmentNumber,
        installmentAmountCents: paidAmountCents,
        paidAmountCents: paidAmountCents,
        dueDate: DateTime.now(),
        paidAt: DateTime.now(),
        installmentStatus: 'PAID',
      ),
      txn: txn,
    );

    final reference = await _generatePaymentReference(txn);
    await _saleDao.insertPayment(
      SalePaymentModel(
        reference: reference,
        saleId: sale.idSale!,
        installmentId: installmentId,
        paidAmountCents: paidAmountCents,
        paymentMethod: paymentMethod,
        paidAt: DateTime.now(),
        notes: notes,
      ),
      txn: txn,
    );

    final newPaidAmount = sale.paidAmountCents + paidAmountCents;
    final isFullyPaid = newPaidAmount >= sale.totalAmountCents;
    final paymentStatus = newPaidAmount <= 0
        ? 'PENDING'
        : (isFullyPaid ? 'PAID' : 'PARTIAL');

    final updatedSale = sale.copyWith(
      paidAmountCents: newPaidAmount,
      paymentStatus: paymentStatus,
      saleStatus: isFullyPaid ? 'COMPLETED' : sale.saleStatus,
      completedAt: isFullyPaid ? DateTime.now() : sale.completedAt,
    );
    await _saleDao.updateSale(updatedSale, txn: txn);
    return updatedSale;
  }

  Future<SaleModel?> getSaleById(int idSale) {
    return _saleDao.getSaleById(idSale);
  }

  Future<List<SaleModel>> getAllSales({
    required int businessUnitId,
    int? customerId,
    String? saleType,
    String? saleStatus,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return _saleDao.getAllSales(
      businessUnitId: businessUnitId,
      customerId: customerId,
      saleType: saleType,
      saleStatus: saleStatus,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Backs the main sales list screen: NORMAL sales always, CREDIT sales only once finalized (COMPLETED/CANCELLED).
  Future<List<SaleModel>> getSalesForSalesList({
    required int businessUnitId,
    int? customerId,
    String? saleType,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return _saleDao.getSalesForSalesList(
      businessUnitId: businessUnitId,
      customerId: customerId,
      saleType: saleType,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Backs the credit sales list screen: only active (unpaid) credit sales.
  Future<List<SaleModel>> getOutstandingCreditSales({
    required int businessUnitId,
    int? customerId,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return _saleDao.getOutstandingCreditSales(
      businessUnitId: businessUnitId,
      customerId: customerId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<List<SaleInstallmentModel>> getInstallmentsBySale(int saleId) {
    return _saleDao.getInstallmentsBySale(saleId);
  }

  Future<List<SalePaymentModel>> getPaymentsBySale(int saleId) {
    return _saleDao.getPaymentsBySale(saleId);
  }

  // ---------------------------------------------------------------------
  // sale lines and sellable items
  // ---------------------------------------------------------------------

  Future<List<SaleItemModel>> getSaleItems(int saleId) {
    return _saleItemDao.getItemsBySale(saleId);
  }

  /// Lines of several sales grouped by sale id (sales without lines are absent).
  Future<Map<int, List<SaleItemModel>>> getItemsForSales(
    List<int> saleIds,
  ) async {
    final items = await _saleItemDao.getItemsBySaleIds(saleIds);
    final grouped = <int, List<SaleItemModel>>{};
    for (final item in items) {
      grouped.putIfAbsent(item.saleId, () => []).add(item);
    }
    return grouped;
  }

  /* Active catalog items of the store for the item picker. Tracked products
  carry their current balance. Two queries in total, whatever the size. */
  Future<List<SellableItem>> getSellableItems({
    required int businessUnitId,
    String? search,
  }) async {
    final items = await _catalogItemDao.getAllItems(
      businessUnitId: businessUnitId,
      search: search,
      onlyActive: true,
    );
    final balances = await _stockMovementDao.getBalances(
      businessUnitId: businessUnitId,
    );
    final balanceById = {
      for (final row in balances) row.item.idCatalogItem!: row.balanceMilli,
    };

    return items.map((item) {
      return SellableItem(
        item: item,
        balanceMilli:
            item.isProduct ? (balanceById[item.idCatalogItem!] ?? 0) : null,
      );
    }).toList();
  }

  // ---------------------------------------------------------------------
  // badge stats
  // ---------------------------------------------------------------------

  /// Number of credit sales still not finalized — backs the sidebar badge.
  Future<int> countOutstandingCreditSales({required int businessUnitId}) {
    return _saleDao.countOutstandingCreditSales(businessUnitId: businessUnitId);
  }


  /* Aggregate dashboard stats for one store, over period. Backs the individual dashboard. businessUnitId is strict scope — callers use
  this for a single store; the Super Dashboard iterates this per business_unit instead of calling it once with a null id, since it
  stays consistent with FinancialStatementRepository.generateStatement's own pattern.*/
  Future<DashboardStats> getDashboardStats({
    required int businessUnitId,
    required DashboardPeriod period,
  }) async {
    final now = DateTime.now();
    final startDate = period.startDateFrom(now);

    final finalizedSalesCount = await _saleDao.countFinalizedSales(
      businessUnitId: businessUnitId,
      startDate: startDate,
      endDate: now,
    );
    final totalRevenueCents = await _saleDao.sumFinalizedSalesCents(
      businessUnitId: businessUnitId,
      startDate: startDate,
      endDate: now,
    );
    final settledCreditSalesCount = await _saleDao.countFinalizedSales(
      businessUnitId: businessUnitId,
      saleType: 'CREDIT',
      startDate: startDate,
      endDate: now,
    );
    final settledCreditRevenueCents = await _saleDao.sumFinalizedSalesCents(
      businessUnitId: businessUnitId,
      saleType: 'CREDIT',
      startDate: startDate,
      endDate: now,
    );

    return DashboardStats(
      businessUnitId: businessUnitId,
      period: period,
      startDate: startDate,
      endDate: now,
      finalizedSalesCount: finalizedSalesCount,
      totalRevenueCents: totalRevenueCents,
      settledCreditSalesCount: settledCreditSalesCount,
      settledCreditRevenueCents: settledCreditRevenueCents,
    );
  }

  /* Consolidated dashboard stats across every business unit (the "Super Dashboard"). Loops every business_unit — same pattern
  FinancialStatementRepository.generateStatement uses for businessUnitId == null — and sums each store's DashboardStats fields,
  keeping a per-store breakdown for the UI.*/
  Future<ConsolidatedDashboardStats> getConsolidatedDashboardStats({
    required DashboardPeriod period,
  }) async {
    final now = DateTime.now();
    final startDate = period.startDateFrom(now);

    final units = await _businessUnitDao.findAll();

    var finalizedSalesCount = 0;
    var totalRevenueCents = 0;
    var settledCreditSalesCount = 0;
    var settledCreditRevenueCents = 0;
    final perStore = <DashboardStoreBreakdown>[];

    for (final unit in units) {
      final unitId = unit.idBusinessUnit!;

      final unitSalesCount = await _saleDao.countFinalizedSales(
        businessUnitId: unitId,
        startDate: startDate,
        endDate: now,
      );
      final unitRevenueCents = await _saleDao.sumFinalizedSalesCents(
        businessUnitId: unitId,
        startDate: startDate,
        endDate: now,
      );
      final unitCreditCount = await _saleDao.countFinalizedSales(
        businessUnitId: unitId,
        saleType: 'CREDIT',
        startDate: startDate,
        endDate: now,
      );
      final unitCreditRevenueCents = await _saleDao.sumFinalizedSalesCents(
        businessUnitId: unitId,
        saleType: 'CREDIT',
        startDate: startDate,
        endDate: now,
      );

      finalizedSalesCount += unitSalesCount;
      totalRevenueCents += unitRevenueCents;
      settledCreditSalesCount += unitCreditCount;
      settledCreditRevenueCents += unitCreditRevenueCents;

      perStore.add(DashboardStoreBreakdown(
        businessUnitId: unitId,
        businessUnitName: unit.name,
        finalizedSalesCount: unitSalesCount,
        totalRevenueCents: unitRevenueCents,
      ));
    }

    perStore.sort((a, b) => b.totalRevenueCents.compareTo(a.totalRevenueCents));

    return ConsolidatedDashboardStats(
      period: period,
      startDate: startDate,
      endDate: now,
      finalizedSalesCount: finalizedSalesCount,
      totalRevenueCents: totalRevenueCents,
      settledCreditSalesCount: settledCreditSalesCount,
      settledCreditRevenueCents: settledCreditRevenueCents,
      perStore: perStore,
    );
  }

  /* Revenue grouped by day for the period. A null businessUnitId sums every
     store (consolidated view), following the same per-unit loop used by
     getConsolidatedDashboardStats. */
  Future<List<DailyRevenuePoint>> getDailyRevenue({
    int? businessUnitId,
    required DashboardPeriod period,
  }) async {
    final now = DateTime.now();
    final startDate = period.startDateFrom(now);

    final unitIds = businessUnitId != null
        ? [businessUnitId]
        : (await _businessUnitDao.findAll())
            .map((unit) => unit.idBusinessUnit!)
            .toList();

    final byDay = <String, int>{};
    for (final unitId in unitIds) {
      final unitDays = await _saleDao.sumFinalizedSalesCentsByDay(
        businessUnitId: unitId,
        startDate: startDate,
        endDate: now,
      );
      unitDays.forEach((day, cents) {
        byDay[day] = (byDay[day] ?? 0) + cents;
      });
    }

    // Fill days without sales with 0 so the line is continuous.
    final points = <DailyRevenuePoint>[];
    var cursor = DateTime(startDate.year, startDate.month, startDate.day);
    final last = DateTime(now.year, now.month, now.day);
    while (!cursor.isAfter(last)) {
      points.add(DailyRevenuePoint(
        day: cursor,
        revenueCents: byDay[_dayKey(cursor)] ?? 0,
      ));
      cursor = DateTime(cursor.year, cursor.month, cursor.day + 1);
    }
    return points;
  }


  // ---------------------------------------------------------------------
  // helpers
  // ---------------------------------------------------------------------

  /* Input rules shared by createSale and createSaleWithItems. [description]
  must already be trimmed. */
  void _validateSaleInput({
    required String description,
    required int totalAmountCents,
    required String saleType,
    required int? customerId,
    required String? walkInCustomerName,
    required int? initialPaymentCents,
  }) {
    if (description.isEmpty) {
      throw ArgumentError('Sale description cannot be empty.');
    }
    if (totalAmountCents <= 0) {
      throw ArgumentError('Sale total must be greater than zero.');
    }

    final isCredit = saleType == 'CREDIT';

    if (isCredit) {
      final hasCustomer = customerId != null;
      final hasWalkIn =
          walkInCustomerName != null && walkInCustomerName.trim().isNotEmpty;
      if (!hasCustomer && !hasWalkIn) {
        throw ArgumentError(
          'A CREDIT sale needs either a customer or a walk-in customer name.',
        );
      }
    }

    if (initialPaymentCents != null) {
      if (!isCredit) {
        throw ArgumentError('Only CREDIT sales accept an initial payment.');
      }
      if (initialPaymentCents <= 0) {
        throw ArgumentError('Initial payment must be greater than zero.');
      }
      if (initialPaymentCents > totalAmountCents) {
        throw ArgumentError('Initial payment cannot exceed the sale total.');
      }
    }
  }

  /* Inserts the sale row (reference, statuses) and the optional initial
  payment, inside the caller's transaction. Inputs are already validated. */
  Future<SaleModel> _insertSaleInTxn(
    Transaction txn, {
    required int businessUnitId,
    required String description,
    required int totalAmountCents,
    required String saleType,
    required int? customerId,
    required String? walkInCustomerName,
    required DateTime? creditDueDate,
    required String? notes,
    required int? initialPaymentCents,
    required String initialPaymentMethod,
  }) async {
    final isCredit = saleType == 'CREDIT';
    final reference = await _generateSaleReference(txn);

    final sale = SaleModel(
      reference: reference,
      description: description,
      totalAmountCents: totalAmountCents,
      saleType: saleType,
      // Installments are no longer predefined by modality — they're generated one at a time as payments come in (see _applyPayment).
      creditModality: null,
      saleStatus: isCredit ? 'OUTSTANDING' : 'COMPLETED',
      paymentStatus: isCredit ? 'PENDING' : 'PAID',
      paidAmountCents: isCredit ? 0 : totalAmountCents,
      customerId: customerId,
      walkInCustomerName: _cleanOrNull(walkInCustomerName),
      saleDate: DateTime.now(),
      creditDueDate: isCredit ? creditDueDate : null,
      completedAt: isCredit ? null : DateTime.now(),
      notes: _cleanOrNull(notes),
      createdAt: DateTime.now(),
      businessUnitId: businessUnitId,
    );

    final insertedId = await _saleDao.insertSale(sale, txn: txn);
    var savedSale = sale.copyWith(idSale: insertedId);

    if (isCredit && initialPaymentCents != null) {
      savedSale = await _applyPayment(
        txn: txn,
        sale: savedSale,
        paidAmountCents: initialPaymentCents,
        paymentMethod: initialPaymentMethod,
        notes: null,
      );
    }

    return savedSale;
  }

  /* Merges lines of the same item with the same requested price (null =
  catalog price). Different prices of the same item stay separate. */
  List<SaleLineInput> _mergeLines(List<SaleLineInput> lines) {
    final merged = <String, SaleLineInput>{};
    var customIndex = 0;
    for (final line in lines) {
      if (line.quantityMilli <= 0) {
        throw ArgumentError('Quantity must be greater than zero.');
      }
      if (line.isCustom) {
        merged['custom|${customIndex++}'] = line;
        continue;
      }
      final key = '${line.catalogItemId}|${line.unitPriceCents}';
      final existing = merged[key];
      merged[key] = existing == null
          ? line
          : SaleLineInput(
              catalogItemId: line.catalogItemId,
              quantityMilli: existing.quantityMilli + line.quantityMilli,
              unitPriceCents: line.unitPriceCents,
            );
    }
    return merged.values.toList();
  }

  /* Gives back the stock of a cancelled sale. Per item: sold (SALE) minus
  already reversed (SALE_REVERSAL); only a positive remainder is reversed, so
  running this twice never duplicates a reversal. Free sales have no
  movements and nothing happens. */
  Future<void> _reverseSaleStock(Transaction txn, SaleModel sale) async {
    final movements = await _stockMovementDao.getMovementsBySale(
      sale.idSale!,
      txn: txn,
    );
    if (movements.isEmpty) return;

    final sold = <int, int>{};
    final reversed = <int, int>{};
    final unitCost = <int, int?>{};

    for (final m in movements) {
      if (m.movementType == StockMovementModel.typeSale) {
        sold[m.catalogItemId] = (sold[m.catalogItemId] ?? 0) - m.quantityMilli;
        unitCost[m.catalogItemId] = m.unitCostCents;
      } else if (m.movementType == StockMovementModel.typeSaleReversal) {
        reversed[m.catalogItemId] =
            (reversed[m.catalogItemId] ?? 0) + m.quantityMilli;
      }
    }

    for (final entry in sold.entries) {
      final remaining = entry.value - (reversed[entry.key] ?? 0);
      if (remaining <= 0) continue;

      await _stockMovementDao.insertMovement(
        StockMovementModel(
          businessUnitId: sale.businessUnitId,
          catalogItemId: entry.key,
          movementType: StockMovementModel.typeSaleReversal,
          quantityMilli: remaining,
          unitCostCents: unitCost[entry.key],
          saleId: sale.idSale,
          createdAt: DateTime.now(),
        ),
        txn: txn,
      );
    }
  }

    String _dayKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  Future<String> _generateSaleReference(Transaction txn) async {
    final count = await _saleDao.countAll(txn: txn);
    return 'V-${(count + 1).toString().padLeft(5, '0')}';
  }

  Future<String> _generatePaymentReference(Transaction txn) async {
    final count = await _saleDao.countAllPayments(txn: txn);
    return 'V-${(count + 1).toString().padLeft(5, '0')}';
  }

  String? _cleanOrNull(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

/* A validated line, ready to be written. [item] is null for custom lines. */
class _PreparedLine {
  const _PreparedLine({
    this.item,
    required this.name,
    required this.itemType,
    required this.unit,
    required this.quantityMilli,
    required this.unitPriceCents,
    required this.unitCostCents,
    required this.subtotalCents,
  });

  final CatalogItemModel? item;
  final String name;
  final String itemType; // 'PRODUCT' | 'SERVICE' | 'CUSTOM'
  final String unit;
  final int quantityMilli;
  final int unitPriceCents;
  final int unitCostCents;
  final int subtotalCents;
}