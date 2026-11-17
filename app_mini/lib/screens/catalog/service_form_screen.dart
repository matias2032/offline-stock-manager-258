import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mini/l10n/app_localizations.dart';

import '../../core/money_utils.dart';
import '../../models/catalog_item_model.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/user_provider.dart';

/* Create/edit form for a SERVICE: name, unit (hour, service...), price,
description and, when editing, the "Active" switch. No category, cost or
stock: the repository rejects them for services anyway. */
class ServiceFormScreen extends StatefulWidget {
  const ServiceFormScreen({super.key, this.item});

  final CatalogItemModel? item;

  @override
  State<ServiceFormScreen> createState() => _ServiceFormScreenState();
}

class _ServiceFormScreenState extends State<ServiceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _unitController;
  late final TextEditingController _salePriceController;

  bool _active = true;

  bool get _isEditing => widget.item != null;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _active = item?.active ?? true;

    _nameController = TextEditingController(text: item?.name ?? '');
    _descriptionController =
        TextEditingController(text: item?.description ?? '');
    // Empty unit is stored as "UN" by the repository.
    _unitController = TextEditingController(text: item?.unit ?? '');
    _salePriceController = TextEditingController(
      text: item != null ? MoneyUtils.toInputText(item.salePriceCents) : '',
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CatalogProvider>().clearError();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _unitController.dispose();
    _salePriceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<CatalogProvider>();
    final salePrice = MoneyUtils.parseToCents(_salePriceController.text);

    final bool success;
    if (_isEditing) {
      final item = widget.item!;
      success = await provider.updateItem(
        idCatalogItem: item.idCatalogItem!,
        name: _nameController.text,
        description: _descriptionController.text,
        unit: _unitController.text,
        salePriceCents: salePrice,
      );
      if (success && item.active != _active) {
        await provider.setItemActive(item.idCatalogItem!, _active);
      }
    } else {
      success = await provider.createItem(
        itemType: CatalogItemModel.typeService,
        name: _nameController.text,
        description: _descriptionController.text,
        unit: _unitController.text,
        salePriceCents: salePrice,
      );
    }

    if (success && mounted) Navigator.of(context).pop();
  }

  Future<void> _confirmDelete(CatalogItemModel item) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteCatalogItem),
        content: Text(l10n.confirmDeleteCatalogItemMessage(item.name)),
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

    final provider = context.read<CatalogProvider>();
    final ok = await provider.deleteItem(item.idCatalogItem!);
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
    } else if (provider.errorMessage != null) {
      messenger.showSnackBar(SnackBar(content: Text(provider.errorMessage!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<CatalogProvider>();
    final currency = context.watch<UserProvider>().user?.currency ?? 'MZN';
    final item = widget.item;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.editService : l10n.newService),
        actions: [
          if (item != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: l10n.delete,
              onPressed: () => _confirmDelete(item),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: l10n.itemNameLabel),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? l10n.nameRequiredMessage
                  : null,
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
                    decoration: InputDecoration(
                      labelText: l10n.unitLabel,
                      helperText: l10n.serviceUnitHelperText,
                      helperMaxLines: 2,
                    ),
                    textCapitalization: TextCapitalization.characters,
                  ),
                ),
              ],
            ),
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
                  : Text(_isEditing ? l10n.saveLabel : l10n.createService),
            ),
          ],
        ),
      ),
    );
  }
}