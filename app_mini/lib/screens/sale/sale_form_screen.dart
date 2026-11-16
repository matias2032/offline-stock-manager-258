import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/money_utils.dart';
import '../../core/quantity_utils.dart';
import '../../models/sale_item_model.dart';
import '../../providers/customer_provider.dart';
import '../../providers/sale_provider.dart';
import '../../providers/user_provider.dart';
import '/widgets/app_sidebar.dart';
import '/widgets/sale_item_picker.dart';
import 'package:mini/l10n/app_localizations.dart';

/* One line of the cart. Holds its own controllers so quantity and price
stay editable; the subtotal is derived. */
class _CartLine {
  _CartLine(this.sellable)
      : quantityController = TextEditingController(text: '1'),
        priceController = TextEditingController(
          text: MoneyUtils.toInputText(sellable.item.salePriceCents),
        );

  final SellableItem sellable;
  final TextEditingController quantityController;
  final TextEditingController priceController;

  int get quantityMilli => QuantityUtils.parseToMilli(quantityController.text);
  int get unitPriceCents => MoneyUtils.parseToCents(priceController.text);
  int get subtotalCents =>
      QuantityUtils.lineSubtotalCents(quantityMilli, unitPriceCents);

  void dispose() {
    quantityController.dispose();
    priceController.dispose();
  }
}

class SaleFormScreen extends StatefulWidget {
  const SaleFormScreen({super.key});

  @override
  State<SaleFormScreen> createState() => _SaleFormScreenState();
}

class _SaleFormScreenState extends State<SaleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _totalAmountController = TextEditingController();
  final _walkInNameController = TextEditingController();
  final _initialPaymentController = TextEditingController();
  final _notesController = TextEditingController();

  /* Fixed rule: with at least one line in the cart the sale is built from
  the catalog (description and total are computed); with an empty cart it is
  a free sale (manual description and total), exactly as before. */
  final List<_CartLine> _cart = [];

  String _saleType = 'NORMAL';

  /* Customer selection applies to both NORMAL and CREDIT sales now.
  For NORMAL it's optional; for CREDIT it's required (customer OR walk-in name).*/
  bool _useExistingCustomer = true;
  int? _customerId;

  DateTime? _creditDueDate;

  bool get _isItemsMode => _cart.isNotEmpty;

  int get _cartTotalCents =>
      _cart.fold<int>(0, (sum, line) => sum + line.subtotalCents);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerProvider>().loadCustomers();
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _totalAmountController.dispose();
    _walkInNameController.dispose();
    _initialPaymentController.dispose();
    _notesController.dispose();
    for (final line in _cart) {
      line.dispose();
    }
    super.dispose();
  }

  /* True when the user typed or picked anything. Used to decide whether leaving
  the screen (back button or sidebar) must ask for confirmation. */
  bool get _hasUnsavedData =>
      _descriptionController.text.trim().isNotEmpty ||
      _totalAmountController.text.trim().isNotEmpty ||
      _walkInNameController.text.trim().isNotEmpty ||
      _initialPaymentController.text.trim().isNotEmpty ||
      _notesController.text.trim().isNotEmpty ||
      _customerId != null ||
      _creditDueDate != null ||
      _cart.isNotEmpty;

  /* Returns true when it is safe to leave: either nothing was entered,
  or the user explicitly chose to discard what they typed. */
  Future<bool> _confirmDiscard() async {
    if (!_hasUnsavedData) return true;
    final l10n = AppLocalizations.of(context)!;
    final discard = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.discardSaleTitle),
        content: Text(l10n.discardSaleMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.keepEditingLabel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.discardLabel),
          ),
        ],
      ),
    );
    return discard == true;
  }

  int _toCents(String text) {
    final value = double.tryParse(text.trim().replaceAll(',', '.')) ?? 0;
    return (value * 100).round();
  }

  Future<void> _pickCreditDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked != null) {
      setState(() => _creditDueDate = picked);
    }
  }

  Future<void> _addItem() async {
    final picked = await showSaleItemPicker(context);
    if (picked == null || !mounted) return;

    setState(() {
      // Picking the same item again just adds one more unit.
      for (final line in _cart) {
        if (line.sellable.item.idCatalogItem == picked.item.idCatalogItem) {
          line.quantityController.text = QuantityUtils.format(
            line.quantityMilli + QuantityUtils.scale,
          );
          return;
        }
      }
      _cart.add(_CartLine(picked));
    });
  }

  void _removeLine(int index) {
    final removed = _cart[index];
    setState(() => _cart.removeAt(index));
    // The field is still in the tree for this frame: dispose afterwards.
    WidgetsBinding.instance.addPostFrameCallback((_) => removed.dispose());
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context)!;
    final isCredit = _saleType == 'CREDIT';
    final totalCents =
        _isItemsMode ? _cartTotalCents : _toCents(_totalAmountController.text);

    int? initialPaymentCents;
    if (isCredit) {
      if (_useExistingCustomer && _customerId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.selectCustomerMessage)),
        );
        return;
      }
if (!_useExistingCustomer && _walkInNameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.enterWalkInNameMessage)),
        );
        return;
      }

      /* Due date is fully optional — a credit sale can have no fixed deadline and simply stay OUTSTANDING until it's paid off.

      The entry field is optional: empty means no down payment, the full total stays outstanding.*/
      final rawEntry = _initialPaymentController.text.trim();
      if (rawEntry.isNotEmpty) {
        final entryCents = _toCents(rawEntry);
        if (entryCents <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.enterValidInitialPaymentMessage)),
          );
          return;
        }
        if (entryCents > totalCents) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.initialPaymentExceedsTotalMessage),
            ),
          );
          return;
        }
        initialPaymentCents = entryCents;
      }
    }

    final provider = context.read<SaleProvider>();
    final bool success;
    if (_isItemsMode) {
      success = await provider.createSaleWithItems(
        lines: _cart
            .map((line) => SaleLineInput(
                  catalogItemId: line.sellable.item.idCatalogItem!,
                  quantityMilli: line.quantityMilli,
                  unitPriceCents: line.unitPriceCents,
                ))
            .toList(),
        saleType: _saleType,
        customerId: _useExistingCustomer ? _customerId : null,
        walkInCustomerName:
            !_useExistingCustomer ? _walkInNameController.text : null,
        creditDueDate: isCredit ? _creditDueDate : null,
        notes: _notesController.text,
        initialPaymentCents: initialPaymentCents,
      );
    } else {
      success = await provider.createSale(
        description: _descriptionController.text,
        totalAmountCents: totalCents,
        saleType: _saleType,
        customerId: _useExistingCustomer ? _customerId : null,
        walkInCustomerName:
            !_useExistingCustomer ? _walkInNameController.text : null,
        creditDueDate: isCredit ? _creditDueDate : null,
        notes: _notesController.text,
        initialPaymentCents: initialPaymentCents,
      );
    }

    if (!mounted) return;

    // Stock errors (e.g. insufficient balance) come from the repository.
    if (!success && _isItemsMode && provider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage!)),
      );
    }
    if (!success) return;

    /* Send the user to where the new sale actually lives: NORMAL sales are
    COMPLETED right away (finished sales list), CREDIT sales stay OUTSTANDING
    (credit sales list) unless the down payment already covers the full total. */
    final settledNow =
        initialPaymentCents != null && initialPaymentCents == totalCents;
    final destination = (isCredit && !settledNow) ? '/credit-sale' : '/sale';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.saleCreatedMessage)),
    );
    Navigator.of(context).pushReplacementNamed(destination);
  }

  Widget _buildCartLine(
    AppLocalizations l10n,
    _CartLine line,
    int index,
    String currency,
  ) {
    final item = line.sellable.item;
    return Card(
      key: ObjectKey(line),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: l10n.removeItemTooltip,
                  onPressed: () => _removeLine(index),
                ),
              ],
            ),
            if (line.sellable.tracksStock)
              Text(
                l10n.stockAvailableLabel(
                  QuantityUtils.format(line.sellable.balanceMilli!),
                  item.unit,
                ),
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: line.quantityController,
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
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: line.priceController,
                    decoration: InputDecoration(
                      labelText: '${l10n.unitPriceLabel} ($currency)',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) =>
                        MoneyUtils.parseToCents(value ?? '') <= 0
                            ? l10n.enterValidAmountMessage
                            : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                l10n.lineSubtotalLabel(
                  '${MoneyUtils.format(line.subtotalCents)} $currency',
                ),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final customers = context.watch<CustomerProvider>().customers;
    final errorMessage = context.watch<SaleProvider>().errorMessage;
    final isLoading = context.watch<SaleProvider>().isLoading;
    final currency = context.watch<UserProvider>().user?.currency ?? 'MZN';
    final isCredit = _saleType == 'CREDIT';

    return PopScope(
      // Back button: only intercepted while there is unsaved data.
      canPop: !_hasUnsavedData,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _confirmDiscard() && context.mounted) {
          final navigator = Navigator.of(context);
          /* Top-level screens reached through the sidebar have no previous route:
          popping the last route would crash, so close the app instead. */
          if (navigator.canPop()) {
            navigator.pop();
          } else {
            SystemNavigator.pop();
          }
        }
      },
      child: Scaffold(
      appBar: AppBar(title: Text(l10n.newSaleTitle)),
      drawer: AppSidebar(
        currentRoute: '/sale/new',
        creditSalesBadgeCount: context.watch<SaleProvider>().outstandingCreditCount,
        onBeforeNavigate: _confirmDiscard,
      ),
      body: Form(
        key: _formKey,
        // Rebuild on every field change so PopScope.canPop and the cart
        // total stay up to date.
        onChanged: () => setState(() {}),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Text(
              l10n.saleItemsTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            for (var i = 0; i < _cart.length; i++)
              _buildCartLine(l10n, _cart[i], i, currency),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: _addItem,
                icon: const Icon(Icons.add),
                label: Text(l10n.addItemButton),
              ),
            ),
            const SizedBox(height: 16),
            if (_isItemsMode)
              Text(
                '${l10n.totalLabel}: ${MoneyUtils.format(_cartTotalCents)} $currency',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              )
            else ...[
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: l10n.descriptionLabel),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? l10n.descriptionRequiredMessage
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _totalAmountController,
                decoration: InputDecoration(labelText: l10n.totalAmountLabel),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  final cents = _toCents(value ?? '');
                  return cents <= 0 ? l10n.enterValidAmountMessage : null;
                },
              ),
            ],
            const SizedBox(height: 16),
            SegmentedButton<String>(
              segments: [
                ButtonSegment(value: 'NORMAL', label: Text(l10n.normalLabel)),
                ButtonSegment(value: 'CREDIT', label: Text(l10n.creditLabel)),
              ],
              selected: {_saleType},
              onSelectionChanged: (selection) =>
                  setState(() => _saleType = selection.first),
            ),
            const SizedBox(height: 16),
            /* Customer picker: available for every sale, not just credit.
            For NORMAL sales it's optional — leaving it unset just means a walk-in sale with no customer on record.*/
            
            SwitchListTile(
              title: Text(isCredit
                  ? l10n.useExistingCustomerLabel
                  : l10n.associateExistingCustomerOptionalLabel),
              value: _useExistingCustomer,
              onChanged: (value) => setState(() => _useExistingCustomer = value),
            ),
            if (_useExistingCustomer)
              DropdownButtonFormField<int>(
                value: _customerId,
                decoration: InputDecoration(labelText: l10n.customerLabel),
                items: customers
                    .map((customer) => DropdownMenuItem(
                          value: customer.idCustomer,
                          child: Text(customer.name),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _customerId = value),
              )
            else if (isCredit)
              TextFormField(
                controller: _walkInNameController,
                decoration: InputDecoration(labelText: l10n.walkInCustomerNameLabel),
              ),
            if (isCredit) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: _creditDueDate == null
                    ? TextButton.icon(
                        onPressed: _pickCreditDueDate,
                        icon: const Icon(Icons.calendar_today_outlined, size: 16),
                        label: Text(l10n.addDueDateOptionalLabel),
                      )
                    : InputChip(
                        avatar: const Icon(Icons.calendar_today_outlined, size: 16),
                        label: Text(
                          l10n.dueDatePrefix(
                            '${_creditDueDate!.toLocal()}'.split(' ').first,
                          ),
                        ),
                        onDeleted: () => setState(() => _creditDueDate = null),
                      ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _initialPaymentController,
                decoration: InputDecoration(
                  labelText: l10n.initialPaymentOptionalLabel,
                  helperText: l10n.initialPaymentHelperText,
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ],
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(labelText: l10n.notesOptionalLabel),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  errorMessage,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ElevatedButton(
              onPressed: isLoading ? null : _submit,
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.createSaleButton),
            ),
          ],
        ),
      ),
      ),
    );
  }
}