import 'package:flutter/material.dart';

import '../core/money_utils.dart';
import '../core/quantity_utils.dart';
import '../models/sale_item_model.dart';

/* Read-only list of the lines of a sale (snapshot values). Shared by the
sales list and the credit sale detail screen. */
class SaleItemLines extends StatelessWidget {
  const SaleItemLines({
    super.key,
    required this.title,
    required this.items,
    required this.currency,
  });

  final String title;
  final List<SaleItemModel> items;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final subtle = Theme.of(context).colorScheme.onSurfaceVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        for (final item in items)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.itemNameSnapshot),
                      Text(
                        '${QuantityUtils.format(item.quantityMilli)} '
                        '${item.unitSnapshot} × '
                        '${MoneyUtils.format(item.unitPriceCents)} $currency',
                        style: TextStyle(fontSize: 12, color: subtle),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${MoneyUtils.format(item.subtotalCents)} $currency',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
      ],
    );
  }
}