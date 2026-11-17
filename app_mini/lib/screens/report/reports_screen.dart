import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:mini/l10n/app_localizations.dart';

import '../../core/money_utils.dart';
import '../../core/quantity_utils.dart';
import '../../models/report_models.dart';
import '../../models/sale_model.dart';
import '../../providers/report_provider.dart';
import '../../providers/sale_provider.dart';
import '../../providers/user_provider.dart';
import '/widgets/app_sidebar.dart';

/* Informative reports of the active store: stock value, margin per item and
losses. None of this enters the statement balance. Low-stock alerts live in
the Stock screen. */
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final reports = context.read<ReportProvider>();
      reports.loadStock();
      reports.loadMargin();
      reports.loadLosses();
      context.read<SaleProvider>().loadOutstandingCreditCount();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.reportsTitle),
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: l10n.stockValueLabel),
              Tab(text: l10n.marginTabLabel),
              Tab(text: l10n.lossesTabLabel),
            ],
          ),
        ),
        drawer: AppSidebar(
          currentRoute: '/reports',
          creditSalesBadgeCount:
              context.watch<SaleProvider>().outstandingCreditCount,
        ),
        body: const TabBarView(
          children: [
            _StockValueTab(),
            _MarginTab(),
            _LossesTab(),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Stock value
// ---------------------------------------------------------------------

class _StockValueTab extends StatelessWidget {
  const _StockValueTab();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<ReportProvider>();
    final currency = context.watch<UserProvider>().user?.currency ?? 'MZN';
    final colorScheme = Theme.of(context).colorScheme;
    final report = provider.stockReport;

    return RefreshIndicator(
      onRefresh: () => context.read<ReportProvider>().loadStock(),
      child: provider.isLoadingStock && report == null
          ? const Center(child: CircularProgressIndicator())
          : report == null || report.valueRows.isEmpty
              ? ListView(
                  children: [
                    const SizedBox(height: 120),
                    Center(child: Text(l10n.noStockValueYet)),
                  ],
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.stockValueLabel,
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${MoneyUtils.format(report.totalValueCents)} $currency',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            if (report.itemsWithoutCost > 0) ...[
                              const SizedBox(height: 8),
                              Text(
                                l10n.itemsWithoutCostNote(
                                  report.itemsWithoutCost,
                                ),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.error,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          for (final entry in report.valueRows)
                            _StockValueTile(entry: entry, currency: currency),
                        ],
                      ),
                    ),
                    _InfoNote(text: l10n.reportsInfoNote),
                  ],
                ),
    );
  }
}

class _StockValueTile extends StatelessWidget {
  const _StockValueTile({required this.entry, required this.currency});

  final StockValueRow entry;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final item = entry.row.item;

    final parts = <String>[
      '${QuantityUtils.format(entry.row.balanceMilli)} ${item.unit} × '
          '${MoneyUtils.format(item.costPriceCents)} $currency',
      if (!entry.hasCost) l10n.noCostLabel,
      if (item.deleted) l10n.deletedLabel,
      if (!item.active && !item.deleted) l10n.inactiveLabel,
    ];

    return ListTile(
      dense: true,
      title: Text(item.name),
      subtitle: Text(
        parts.join(' • '),
        style: TextStyle(color: entry.hasCost ? null : colorScheme.error),
      ),
      trailing: Text(
        '${MoneyUtils.format(entry.valueCents)} $currency',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Period selector (shared by Margin and Losses)
// ---------------------------------------------------------------------

class _PeriodChips extends StatelessWidget {
  const _PeriodChips();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReportProvider>();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SizedBox(
        height: 40,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: DashboardPeriod.values.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final period = DashboardPeriod.values[index];
            return ChoiceChip(
              label: Text(period.label),
              selected: provider.period == period,
              onSelected: (_) =>
                  context.read<ReportProvider>().setPeriod(period),
            );
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Margin per item
// ---------------------------------------------------------------------

class _MarginTab extends StatelessWidget {
  const _MarginTab();

  String _percent(double? value) =>
      value == null ? '' : '${NumberFormat('#,##0.0').format(value)}%';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<ReportProvider>();
    final currency = context.watch<UserProvider>().user?.currency ?? 'MZN';
    final colorScheme = Theme.of(context).colorScheme;
    final report = provider.marginReport;

    return Column(
      children: [
        const _PeriodChips(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => context.read<ReportProvider>().loadMargin(),
            child: provider.isLoadingMargin && report == null
                ? const Center(child: CircularProgressIndicator())
                : report == null ||
                        (report.rows.isEmpty && report.customSales.isEmpty)
                    ? ListView(
                        children: [
                          const SizedBox(height: 100),
                          Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 32),
                              child: Text(
                                l10n.marginNoSalesYet,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      )
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        children: [
                          if (report.rows.isNotEmpty) ...[
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    _SummaryRow(
                                      label: l10n.totalRevenue,
                                      value:
                                          '${MoneyUtils.format(report.totalRevenueCents)} $currency',
                                    ),
                                    _SummaryRow(
                                      label: l10n.costOfGoodsLabel,
                                      value:
                                          '${MoneyUtils.format(report.totalCostCents)} $currency',
                                    ),
                                    const Divider(height: 20),
                                    _SummaryRow(
                                      label: l10n.marginLabel,
                                      value:
                                          '${MoneyUtils.format(report.totalMarginCents)} $currency'
                                          '${report.marginPercent != null ? ' • ${_percent(report.marginPercent)}' : ''}',
                                      bold: true,
                                      color: report.totalMarginCents >= 0
                                          ? Colors.green
                                          : colorScheme.error,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Card(
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                children: [
                                  for (final row in report.rows)
                                    _MarginTile(
                                      row: row,
                                      currency: currency,
                                      percent: _percent(row.marginPercent),
                                    ),
                                ],
                              ),
                            ),
                          ],
                          // Custom lines: no cost, so shown apart from the margin.
                          if (!report.customSales.isEmpty) ...[
                            const SizedBox(height: 8),
                            Card(
                              child: ListTile(
                                dense: true,
                                leading: const Icon(Icons.edit_note_outlined),
                                title: Text(l10n.customItemsSalesTitle),
                                subtitle: Text(
                                  l10n.customItemsSalesNote(
                                    report.customSales.lineCount,
                                  ),
                                ),
                                isThreeLine: true,
                                trailing: Text(
                                  '${MoneyUtils.format(report.customSales.revenueCents)} $currency',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                          _InfoNote(text: l10n.reportsInfoNote),
                        ],
                      ),
          ),
        ),
      ],
    );
  }
}

class _MarginTile extends StatelessWidget {
  const _MarginTile({
    required this.row,
    required this.currency,
    required this.percent,
  });

  final ItemMarginRow row;
  final String currency;
  final String percent;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final marginColor = row.marginCents >= 0 ? Colors.green : colorScheme.error;

    final parts = <String>[
      '${QuantityUtils.format(row.quantityMilli)} ${row.unit}',
      '${MoneyUtils.format(row.revenueCents)} $currency',
      if (row.hasMissingCost) l10n.noCostLabel,
    ];

    return ListTile(
      dense: true,
      title: Text(row.itemName),
      subtitle: Text(
        parts.join(' • '),
        style: TextStyle(color: row.hasMissingCost ? colorScheme.error : null),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${MoneyUtils.format(row.marginCents)} $currency',
            style: TextStyle(fontWeight: FontWeight.bold, color: marginColor),
          ),
          if (percent.isNotEmpty)
            Text(
              percent,
              style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Losses
// ---------------------------------------------------------------------

class _LossesTab extends StatelessWidget {
  const _LossesTab();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<ReportProvider>();
    final currency = context.watch<UserProvider>().user?.currency ?? 'MZN';
    final colorScheme = Theme.of(context).colorScheme;
    final report = provider.lossReport;

    return Column(
      children: [
        const _PeriodChips(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => context.read<ReportProvider>().loadLosses(),
            child: provider.isLoadingLosses && report == null
                ? const Center(child: CircularProgressIndicator())
                : report == null || report.isEmpty
                    ? ListView(
                        children: [
                          const SizedBox(height: 100),
                          Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 32),
                              child: Text(
                                l10n.noLossesInPeriod,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      )
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        children: [
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.lossesTotalLabel,
                                    style: TextStyle(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${MoneyUtils.format(report.totalValueCents)} $currency',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(color: colorScheme.error),
                                  ),
                                  if (report.itemsWithoutCost > 0) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      l10n.itemsWithoutCostNote(
                                        report.itemsWithoutCost,
                                      ),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: colorScheme.error,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Card(
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              children: [
                                for (final row in report.rows)
                                  _LossTile(row: row, currency: currency),
                              ],
                            ),
                          ),
                          _InfoNote(text: l10n.reportsInfoNote),
                        ],
                      ),
          ),
        ),
      ],
    );
  }
}

class _LossTile extends StatelessWidget {
  const _LossTile({required this.row, required this.currency});

  final ItemLossRow row;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    final parts = <String>[
      '${QuantityUtils.format(row.quantityMilli)} ${row.unit}',
      if (row.hasMissingCost) l10n.noCostLabel,
    ];

    return ListTile(
      dense: true,
      title: Text(row.itemName),
      subtitle: Text(
        parts.join(' • '),
        style: TextStyle(color: row.hasMissingCost ? colorScheme.error : null),
      ),
      trailing: Text(
        '${MoneyUtils.format(row.valueCents)} $currency',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: colorScheme.error,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Shared bits
// ---------------------------------------------------------------------

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
    this.color,
  });

  final String label;
  final String value;
  final bool bold;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: bold ? 16 : 14,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      color: color,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style.copyWith(color: null)),
          Text(value, style: style),
        ],
      ),
    );
  }
}

class _InfoNote extends StatelessWidget {
  const _InfoNote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontStyle: FontStyle.italic,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}