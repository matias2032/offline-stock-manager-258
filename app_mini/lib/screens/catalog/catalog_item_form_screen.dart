import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:mini/l10n/app_localizations.dart';

import '../../core/money_utils.dart';
import '../../core/quantity_utils.dart';
import '../../models/catalog_item_model.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/user_provider.dart';

/* Create/edit form for a product or service. The type is chosen only on
creation; when editing it is shown but locked. */
class CatalogItemFormScreen extends StatefulWidget {
  const CatalogItemFormScreen({super.key, this.item});

  final CatalogItemModel? item;

  @override
  State<CatalogItemFormScreen> createState() => _CatalogItemFormScreenState();
}

class _CatalogItemFormScreenState extends State<CatalogItemFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _codeController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _unitController;
  late final TextEditingController _salePriceController;
  late final TextEditingController _costPriceController;
  late final TextEditingController _minStockController;

  late String _itemType;
  int? _categoryId;
  bool _trackStock = false;
  bool _active = true;

  bool get _isEditing => widget.item != null;
  bool get _isProduct => _itemType == CatalogItemModel.typeProduct;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _itemType = item?.itemType ?? CatalogItemModel.typeProduct;
    _categoryId = item?.categoryId;
    _trackStock = item?.trackStock ?? false;
    _active = item?.active ?? true;

    _nameController = TextEditingController(text: item?.name ?? '');
    _codeController = TextEditingController(text: item?.code ?? '');
    _descriptionController =
        TextEditingController(text: item?.description ?? '');
    _unitController = TextEditingController(text: item?.unit ?? 'UN');
    _salePriceController = TextEditingController(
      text: item != null ? MoneyUtils.toInputText(item.salePriceCents) : '',
    );
    _costPriceController = TextEditingController(
      text: item != null && item.costPriceCents > 0
          ? MoneyUtils.toInputText(item.costPriceCents)
          : '',
    );
    _minStockController = TextEditingController(
      text: item != null && item.minStockMilli > 0
          ? QuantityUtils.toInputText(item.minStockMilli)
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
    _codeController.dispose();
    _descriptionController.dispose();
    _unitController.dispose();
    _salePriceController.dispose();
    _costPriceController.dispose();
    _minStockController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<CatalogProvider>();
    final salePrice = MoneyUtils.parseToCents(_salePriceController.text);
    final costPrice = MoneyUtils.parseToCents(_costPriceController.text);
    final minStockMilli = QuantityUtils.parseToMilli(_minStockController.text);
    final track = _isProduct && _trackStock;

    final bool success;
    if (_isEditing) {
      success = await provider.updateItem(
        idCatalogItem: widget.item!.idCatalogItem!,
        name: _nameController.text,
        code: _codeController.text,
        description: _descriptionController.text,
        categoryId: _categoryId,
        unit: _unitController.text,
        salePriceCents: salePrice,
        costPriceCents: costPrice,
        trackStock: track,
        minStockMilli: minStockMilli,
      );
      if (success && widget.item!.active != _active) {
        await provider.setItemActive(widget.item!.idCatalogItem!, _active);
      }
    } else {
      success = await provider.createItem(
        itemType: _itemType,
        name: _nameController.text,
        code: _codeController.text,
        description: _descriptionController.text,
        categoryId: _categoryId,
        unit: _unitController.text,
        salePriceCents: salePrice,
        costPriceCents: costPrice,
        trackStock: track,
        minStockMilli: minStockMilli,
      );
    }

    if (success && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<CatalogProvider>();
    final currency = context.watch<UserProvider>().user?.currency ?? 'MZN';
    final categories = provider.categories;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.editCatalogItem : l10n.newCatalogItem),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SegmentedButton<String>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: CatalogItemModel.typeProduct,
                  label: Text(l10n.productLabel),
                  icon: const Icon(Icons.inventory_2_outlined),
                ),
                ButtonSegment(
                  value: CatalogItemModel.typeService,
                  label: Text(l10n.serviceLabel),
                  icon: const Icon(Icons.handyman_outlined),
                ),
              ],
              selected: {_itemType},
              // Locked when editing: stock movements depend on the type.
              onSelectionChanged: _isEditing
                  ? null
                  : (selection) => setState(() {
                        _itemType = selection.first;
                        if (!_isProduct) _trackStock = false;
                      }),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: l10n.itemNameLabel),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? l10n.nameRequiredMessage
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _codeController,
              decoration: InputDecoration(labelText: l10n.itemCodeLabel),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int?>(
              value: categories.any((c) => c.idItemCategory == _categoryId)
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
            if (_isProduct) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _costPriceController,
                decoration: InputDecoration(
                  labelText: '${l10n.costPriceLabel} ($currency)',
                  helperText: l10n.costPriceHelperText,
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.trackStockLabel),
                subtitle: Text(l10n.trackStockHelperText),
                value: _trackStock,
                onChanged: (value) => setState(() => _trackStock = value),
              ),
              if (_trackStock)
                TextFormField(
                  controller: _minStockController,
                  decoration: InputDecoration(labelText: l10n.minStockLabel),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
                  // Empty means "no alert"; otherwise at most 3 decimals.
                  validator: (value) {
                    final text = (value ?? '').trim();
                    if (text.isEmpty) return null;
                    return QuantityUtils.tryParseToMilli(text) == null
                        ? l10n.enterValidQuantityMessage
                        : null;
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
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
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
                  : Text(_isEditing ? l10n.saveLabel : l10n.createCatalogItem),
            ),
          ],
        ),
      ),
    );
  }
}