import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:mini/l10n/app_localizations.dart';

import '../../core/money_utils.dart';
import '../../core/quantity_utils.dart';
import '../../models/catalog_item_model.dart';
import '../../models/stock_movement_model.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/stock_provider.dart';
import '../../providers/user_provider.dart';
import '/widgets/stock_movement_sheet.dart';

/* Create/edit form for a PRODUCT. [row] is null when creating.
 - Create: name, category, price, cost (required), initial quantity (stock
   already on hand: INITIAL movement plus an expense of quantity x cost) and
   description.
 - Edit: same fields without the initial quantity, plus the "Active" switch
   and the "Move stock" button. Stock never moves from this form's Save:
   one save never does two things at once. */
class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({super.key, this.row});

  final StockBalanceRow? row;

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _unitController;
  late final TextEditingController _salePriceController;
  late final TextEditingController _costController;
  final _initialQuantityController = TextEditingController();

  int? _categoryId;
  bool _active = true;

  bool get _isEditing => widget.row != null;

  @override
  void initState() {
    super.initState();
    final item = widget.row?.item;
    _categoryId = item?.categoryId;
    _active = item?.active ?? true;

    _nameController = TextEditingController(text: item?.name ?? '');
    _descriptionController =
        TextEditingController(text: item?.description ?? '');
    _unitController = TextEditingController(text: item?.unit ?? 'UN');
    _salePriceController = TextEditingController(
      text: item != null ? MoneyUtils.toInputText(item.salePriceCents) : '',
    );
    _costController = TextEditingController(
      text: item != null && item.costPriceCents > 0
          ? MoneyUtils.toInputText(item.costPriceCents)
          : '',
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<CatalogProvider>();
      provider.clearError();
      if (provider.categories.isEmpty) provider.loadCatalog(keepFilters: true);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _unitController.dispose();
    _salePriceController.dispose();
    _costController.dispose();
    _initialQuantityController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context)!;
    final provider = context.read<CatalogProvider>();
    final salePrice = MoneyUtils.parseToCents(_salePriceController.text);
    final cost = MoneyUtils.parseToCents(_costController.text);

    final bool success;
    if (_isEditing) {
      final item = widget.row!.item;
      success = await provider.updateItem(
        idCatalogItem: item.idCatalogItem!,
        name: _nameController.text,
        description: _descriptionController.text,
        categoryId: _categoryId,
        unit: _unitController.text,
        salePriceCents: salePrice,
        costPriceCents: cost,
      );
      if (success && item.active != _active) {
        await provider.setItemActive(item.idCatalogItem!, _active);
      }
    } else {
      final initialMilli =
          QuantityUtils.parseToMilli(_initialQuantityController.text);
      success = await provider.createItem(
        itemType: CatalogItemModel.typeProduct,
        name: _nameController.text,
        description: _descriptionController.text,
        categoryId: _categoryId,
        unit: _unitController.text,
        salePriceCents: salePrice,
        costPriceCents: cost,
        initialQuantityMilli: initialMilli,
        // Same text as a purchase; stored in the language active right now.
        initialStockExpenseDescription: initialMilli > 0
            ? l10n.stockPurchaseExpenseDescription(
                QuantityUtils.format(initialMilli),
                _nameController.text.trim(),
              )
            : null,
      );
    }

    if (success && mounted) Navigator.of(context).pop();
  }

  Future<void> _moveStock(StockBalanceRow row) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final stock = context.read<StockProvider>();

    final saved = await showStockMovementSheet(context, row);
    if (saved != true || !mounted) return;

    /* An Entry updates the product cost in the database. Refresh the field
    only when the cost really changed, so a cost the user is typing during
    an Exit is not overwritten. */
    final fresh = stock.rowFor(row.item.idCatalogItem!);
    if (fresh != null &&
        fresh.item.costPriceCents > 0 &&
        fresh.item.costPriceCents != row.item.costPriceCents) {
      _costController.text = MoneyUtils.toInputText(fresh.item.costPriceCents);
    }
    messenger.showSnackBar(SnackBar(content: Text(l10n.stockMovementSaved)));
  }

  Future<void> _confirmDelete(StockBalanceRow row) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);

    // Same rule as the repository, only to show a message in the active
    // language. The repository still enforces it.
    if (row.balanceMilli > 0) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.cannotDeleteProductWithStockMessage)),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteCatalogItem),
        content: Text(l10n.confirmDeleteCatalogItemMessage(row.item.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final catalog = context.read<CatalogProvider>();
    final ok = await catalog.deleteItem(row.item.idCatalogItem!);
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
    } else if (catalog.errorMessage != null) {
      messenger.showSnackBar(SnackBar(content: Text(catalog.errorMessage!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<CatalogProvider>();
    final stock = context.watch<StockProvider>();
    final currency = context.watch<UserProvider>().user?.currency ?? 'MZN';
    final colorScheme = Theme.of(context).colorScheme;
    final categories = provider.categories;

    // Fresh balance (changes after each movement); falls back to the row
    // that opened the form.
    final row = widget.row == null
        ? null
        : (stock.rowFor(widget.row!.item.idCatalogItem!) ?? widget.row);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.editProduct : l10n.newProduct),
        actions: [
          if (row != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: l10n.delete,
              onPressed: () => _confirmDelete(row),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (row != null) ...[
              Text(
                row.isOutOfStock
                    ? l10n.outOfStockLabel
                    : l10n.stockAvailableLabel(
                        QuantityUtils.format(row.balanceMilli),
                        row.item.unit,
                      ),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: row.isLow ? colorScheme.error : null,
                    ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                icon: const Icon(Icons.sync_alt),
                label: Text(l10n.moveStockButton),
                onPressed: () => _moveStock(row),
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),
            ],
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: l10n.itemNameLabel),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? l10n.nameRequiredMessage
                  : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int?>(
              // New key when categories finish loading, so the initial
              // value is re-evaluated against the loaded list.
              key: ValueKey('category-${categories.length}'),
              initialValue:
                  categories.any((c) => c.idItemCategory == _categoryId)
                      ? _categoryId
                      : null,
              decoration: InputDecoration(labelText: l10n.categoryLabel),
              items: [
                DropdownMenuItem<int?>(
                  value: null,
                  child: Text(l10n.noCategoryLabel),
                ),
                ...categories.map(
                  (c) => DropdownMenuItem<int?>(
                    value: c.idItemCategory,
                    child: Text(c.name),
                  ),
                ),
              ],
              onChanged: (value) => setState(() => _categoryId = value),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _salePriceController,
                    decoration: InputDecoration(
                      labelText: '${l10n.salePriceLabel} ($currency)',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) =>
                        MoneyUtils.parseToCents(value ?? '') <= 0
                            ? l10n.enterValidAmountMessage
                            : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _unitController,
                    decoration: InputDecoration(labelText: l10n.unitLabel),
                    textCapitalization: TextCapitalization.characters,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _costController,
              decoration: InputDecoration(
                labelText: '${l10n.costPriceLabel} ($currency)',
                helperText: l10n.costPriceHelperText,
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (value) => MoneyUtils.parseToCents(value ?? '') <= 0
                  ? l10n.enterValidAmountMessage
                  : null,
            ),
            if (!_isEditing) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _initialQuantityController,
                decoration: InputDecoration(
                  labelText: l10n.initialQuantityLabel,
                  helperText: l10n.initialQuantityHelperText,
                  helperMaxLines: 3,
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                // Empty (or 0) means "no stock yet": no movement or expense.
                validator: (value) {
                  final text = (value ?? '').trim();
                  if (text.isEmpty) return null;
                  final milli = QuantityUtils.tryParseToMilli(text);
                  if (milli == null) return l10n.enterValidQuantityMessage;

                  // It becomes an expense (quantity x cost): the total
                  // cannot round to zero.
                  final cost = MoneyUtils.parseToCents(_costController.text);
                  if (milli > 0 &&
                      cost > 0 &&
                      QuantityUtils.lineSubtotalCents(milli, cost) <= 0) {
                    return l10n.enterValidAmountMessage;
                  }
                  return null;
                },
              ),
            ],
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration:
                  InputDecoration(labelText: l10n.descriptionOptionalLabel),
              maxLines: 3,
            ),
            if (_isEditing)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.activeLabel),
                value: _active,
                onChanged: (value) => setState(() => _active = value),
              ),
            const SizedBox(height: 16),
            if (provider.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  provider.errorMessage!,
                  style: TextStyle(color: colorScheme.error),
                ),
              ),
            ElevatedButton(
              onPressed: provider.isLoading ? null : _submit,
              child: provider.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_isEditing ? l10n.saveLabel : l10n.createProduct),
            ),
          ],
        ),
      ),
    );
  }
}