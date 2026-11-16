import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mini/l10n/app_localizations.dart';

import '../../core/quantity_utils.dart';
import '../../models/stock_movement_model.dart';
import '../../providers/sale_provider.dart';
import '../../providers/stock_provider.dart';
import '/widgets/app_sidebar.dart';
import 'stock_history_screen.dart';

/* Stock overview of the active store: balance per product, a search box and
a "below minimum" filter. Tapping a row opens its history and actions. */
class StockListScreen extends StatefulWidget {
  const StockListScreen({super.key});

  @override
  State<StockListScreen> createState() => _StockListScreenState();
}

class _StockListScreenState extends State<StockListScreen> {
  final _searchController = TextEditingController();
  bool _onlyLow = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StockProvider>().loadBalances();
      context.read<SaleProvider>().loadOutstandingCreditCount();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openHistory(StockBalanceRow row) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => StockHistoryScreen(row: row)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<StockProvider>();
    final colorScheme = Theme.of(context).colorScheme;
    final rows = _onlyLow
        ? provider.rows.where((r) => r.isLow).toList()
        : provider.rows;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.stockTitle)),
      drawer: AppSidebar(
        currentRoute: '/stock',
        creditSalesBadgeCount:
            context.watch<SaleProvider>().outstandingCreditCount,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: l10n.searchLabel,
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (value) =>
                  context.read<StockProvider>().loadBalances(search: value),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FilterChip(
                avatar: Icon(
                  Icons.warning_amber_rounded,
                  size: 18,
                  color: colorScheme.error,
                ),
                label: Text(l10n.lowStockFilterLabel(provider.lowStockCount)),
                selected: _onlyLow,
                onSelected: (value) => setState(() => _onlyLow = value),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => context
                  .read<StockProvider>()
                  .loadBalances(keepFilters: true),
              child: provider.isLoading && provider.rows.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : rows.isEmpty
                      ? ListView(
                          children: [
                            const SizedBox(height: 120),
                            Center(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 32),
                                child: Text(
                                  l10n.noStockItemsYet,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView.separated(
                          itemCount: rows.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final row = rows[index];
                            final item = row.item;
                            final parts = <String>[
                              if (item.code != null) item.code!,
                              if (item.deleted) l10n.deletedLabel,
                              if (!item.active && !item.deleted)
                                l10n.inactiveLabel,
                              if (row.needsInitialStock)
                                l10n.noInitialStockLabel,
                              if (item.trackStock && item.minStockMilli > 0)
                                l10n.stockMinLabel(
                                  QuantityUtils.format(item.minStockMilli),
                                ),
                            ];
                            return ListTile(
                              leading: Icon(
                                row.isLow
                                    ? Icons.warning_amber_rounded
                                    : Icons.inventory_outlined,
                                color: row.isLow
                                    ? colorScheme.error
                                    : colorScheme.primary,
                              ),
                              title: Text(item.name),
                              subtitle: parts.isEmpty
                                  ? null
                                  : Text(parts.join(' • ')),
                              trailing: Text(
                                '${QuantityUtils.format(row.balanceMilli)} ${item.unit}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: row.isLow ? colorScheme.error : null,
                                ),
                              ),
                              onTap: () => _openHistory(row),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }
}