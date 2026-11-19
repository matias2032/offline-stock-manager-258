import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mini/l10n/app_localizations.dart';

import '../core/money_utils.dart';
import '../core/quantity_utils.dart';
import '../models/sale_item_model.dart';
import '../providers/business_unit_provider.dart';
import '../providers/sale_provider.dart';
import '../providers/user_provider.dart';

/* What the picker returns: either a catalog item (with its balance at the
moment of picking) or a custom line typed by the seller (name, quantity and
price, no stock, no cost). */
class SaleItemPickResult {
  const SaleItemPickResult.catalog(SellableItem this.sellable)
      : customName = null,
        customQuantityMilli = null,
        customPriceCents = null;

  const SaleItemPickResult.custom({
    required String name,
    required int quantityMilli,
    required int priceCents,
  })  : sellable = null,
        customName = name,
        customQuantityMilli = quantityMilli,
        customPriceCents = priceCents;

  final SellableItem? sellable;
  final String? customName;
  final int? customQuantityMilli;
  final int? customPriceCents;

  bool get isCustom => sellable == null;
}

/* Bottom sheet to pick one product or service for a sale. Lists the active
items of the store, with search. A sold-out product shows a red "Out of
stock" tag and, when tapped, explains why it cannot be added. Returns the
chosen item, or null. Closes itself if the active store changes. */
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

  late final BusinessUnitProvider _unitProvider;
  late final int? _initialUnitId;

  @override
  void initState() {
    super.initState();
    _unitProvider = context.read<BusinessUnitProvider>();
    _initialUnitId = _unitProvider.activeBusinessUnit?.idBusinessUnit;
    _unitProvider.addListener(_onUnitChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SaleProvider>().loadSellableItems();
    });
  }

  @override
  void dispose() {
    _unitProvider.removeListener(_onUnitChanged);
    _searchController.dispose();
    super.dispose();
  }

  // Items belong to one store: if it changes, the sheet closes with no result.
  void _onUnitChanged() {
    final current = _unitProvider.activeBusinessUnit?.idBusinessUnit;
    if (current != _initialUnitId && mounted) {
      Navigator.of(context).pop();
    }
  }


  Future<void> _onTapItem(SellableItem sellable) async {
    if (sellable.isOutOfStock) {
      final l10n = AppLocalizations.of(context)!;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l10n.outOfStockLabel),
          content: Text(l10n.outOfStockNotice(sellable.item.name)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.okLabel),
            ),
          ],
        ),
      );
      return;
    }
    Navigator.of(context).pop(sellable);
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
            const Divider(height: 1),
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
                            final soldOut = sellable.isOutOfStock;
                            final stockText = (!soldOut && sellable.tracksStock)
                                ? l10n.stockAvailableLabel(
                                    QuantityUtils.format(sellable.balanceMilli!),
                                    item.unit,
                                  )
                                : null;

                            return ListTile(
                              leading: Icon(
                                item.isProduct
                                    ? Icons.inventory_2_outlined
                                    : Icons.handyman_outlined,
                                color: soldOut
                                    ? colorScheme.outline
                                    : colorScheme.primary,
                              ),
                              title: Text(
                                item.name,
                                style: soldOut
                                    ? TextStyle(color: colorScheme.outline)
                                    : null,
                              ),
                              subtitle: Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: item.isProduct
                                          ? l10n.productLabel
                                          : l10n.serviceLabel,
                                    ),
                                    if (stockText != null)
                                      TextSpan(
                                        text: ' • $stockText',
                                        style: sellable.isLowStock
                                            ? TextStyle(
                                                color: colorScheme.error,
                                                fontWeight: FontWeight.w600,
                                              )
                                            : null,
                                      ),
                                  ],
                                ),
                              ),
                              trailing: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${MoneyUtils.format(item.salePriceCents)} $currency',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  if (soldOut)
                                    Container(
                                      margin: const EdgeInsets.only(top: 2),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: colorScheme.error,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        l10n.outOfStockLabel,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: colorScheme.onError,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              onTap: () => _onTapItem(sellable),
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
