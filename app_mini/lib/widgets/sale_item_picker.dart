import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mini/l10n/app_localizations.dart';

import '../core/money_utils.dart';
import '../core/quantity_utils.dart';
import '../models/sale_item_model.dart';
import '../providers/sale_provider.dart';
import '../providers/user_provider.dart';

/* Bottom sheet to pick one catalog item for a sale. Lists only active items
of the store, with search. Tracked products show their balance and are
disabled when out of stock. Returns the chosen item or null. */
Future<SellableItem?> showSaleItemPicker(BuildContext context) {
  return showModalBottomSheet<SellableItem>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => const _SaleItemPickerSheet(),
  );
}

class _SaleItemPickerSheet extends StatefulWidget {
  const _SaleItemPickerSheet();

  @override
  State<_SaleItemPickerSheet> createState() => _SaleItemPickerSheetState();
}

class _SaleItemPickerSheetState extends State<_SaleItemPickerSheet> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SaleProvider>().loadSellableItems();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<SaleProvider>();
    final currency = context.watch<UserProvider>().user?.currency ?? 'MZN';
    final colorScheme = Theme.of(context).colorScheme;
    final items = provider.sellableItems;

    return FractionallySizedBox(
      heightFactor: 0.85,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.selectItemTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: l10n.searchLabel,
                  prefixIcon: const Icon(Icons.search),
                ),
                onChanged: (value) =>
                    context.read<SaleProvider>().loadSellableItems(search: value),
              ),
            ),
            Expanded(
              child: provider.isLoadingSellable && items.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : items.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              l10n.noSellableItemsYet,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : ListView.separated(
                          itemCount: items.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final sellable = items[index];
                            final item = sellable.item;
                            final parts = <String>[
                              item.isProduct
                                  ? l10n.productLabel
                                  : l10n.serviceLabel,
                              if (item.code != null) item.code!,
                              if (sellable.isOutOfStock)
                                l10n.outOfStockLabel
                              else if (sellable.tracksStock)
                                l10n.stockAvailableLabel(
                                  QuantityUtils.format(sellable.balanceMilli!),
                                  item.unit,
                                ),
                            ];
                            return ListTile(
                              enabled: !sellable.isOutOfStock,
                              leading: Icon(
                                item.isProduct
                                    ? Icons.inventory_2_outlined
                                    : Icons.handyman_outlined,
                                color: sellable.isOutOfStock
                                    ? colorScheme.outline
                                    : colorScheme.primary,
                              ),
                              title: Text(item.name),
                              subtitle: Text(parts.join(' • ')),
                              trailing: Text(
                                '${MoneyUtils.format(item.salePriceCents)} $currency',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              onTap: () => Navigator.of(context).pop(sellable),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}