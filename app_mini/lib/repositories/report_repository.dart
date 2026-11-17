import '../core/quantity_utils.dart';
import '../daos/sale_item_dao.dart';
import '../daos/stock_movement_dao.dart';
import '../models/report_models.dart';
import '../models/sale_model.dart';

/* Read-only reports. Everything here is informative: none of it feeds the
financial statement, whose balance stays cash-based (sales - expenses).
Margin (price - cost) and the value of losses are never added to the balance:
the cost of goods is already counted once, as the purchase expense. */
class ReportRepository {
  ReportRepository(this._stockMovementDao, this._saleItemDao);

  final StockMovementDao _stockMovementDao;
  final SaleItemDao _saleItemDao;

  /* Stock value and the low-stock count from a single balance query.
  - Value: every product with balance > 0 (also inactive or deleted ones,
    since the stock is still physically there) at its reference cost.
  - Low stock: how many rows are at or below the fixed threshold, counted
    exactly like the "Low stock" filter of the Stock screen. */
  Future<StockReport> getStockReport({required int businessUnitId}) async {
    final balances = await _stockMovementDao.getBalances(
      businessUnitId: businessUnitId,
    );

    final valueRows = <StockValueRow>[];
    var totalValueCents = 0;
    for (final row in balances) {
      if (row.balanceMilli <= 0) continue;
      final value = QuantityUtils.lineSubtotalCents(
        row.balanceMilli,
        row.item.costPriceCents,
      );
      totalValueCents += value;
      valueRows.add(StockValueRow(row: row, valueCents: value));
    }
    valueRows.sort((a, b) => b.valueCents.compareTo(a.valueCents));

    return StockReport(
      valueRows: valueRows,
      lowStockCount: balances.where((row) => row.isLow).length,
      totalValueCents: totalValueCents,
    );
  }

  /* Margin per catalog item over [period], from the sale line snapshots.
  Custom lines have no cost: they are summarized apart and never enter the
  margin totals. */
  Future<MarginReport> getMarginReport({
    required int businessUnitId,
    required DashboardPeriod period,
  }) async {
    final now = DateTime.now();
    final startDate = period.startDateFrom(now);

    final rows = await _saleItemDao.getMarginByItem(
      businessUnitId: businessUnitId,
      startDate: startDate,
      endDate: now,
    );
    rows.sort((a, b) => b.marginCents.compareTo(a.marginCents));

    final customSales = await _saleItemDao.getCustomSalesSummary(
      businessUnitId: businessUnitId,
      startDate: startDate,
      endDate: now,
    );

    var revenue = 0;
    var cost = 0;
    for (final row in rows) {
      revenue += row.revenueCents;
      cost += row.costCents;
    }

    return MarginReport(
      rows: rows,
      totalRevenueCents: revenue,
      totalCostCents: cost,
      customSales: customSales,
    );
  }

  /// Value of the losses (LOSS movements) over [period], at cost.
  Future<LossReport> getLossReport({
    required int businessUnitId,
    required DashboardPeriod period,
  }) async {
    final now = DateTime.now();
    final rows = await _stockMovementDao.getLossesByItem(
      businessUnitId: businessUnitId,
      startDate: period.startDateFrom(now),
      endDate: now,
    );
    return LossReport(rows: rows);
  }
}