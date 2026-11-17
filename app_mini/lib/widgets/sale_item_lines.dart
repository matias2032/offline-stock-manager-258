import 'package:flutter/material.dart';

import '../core/money_utils.dart';
import '../core/quantity_utils.dart';
import 'package:mini/l10n/app_localizations.dart';

import '../models/sale_item_model.dart';

/* Read-only list of the lines of a sale (snapshot values), used by the sale
detail screen. Custom (free-text) lines carry a small tag. */
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
    final l10n = AppLocalizations.of(context)!;

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
                      Row(
                        children: [
                          Flexible(child: Text(item.itemNameSnapshot)),
                          if (item.isCustom) ...[
                            const SizedBox(width: 6),
                            _CustomTag(label: l10n.customItemTag),
                          ],
                        ],
                      ),
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

class _CustomTag extends StatelessWidget {
  const _CustomTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, color: scheme.onSecondaryContainer),
      ),
    );
  }
}