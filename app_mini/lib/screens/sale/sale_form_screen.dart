import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/money_utils.dart';
import '../../core/quantity_utils.dart';
import '../../models/sale_item_model.dart';
import '../../providers/business_unit_provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/sale_provider.dart';
import '../../providers/user_provider.dart';
import '/widgets/app_sidebar.dart';
import '/widgets/sale_item_picker.dart';
import 'package:mini/l10n/app_localizations.dart';

/* One line of the cart: a catalog item (sellable != null) or a custom line
typed by the seller (customName != null, no stock). Holds its own controllers
so quantity and price stay editable; the subtotal is derived.

[sellable] is a snapshot taken when the item was picked (or last refreshed):
its balance may be out of date, the repository is the final authority.
[unavailable] is set when a refresh finds the item is no longer sellable. */
class _CartLine {
  _CartLine.catalog(SellableItem this.sellable)
      : customName = null,
        quantityController = TextEditingController(text: '1'),
        priceController = TextEditingController(
          text: MoneyUtils.toInputText(sellable.item.salePriceCents),
        );

  _CartLine.custom({
    required String name,
    required int quantityMilli,
    required int priceCents,
  })  : sellable = null,
        customName = name,
        quantityController =
            TextEditingController(text: QuantityUtils.toInputText(quantityMilli)),
        priceController =
            TextEditingController(text: MoneyUtils.toInputText(priceCents));

  SellableItem? sellable;
  final String? customName;
  bool unavailable = false;
  final TextEditingController quantityController;
  final TextEditingController priceController;

  bool get isCustom => sellable == null;
  int? get catalogItemId => sellable?.item.idCatalogItem;
  String get name => customName ?? sellable!.item.name;
  String get unit => sellable?.item.unit ?? 'UN';

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
  final _walkInNameController = TextEditingController();
  final _initialPaymentController = TextEditingController();
  final _notesController = TextEditingController();

  // A sale is always made of lines; the total is their sum (read only).
  final List<_CartLine> _cart = [];

  String _saleType = 'NORMAL';

  /* Customer selection applies to both NORMAL and CREDIT sales.
  For NORMAL it's optional; for CREDIT it's required (customer OR walk-in name).*/
  bool _useExistingCustomer = true;
  int? _customerId;

  DateTime? _creditDueDate;

  late final BusinessUnitProvider _unitProvider;
  int? _activeUnitId;

  int get _cartTotalCents =>
      _cart.fold<int>(0, (sum, line) => sum + line.subtotalCents);

  @override
  void initState() {
    super.initState();
    _unitProvider = context.read<BusinessUnitProvider>();
    _activeUnitId = _unitProvider.activeBusinessUnit?.idBusinessUnit;
    _unitProvider.addListener(_onUnitChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerProvider>().loadCustomers();
      context.read<SaleProvider>().clearError();
    });
  }

  @override
  void dispose() {
    _unitProvider.removeListener(_onUnitChanged);
    _walkInNameController.dispose();
    _initialPaymentController.dispose();
    _notesController.dispose();
    for (final line in _cart) {
      line.dispose();
    }
    super.dispose();
  }

  /* The cart and the chosen customer belong to the previous store: clear
  them and say so. */
  void _onUnitChanged() {
    final current = _unitProvider.activeBusinessUnit?.idBusinessUnit;
    if (!mounted || current == _activeUnitId) return;
    _activeUnitId = current;

    final removed = List<_CartLine>.of(_cart);
    setState(() {
      _cart.clear();
      _customerId = null;
    });
    // The fields are still in the tree for this frame: dispose afterwards.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final line in removed) {
        line.dispose();
      }
    });

    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.cartClearedStoreChangedMessage)),
    );
  }

  /* True when the user typed or picked anything. Used to decide whether leaving
  the screen (back button or sidebar) must ask for confirmation. */
  bool get _hasUnsavedData =>
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
      final sellable = picked.sellable;

      // Custom line: always a new line.
      if (sellable == null) {
        _cart.add(_CartLine.custom(
          name: picked.customName!,
          quantityMilli: picked.customQuantityMilli!,
          priceCents: picked.customPriceCents!,
        ));
        return;
      }

      // Picking the same catalog item again just adds one more unit (and
      // refreshes the balance snapshot with the one just read).
      for (final line in _cart) {
        if (line.catalogItemId == sellable.item.idCatalogItem) {
          line.sellable = sellable;
          line.unavailable = false;
          line.quantityController.text = QuantityUtils.format(
            line.quantityMilli + QuantityUtils.scale,
          );
          return;
        }
      }
      _cart.add(_CartLine.catalog(sellable));
    });
  }

  void _removeLine(int index) {
    final removed = _cart[index];
    setState(() => _cart.removeAt(index));
    // The field is still in the tree for this frame: dispose afterwards.
    WidgetsBinding.instance.addPostFrameCallback((_) => removed.dispose());
  }

  /* Total requested per product (lines of the same product count together,
  whatever their prices). Custom lines and services never use stock. */
  Map<int, int> get _requestedByProduct {
    final requested = <int, int>{};
    for (final line in _cart) {
      final item = line.sellable?.item;
      if (item == null || !item.isProduct) continue;
      final id = item.idCatalogItem!;
      requested[id] = (requested[id] ?? 0) + line.quantityMilli;
    }
    return requested;
  }

  /// The known balance when this line's product is requested above it, else null.
  int? _shortageBalance(_CartLine line, Map<int, int> requested) {
    final sellable = line.sellable;
    if (sellable == null || !sellable.item.isProduct) return null;
    final balance = sellable.balanceMilli;
    if (balance == null) return null;
    final total = requested[sellable.item.idCatalogItem!] ?? 0;
    return total > balance ? balance : null;
  }

  /* Re-reads the sellable items and refreshes the balance of every catalog
  line. A line whose item is no longer offered is flagged as unavailable. */
  Future<void> _refreshCartBalances() async {
    final provider = context.read<SaleProvider>();
    await provider.loadSellableItems();
    if (!mounted) return;

    final fresh = {
      for (final s in provider.sellableItems) s.item.idCatalogItem: s,
    };
    setState(() {
      for (final line in _cart) {
        final id = line.catalogItemId;
        if (id == null) continue;
        final updated = fresh[id];
        if (updated == null) {
          line.unavailable = true;
        } else {
          line.sellable = updated;
          line.unavailable = false;
        }
      }
    });
  }

  Future<void> _showAlert(String title, String message) {
    final l10n = AppLocalizations.of(context)!;
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.okLabel),
          ),
        ],
      ),
    );
  }

  SaleLineInput _toLineInput(_CartLine line) {
    if (line.isCustom) {
      return SaleLineInput.custom(
        name: line.customName!,
        quantityMilli: line.quantityMilli,
        price: line.unitPriceCents,
      );
    }
    return SaleLineInput(
      catalogItemId: line.catalogItemId!,
      quantityMilli: line.quantityMilli,
      unitPriceCents: line.unitPriceCents,
    );
  }

  /* Typed failures become localized dialogs; any other error is already
  shown inline from provider.errorMessage. */
  Future<void> _handleSubmitFailure(SaleProvider provider) async {
    final l10n = AppLocalizations.of(context)!;

    final shortage = provider.insufficientStock;
    if (shortage != null) {
      var unit = '';
      for (final line in _cart) {
        if (line.name == shortage.itemName) {
          unit = line.unit;
          break;
        }
      }
      await _showAlert(
        l10n.insufficientStockDialogTitle,
        l10n.insufficientStockDialogMessage(
          shortage.itemName,
          QuantityUtils.format(shortage.balanceMilli),
          unit,
        ),
      );
      if (mounted) await _refreshCartBalances();
      return;
    }

    if (provider.itemUnavailable) {
      await _showAlert(
        l10n.itemUnavailableTitle,
        l10n.itemUnavailableMessage,
      );
      if (mounted) await _refreshCartBalances();
    }
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;

    if (_cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.saleNeedsItemsMessage)),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    final isCredit = _saleType == 'CREDIT';
    final totalCents = _cartTotalCents;

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
            SnackBar(content: Text(l10n.initialPaymentExceedsTotalMessage)),
          );
          return;
        }
        initialPaymentCents = entryCents;
      }
    }

    final provider = context.read<SaleProvider>();
    final success = await provider.createSaleWithItems(
      lines: _cart.map(_toLineInput).toList(),
      saleType: _saleType,
      customerId: _useExistingCustomer ? _customerId : null,
      walkInCustomerName:
          !_useExistingCustomer ? _walkInNameController.text : null,
      creditDueDate: isCredit ? _creditDueDate : null,
      notes: _notesController.text,
      initialPaymentCents: initialPaymentCents,
    );

    if (!mounted) return;

    if (!success) {
      await _handleSubmitFailure(provider);
      return;
    }

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
    Map<int, int> requested,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final shortage = _shortageBalance(line, requested);

    // At most one status line under the name, by priority.
    Widget? status;
    if (line.unavailable) {
      status = Text(
        l10n.itemUnavailableLine,
        style: TextStyle(fontSize: 12, color: colorScheme.error),
      );
    } else if (shortage != null) {
      status = Text(
        l10n.insufficientStockMessage(
          QuantityUtils.format(shortage),
          line.unit,
        ),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: colorScheme.error,
        ),
      );
    } else if (line.sellable != null &&
        line.sellable!.item.isProduct &&
        line.sellable!.balanceMilli != null) {
      status = Text(
        l10n.stockAvailableLabel(
          QuantityUtils.format(line.sellable!.balanceMilli!),
          line.unit,
        ),
        style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
      );
    }

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
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          line.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (line.isCustom) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            l10n.customItemTag,
                            style: TextStyle(
                              fontSize: 11,
                              color: colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: l10n.removeItemTooltip,
                  onPressed: () => _removeLine(index),
                ),
              ],
            ),
            if (status != null) status,
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: line.quantityController,
                    decoration: InputDecoration(
                      labelText: '${l10n.quantityLabel} (${line.unit})',
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
                    // The subtotal must be > 0, or the repository rejects the line.
                    validator: (value) =>
                        MoneyUtils.parseToCents(value ?? '') <= 0 ||
                                line.subtotalCents <= 0
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

    final requested = _requestedByProduct;
    final blocked = _cart.any(
      (line) => line.unavailable || _shortageBalance(line, requested) != null,
    );

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
          creditSalesBadgeCount:
              context.watch<SaleProvider>().outstandingCreditCount,
          onBeforeNavigate: _confirmDiscard,
        ),
        body: Form(
          key: _formKey,
          // Rebuild on every field change so PopScope.canPop, the live stock
          // alerts and the cart total stay up to date.
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
                _buildCartLine(l10n, _cart[i], i, currency, requested),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: _addItem,
                  icon: const Icon(Icons.add),
                  label: Text(l10n.addItemButton),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${l10n.totalLabel}: ${MoneyUtils.format(_cartTotalCents)} $currency',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
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
                onChanged: (value) =>
                    setState(() => _useExistingCustomer = value),
              ),
              if (_useExistingCustomer)
                DropdownButtonFormField<int>(
                  key: ValueKey('customer-$_activeUnitId-${customers.length}'),
                  initialValue: _customerId,
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
                  decoration:
                      InputDecoration(labelText: l10n.walkInCustomerNameLabel),
                ),
              if (isCredit) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: _creditDueDate == null
                      ? TextButton.icon(
                          onPressed: _pickCreditDueDate,
                          icon: const Icon(Icons.calendar_today_outlined,
                              size: 16),
                          label: Text(l10n.addDueDateOptionalLabel),
                        )
                      : InputChip(
                          avatar: const Icon(Icons.calendar_today_outlined,
                              size: 16),
                          label: Text(
                            l10n.dueDatePrefix(
                              '${_creditDueDate!.toLocal()}'.split(' ').first,
                            ),
                          ),
                          onDeleted: () =>
                              setState(() => _creditDueDate = null),
                        ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _initialPaymentController,
                  decoration: InputDecoration(
                    labelText: l10n.initialPaymentOptionalLabel,
                    helperText: l10n.initialPaymentHelperText,
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
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
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              ElevatedButton(
                // Blocked while a line asks for more than the known balance
                // or points to an item that is no longer sellable.
                onPressed: (isLoading || blocked) ? null : _submit,
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