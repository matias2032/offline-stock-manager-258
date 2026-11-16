import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:mini/l10n/app_localizations.dart';

import '../../core/money_utils.dart';
import '../../core/quantity_utils.dart';
import '../../models/stock_movement_model.dart';
import '../../providers/stock_provider.dart';
import '../../providers/user_provider.dart';
import '/widgets/stock_movement_label.dart';
import 'stock_adjustment_screen.dart';
import 'stock_purchase_screen.dart';


/* Balance summary, actions and movement history (newest first) of one
product. Movements are read-only: corrections are new movements. */
class StockHistoryScreen extends StatefulWidget {
  const StockHistoryScreen({super.key, required this.row});

  final StockBalanceRow row;

  @override
  State<StockHistoryScreen> createState() => _StockHistoryScreenState();
}

class _StockHistoryScreenState extends State<StockHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StockProvider>().loadMovements(widget.row.item.idCatalogItem!);
    });
  }

  void _push(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<StockProvider>();
    final currency = context.watch<UserProvider>().user?.currency ?? 'MZN';
    final colorScheme = Theme.of(context).colorScheme;

    // Fresh row from the provider (balance changes after each movement).
    final row = provider.rowFor(widget.row.item.idCatalogItem!) ?? widget.row;
    final item = row.item;
    final movements = provider.movements;
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final canAdjust = row.movementCount > 0 || row.canReceiveStock;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.stockHistoryTitle)),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  '${QuantityUtils.format(row.balanceMilli)} ${item.unit}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: row.isLow ? colorScheme.error : null,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  [
                    if (row.isLow) l10n.belowMinimumLabel,
                    if (item.minStockMilli > 0)
                      l10n.stockMinLabel(
                        QuantityUtils.format(item.minStockMilli),
                      ),
                    if (item.costPriceCents > 0)
                      '${l10n.costPriceLabel}: '
                          '${MoneyUtils.format(item.costPriceCents)} $currency',
                    if (item.deleted) l10n.deletedLabel,
                    if (!item.active && !item.deleted) l10n.inactiveLabel,
                  ].join(' • '),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        icon: const Icon(Icons.add_shopping_cart_outlined),
                        label: Text(l10n.stockPurchaseButton),
                        onPressed: row.canReceiveStock
                            ? () => _push(StockPurchaseScreen(row: row))
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.tune),
                        label: Text(
                          row.movementCount == 0
                              ? l10n.initialStockButton
                              : l10n.adjustStockButton,
                        ),
                        onPressed: canAdjust
                            ? () => _push(StockAdjustmentScreen(row: row))
                            : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (movements.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(child: Text(l10n.noMovementsYet)),
            )
          else
            ...movements.map((m) {
              final sign = m.isIncoming ? '+' : '';
              final details = <String>[
                dateFormat.format(m.createdAt),
                if (m.unitCostCents != null)
                  '${MoneyUtils.format(m.unitCostCents!)} $currency',
                if (m.notes != null) m.notes!,
              ];
              return ListTile(
                leading: Icon(
                  m.isIncoming ? Icons.arrow_downward : Icons.arrow_upward,
                  color: m.isIncoming ? Colors.green : colorScheme.error,
                ),
                title: Text(stockMovementLabel(l10n, m.movementType)),
                subtitle: Text(details.join(' • ')),
                trailing: Text(
                  '$sign${QuantityUtils.format(m.quantityMilli)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: m.isIncoming ? Colors.green : colorScheme.error,
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}