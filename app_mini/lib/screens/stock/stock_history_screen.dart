import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:mini/l10n/app_localizations.dart';

import '../../core/quantity_utils.dart';
import '../../models/stock_movement_model.dart';
import '../../providers/stock_provider.dart';
import '/widgets/stock_movement_label.dart';

/* Read-only history of ALL stock movements of the active store, newest
first, paged. Filters: movement type (chips) and product (searchable menu).
Sales and sale reversals appear here too, with the sale reference. No
prices and no actions: stock only moves from Products ("Move stock") and
from Sales. [initialItemId] opens the screen already filtered by a product. */
class StockHistoryScreen extends StatefulWidget {
  const StockHistoryScreen({super.key, this.initialItemId});

  final int? initialItemId;

  @override
  State<StockHistoryScreen> createState() => _StockHistoryScreenState();
}

class _StockHistoryScreenState extends State<StockHistoryScreen> {
  static const List<String> _types = [
    StockMovementModel.typeInitial,
    StockMovementModel.typePurchase,
    StockMovementModel.typeSale,
    StockMovementModel.typeSaleReversal,
    StockMovementModel.typeAdjustmentOut,
    StockMovementModel.typeLoss,
    StockMovementModel.typeAdjustmentIn,
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<StockProvider>();
      // Fresh entry: type filter cleared, product filter as requested.
      provider.loadHistory(catalogItemId: widget.initialItemId);
      provider.loadHistoryProducts();
    });
  }

  void _filterProduct(int? itemId) {
    final provider = context.read<StockProvider>();
    provider.loadHistory(
      catalogItemId: itemId,
      movementType: provider.historyTypeFilter,
    );
  }

  void _filterType(String? type) {
    final provider = context.read<StockProvider>();
    provider.loadHistory(
      catalogItemId: provider.historyItemFilter,
      movementType: type,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<StockProvider>();
    final colorScheme = Theme.of(context).colorScheme;
    final history = provider.history;
    final products = provider.historyProducts;
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(title: Text(l10n.stockHistoryTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: DropdownMenu<int?>(
              // Rebuilt once the product list arrives, so the initial
              // selection is matched against the loaded entries.
              key: ValueKey('products-${products.length}'),
              expandedInsets: EdgeInsets.zero,
              enableFilter: true,
              requestFocusOnTap: true,
              label: Text(l10n.productLabel),
              initialSelection: provider.historyItemFilter,
              dropdownMenuEntries: [
                DropdownMenuEntry<int?>(
                  value: null,
                  label: l10n.allProductsLabel,
                ),
                ...products.map(
                  (r) => DropdownMenuEntry<int?>(
                    value: r.item.idCatalogItem,
                    label: r.item.name,
                  ),
                ),
              ],
              onSelected: _filterProduct,
            ),
          ),
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(l10n.allTypesLabel),
                    selected: provider.historyTypeFilter == null,
                    onSelected: (_) => _filterType(null),
                  ),
                ),
                ..._types.map(
                  (type) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(stockMovementLabel(l10n, type)),
                      selected: provider.historyTypeFilter == type,
                      onSelected: (_) => _filterType(type),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => context
                  .read<StockProvider>()
                  .loadHistory(keepFilters: true),
              child: provider.isLoadingHistory && history.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : history.isEmpty
                      ? ListView(
                          children: [
                            const SizedBox(height: 120),
                            Center(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 32),
                                child: Text(
                                  provider.errorMessage ?? l10n.noMovementsYet,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView.separated(
                          itemCount:
                              history.length + (provider.historyHasMore ? 1 : 0),
                          separatorBuilder: (_, __) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) {
                            if (index == history.length) {
                              return Padding(
                                padding: const EdgeInsets.all(8),
                                child: Center(
                                  child: provider.isLoadingHistory
                                      ? const CircularProgressIndicator()
                                      : TextButton(
                                          onPressed: () => context
                                              .read<StockProvider>()
                                              .loadMoreHistory(),
                                          child: Text(l10n.loadMoreLabel),
                                        ),
                                ),
                              );
                            }

                            final entry = history[index];
                            final m = entry.movement;
                            final sign = m.isIncoming ? '+' : '';
                            final color =
                                m.isIncoming ? Colors.green : colorScheme.error;
                            return ListTile(
                              leading: Icon(
                                m.isIncoming
                                    ? Icons.arrow_downward
                                    : Icons.arrow_upward,
                                color: color,
                              ),
                              title: Text(entry.itemName),
                              subtitle: Text(
                                [
                                  stockMovementLabel(l10n, m.movementType),
                                  if (entry.saleReference != null)
                                    entry.saleReference!,
                                  dateFormat.format(m.createdAt),
                                  if (m.notes != null) m.notes!,
                                ].join(' • '),
                              ),
                              trailing: Text(
                                '$sign${QuantityUtils.format(m.quantityMilli)} ${entry.itemUnit}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                ),
                              ),
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