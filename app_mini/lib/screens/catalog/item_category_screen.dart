import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mini/l10n/app_localizations.dart';

import '../../models/item_category_model.dart';
import '../../providers/catalog_provider.dart';
import '/widgets/text_input_dialog.dart';

/* Manages the PRODUCT categories of the active store: list, create, rename
and delete. Only reachable from the Products screen (AppBar icon), so it
keeps a back button instead of the sidebar. Services have no categories. */
class ItemCategoryScreen extends StatefulWidget {
  const ItemCategoryScreen({super.key});

  @override
  State<ItemCategoryScreen> createState() => _ItemCategoryScreenState();
}

class _ItemCategoryScreenState extends State<ItemCategoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<CatalogProvider>();
      provider.clearError();
      provider.loadCatalog(keepFilters: true);
    });
  }

  Future<void> _showNameDialog({ItemCategoryModel? category}) async {
    final l10n = AppLocalizations.of(context)!;
    final name = await showTextInputDialog(
      context,
      title: category == null ? l10n.newCategory : l10n.renameCategory,
      label: l10n.categoryNameLabel,
      initialText: category?.name ?? '',
      confirmLabel: l10n.saveLabel,
      cancelLabel: l10n.cancel,
      emptyMessage: l10n.nameRequiredMessage,
    );

    if (name == null || !mounted) return;
    final provider = context.read<CatalogProvider>();
    final success = category == null
        ? await provider.createCategory(name)
        : await provider.renameCategory(category.idItemCategory!, name);

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage ?? l10n.nameRequiredMessage)),
      );
    }
  }

  Future<void> _confirmDelete(ItemCategoryModel category) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteCategory),
        content: Text(l10n.confirmDeleteCategoryMessage(category.name)),
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
    if (confirmed == true && mounted) {
      await context
          .read<CatalogProvider>()
          .deleteCategory(category.idItemCategory!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<CatalogProvider>();
    final categories = provider.categories;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.productCategoriesTitle)),
      body: provider.isLoading && categories.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : categories.isEmpty
              ? Center(child: Text(l10n.noCategoriesYet))
              : ListView.separated(
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return ListTile(
                      leading: const Icon(Icons.label_outline),
                      title: Text(category.name),
                      onTap: () => _showNameDialog(category: category),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _confirmDelete(category),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNameDialog(),
        tooltip: l10n.newCategory,
        child: const Icon(Icons.add),
      ),
    );
  }
}