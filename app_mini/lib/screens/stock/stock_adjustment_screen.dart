import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:mini/l10n/app_localizations.dart';

import '../../core/money_utils.dart';
import '../../core/quantity_utils.dart';
import '../../models/stock_movement_model.dart';
import '../../providers/stock_provider.dart';
import '../../providers/user_provider.dart';
import '/widgets/stock_movement_label.dart';

/* Initial stock or manual adjustment. Fixed rule: an item without movements
can only receive INITIAL stock; once it has movements, only adjustments
(in / out / loss) are offered. Neither creates an expense. */
class StockAdjustmentScreen extends StatefulWidget {
  const StockAdjustmentScreen({super.key, required this.row});

  final StockBalanceRow row;

  @override
  State<StockAdjustmentScreen> createState() => _StockAdjustmentScreenState();
}

class _StockAdjustmentScreenState extends State<StockAdjustmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _costController = TextEditingController();
  final _notesController = TextEditingController();

  late final List<String> _types;
  late String _type;

  bool get _isInitial => _type == StockMovementModel.typeInitial;
  bool get _isOutgoing =>
      _type == StockMovementModel.typeAdjustmentOut ||
      _type == StockMovementModel.typeLoss;

  @override
  void initState() {
    super.initState();
    _types = widget.row.movementCount == 0
        ? [StockMovementModel.typeInitial]
        : [
            StockMovementModel.typeAdjustmentIn,
            StockMovementModel.typeAdjustmentOut,
            StockMovementModel.typeLoss,
          ];
    _type = _types.first;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StockProvider>().clearError();
    });
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _costController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final provider = context.read<StockProvider>();
    final quantityMilli = QuantityUtils.parseToMilli(_quantityController.text);
    final itemId = widget.row.item.idCatalogItem!;

    final success = _isInitial
        ? await provider.registerInitialStock(
            catalogItemId: itemId,
                      quantityMilli: quantityMilli,
            unitCostCents: MoneyUtils.parseToCents(_costController.text),
            notes: _notesController.text,
          )
        : await provider.registerAdjustment(
            catalogItemId: itemId,
            movementType: _type,
                            quantityMilli: quantityMilli,
            notes: _notesController.text,
          );

    if (!mounted) return;
    if (success) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.stockMovementSaved)));
      navigator.pop();
    } else if (provider.errorMessage != null) {
      messenger.showSnackBar(SnackBar(content: Text(provider.errorMessage!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<StockProvider>();
    final currency = context.watch<UserProvider>().user?.currency ?? 'MZN';
    final item = widget.row.item;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isInitial ? l10n.initialStockButton : l10n.adjustStockButton),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(item.name, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              '${l10n.balanceLabel}: '
              '${QuantityUtils.format(widget.row.balanceMilli)} ${item.unit}',
            ),
            const SizedBox(height: 16),
            if (_types.length > 1)
              DropdownButtonFormField<String>(
                initialValue: _type,
                decoration: InputDecoration(labelText: l10n.movementTypeLabel),
                items: _types
                    .map(
                      (t) => DropdownMenuItem(
                        value: t,
                        child: Text(stockMovementLabel(l10n, t)),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _type = value ?? _type),
              ),
            if (_types.length > 1) const SizedBox(height: 16),
            TextFormField(
              controller: _quantityController,
              decoration: InputDecoration(
                labelText: '${l10n.quantityLabel} (${item.unit})',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              validator: (value) =>
                  (QuantityUtils.tryParseToMilli(value ?? '') ?? 0) <= 0
                      ? l10n.enterValidQuantityMessage
                      : null,
            ),
            if (_isInitial) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _costController,
                decoration: InputDecoration(
                  labelText: '${l10n.unitCostOptionalLabel} ($currency)',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
            ],
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText:
                    _isOutgoing ? l10n.notesLabel : l10n.notesOptionalLabel,
              ),
              maxLines: 2,
              validator: (value) => _isOutgoing && (value ?? '').trim().isEmpty
                  ? l10n.noteRequiredMessage
                  : null,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: provider.isLoading ? null : _submit,
              child: provider.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.saveLabel),
            ),
          ],
        ),
      ),
    );
  }
}