import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:mini/l10n/app_localizations.dart';

import '../../core/money_utils.dart';
import '../../core/quantity_utils.dart';
import '../../models/stock_movement_model.dart';
import '../../providers/stock_provider.dart';
import '../../providers/supplier_provider.dart';
import '../../providers/user_provider.dart';

/* Registers a stock purchase for one product. Fixed rule, no options: the
purchase always creates its expense (quantity x unit cost) automatically. */
class StockPurchaseScreen extends StatefulWidget {
  const StockPurchaseScreen({super.key, required this.row});

  final StockBalanceRow row;

  @override
  State<StockPurchaseScreen> createState() => _StockPurchaseScreenState();
}

class _StockPurchaseScreenState extends State<StockPurchaseScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _quantityController;
  late final TextEditingController _costController;
  late final TextEditingController _notesController;

  int? _supplierId;
  DateTime _purchaseDate = DateTime.now();

  int get _quantityMilli => QuantityUtils.parseToMilli(_quantityController.text);
  int get _unitCostCents => MoneyUtils.parseToCents(_costController.text);

  @override
  void initState() {
    super.initState();
    final cost = widget.row.item.costPriceCents;
    _quantityController = TextEditingController();
    _costController = TextEditingController(
      text: cost > 0 ? MoneyUtils.toInputText(cost) : '',
    );
    _notesController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StockProvider>().clearError();
      context.read<SupplierProvider>().loadSuppliers();
    });
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _costController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _purchaseDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _purchaseDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final provider = context.read<StockProvider>();
    final item = widget.row.item;

    final success = await provider.registerPurchase(
      catalogItemId: item.idCatalogItem!,
            quantityMilli: _quantityMilli,
      unitCostCents: _unitCostCents,
      supplierId: _supplierId,
      purchaseDate: _purchaseDate,
      // Stored in the language active right now.
      expenseDescription: l10n.stockPurchaseExpenseDescription(
        QuantityUtils.format(_quantityMilli),
        item.name,
      ),
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
    final suppliers = context.watch<SupplierProvider>().suppliers;
    final currency = context.watch<UserProvider>().user?.currency ?? 'MZN';
    final item = widget.row.item;
    final total =
        QuantityUtils.lineSubtotalCents(_quantityMilli, _unitCostCents);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.stockPurchaseTitle)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(item.name, style: Theme.of(context).textTheme.titleMedium),
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
            const SizedBox(height: 16),
            TextFormField(
              controller: _costController,
              decoration: InputDecoration(
                labelText: '${l10n.unitCostLabel} ($currency)',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => setState(() {}),
              validator: (value) => MoneyUtils.parseToCents(value ?? '') <= 0
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
                l10n.dateLabel(DateFormat('dd/MM/yyyy').format(_purchaseDate)),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(labelText: l10n.notesOptionalLabel),
              maxLines: 2,
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
                  : Text(l10n.stockPurchaseButton),
            ),
          ],
        ),
      ),
    );
  }
}