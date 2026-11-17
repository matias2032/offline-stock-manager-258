import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:mini/l10n/app_localizations.dart';

import '../core/money_utils.dart';
import '../core/quantity_utils.dart';
import '../models/stock_movement_model.dart';
import '../providers/business_unit_provider.dart';
import '../providers/stock_provider.dart';
import '../providers/supplier_provider.dart';
import '../providers/user_provider.dart';

/* "Move stock" sheet of one product. Opened from the product edit form.
Three options only:
 - Entry (purchase): quantity x cost becomes a protected expense, same
   transaction (StockRepository.registerPurchase). Cost is pre-filled with
   the product cost and, when saved, becomes the new product cost.
 - Exit (internal use / correction) and Loss: need a note and can never take
   the balance below zero.
ADJUSTMENT_IN exists in the ledger but is deliberately not offered here.
Returns true when a movement was saved. */
Future<bool?> showStockMovementSheet(
  BuildContext context,
  StockBalanceRow row,
) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => _StockMovementSheet(row: row),
  );
}

class _StockMovementSheet extends StatefulWidget {
  const _StockMovementSheet({required this.row});

  final StockBalanceRow row;

  @override
  State<_StockMovementSheet> createState() => _StockMovementSheetState();
}

class _StockMovementSheetState extends State<_StockMovementSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _quantityController;
  late final TextEditingController _costController;
  final _notesController = TextEditingController();

  late final List<String> _types;
  late String _type;

  late final BusinessUnitProvider _unitProvider;
  late final int? _initialUnitId;

  int? _supplierId;
  DateTime _date = DateTime.now();
  String? _error;

  bool get _isPurchase => _type == StockMovementModel.typePurchase;

  @override
  void initState() {
    super.initState();
    final item = widget.row.item;

    // An inactive product cannot receive stock, but can still be zeroed.
    _types = [
      if (widget.row.canReceiveStock) StockMovementModel.typePurchase,
      StockMovementModel.typeAdjustmentOut,
      StockMovementModel.typeLoss,
    ];
    _type = _types.first;

    _quantityController = TextEditingController();
    _costController = TextEditingController(
      text: item.costPriceCents > 0
          ? MoneyUtils.toInputText(item.costPriceCents)
          : '',
    );

    // The sheet belongs to one store: if the active store changes, close it.
    _unitProvider = context.read<BusinessUnitProvider>();
    _initialUnitId = _unitProvider.activeBusinessUnit?.idBusinessUnit;
    _unitProvider.addListener(_onUnitChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StockProvider>().clearError();
      context.read<SupplierProvider>().loadSuppliers();
    });
  }

  @override
  void dispose() {
    _unitProvider.removeListener(_onUnitChanged);
    _quantityController.dispose();
    _costController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onUnitChanged() {
    final current = _unitProvider.activeBusinessUnit?.idBusinessUnit;
    if (current != _initialUnitId && mounted) {
      Navigator.of(context).pop(false);
    }
  }

  String _typeLabel(AppLocalizations l10n, String type) {
    switch (type) {
      case StockMovementModel.typePurchase:
        return l10n.movementEntryOption;
      case StockMovementModel.typeAdjustmentOut:
        return l10n.movementAdjustmentOut;
      default:
        return l10n.movementLoss;
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context)!;
    final navigator = Navigator.of(context);
    final provider = context.read<StockProvider>();
    final item = widget.row.item;
    final quantityMilli = QuantityUtils.parseToMilli(_quantityController.text);

    setState(() => _error = null);

    final bool success;
    if (_isPurchase) {
      success = await provider.registerPurchase(
        catalogItemId: item.idCatalogItem!,
        quantityMilli: quantityMilli,
        unitCostCents: MoneyUtils.parseToCents(_costController.text),
        supplierId: _supplierId,
        purchaseDate: _date,
        // Stored in the language active right now.
        expenseDescription: l10n.stockPurchaseExpenseDescription(
          QuantityUtils.format(quantityMilli),
          item.name,
        ),
        notes: _notesController.text,
      );
    } else {
      success = await provider.registerAdjustment(
        catalogItemId: item.idCatalogItem!,
        movementType: _type,
        quantityMilli: quantityMilli,
        notes: _notesController.text,
      );
    }

    if (!mounted) return;
    if (success) {
      navigator.pop(true);
      return;
    }

    // Typed error -> message in the active language, never the English text.
    final shortage = provider.insufficientStock;
    setState(() {
      _error = shortage != null
          ? l10n.insufficientStockMessage(
              QuantityUtils.format(shortage.balanceMilli),
              item.unit,
            )
          : provider.errorMessage;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<StockProvider>();
    final suppliers = context.watch<SupplierProvider>().suppliers;
    final currency = context.watch<UserProvider>().user?.currency ?? 'MZN';
    final colorScheme = Theme.of(context).colorScheme;

    // Fresh balance from the provider (it reloads after each write).
    final row = provider.rowFor(widget.row.item.idCatalogItem!) ?? widget.row;
    final item = row.item;
    final total = QuantityUtils.lineSubtotalCents(
      QuantityUtils.parseToMilli(_quantityController.text),
      MoneyUtils.parseToCents(_costController.text),
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.moveStockButton,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(item.name, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                '${l10n.balanceLabel}: '
                '${QuantityUtils.format(row.balanceMilli)} ${item.unit}',
                style: TextStyle(color: row.isLow ? colorScheme.error : null),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _type,
                decoration: InputDecoration(labelText: l10n.movementTypeLabel),
                items: _types
                    .map(
                      (t) => DropdownMenuItem(
                        value: t,
                        child: Text(_typeLabel(l10n, t)),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() {
                  _type = value ?? _type;
                  _error = null;
                }),
              ),
              const SizedBox(height: 16),
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
                onChanged: (_) => setState(() {}),
                validator: (value) =>
                    (QuantityUtils.tryParseToMilli(value ?? '') ?? 0) <= 0
                        ? l10n.enterValidQuantityMessage
                        : null,
              ),
              if (_isPurchase) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _costController,
                  decoration: InputDecoration(
                    labelText: '${l10n.unitCostLabel} ($currency)',
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => setState(() {}),
                  validator: (value) =>
                      MoneyUtils.parseToCents(value ?? '') <= 0
                          ? l10n.enterValidAmountMessage
                          : null,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.purchaseTotalLabel(
                    '${MoneyUtils.format(total)} $currency',
                  ),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int?>(
                  initialValue: _supplierId,
                  decoration:
                      InputDecoration(labelText: l10n.supplierOptionalLabel),
                  items: [
                    DropdownMenuItem<int?>(
                      value: null,
                      child: Text(l10n.noneLabel),
                    ),
                    ...suppliers.map(
                      (s) => DropdownMenuItem<int?>(
                        value: s.idSupplier,
                        child: Text(s.name),
                      ),
                    ),
                  ],
                  onChanged: (value) => setState(() => _supplierId = value),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: _pickDate,
                  child: Text(
                    l10n.dateLabel(DateFormat('dd/MM/yyyy').format(_date)),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText:
                      _isPurchase ? l10n.notesOptionalLabel : l10n.notesLabel,
                ),
                maxLines: 2,
                validator: (value) =>
                    !_isPurchase && (value ?? '').trim().isEmpty
                        ? l10n.noteRequiredMessage
                        : null,
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    _error!,
                    style: TextStyle(color: colorScheme.error),
                  ),
                ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: provider.isLoading ? null : _submit,
                  child: provider.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.saveLabel),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}