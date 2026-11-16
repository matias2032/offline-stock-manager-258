import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mini/l10n/app_localizations.dart';

import '../../core/money_utils.dart';
import '../../models/catalog_item_model.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/sale_provider.dart';
import '../../providers/user_provider.dart';
import '/widgets/app_sidebar.dart';
import 'catalog_item_form_screen.dart';

/* Lists products and services of the active store, with a type filter and
a search box. Tapping an item opens the form; FAB creates a new one. */
class CatalogListScreen extends StatefulWidget {
  const CatalogListScreen({super.key});

  @override
  State<CatalogListScreen> createState() => _CatalogListScreenState();
}

class _CatalogListScreenState extends State<CatalogListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CatalogProvider>().loadCatalog();
      context.read<SaleProvider>().loadOutstandingCreditCount();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _reload({String? type, bool clearType = false}) {
    final provider = context.read<CatalogProvider>();
    provider.loadCatalog(
      itemType: clearType ? null : (type ?? provider.itemTypeFilter),
      categoryId: provider.categoryFilter,
      search: _searchController.text,
    );
  }

  void _openForm({CatalogItemModel? item}) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CatalogItemFormScreen(item: item)),
    );
  }

  Future<void> _confirmDelete(CatalogItemModel item) async {
    final l10n = AppLocalizations.of(context)!;
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
    if (confirmed == true && mounted) {
      await context.read<CatalogProvider>().deleteItem(item.idCatalogItem!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<CatalogProvider>();
    final currency = context.watch<UserProvider>().user?.currency ?? 'MZN';
    final items = provider.items;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.catalogTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.category_outlined),
            tooltip: l10n.categoriesLabel,
            onPressed: () => Navigator.of(context)
                .pushNamed('/catalog/categories')
                .then((_) {
              if (mounted) _reload();
            }),
          ),
        ],
      ),
      drawer: AppSidebar(
        currentRoute: '/catalog',
        creditSalesBadgeCount:
            context.watch<SaleProvider>().outstandingCreditCount,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: l10n.searchLabel,
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (_) => _reload(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: SegmentedButton<String?>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(value: null, label: Text(l10n.allLabel)),
                ButtonSegment(
                  value: CatalogItemModel.typeProduct,
                  label: Text(l10n.productLabel),
                ),
                ButtonSegment(
                  value: CatalogItemModel.typeService,
                  label: Text(l10n.serviceLabel),
                ),
              ],
              selected: {provider.itemTypeFilter},
              onSelectionChanged: (selection) => _reload(
                type: selection.first,
                clearType: selection.first == null,
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => _reload(),
              child: provider.isLoading && items.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : items.isEmpty
                      ? ListView(
                          children: [
                            const SizedBox(height: 120),
                            Center(child: Text(l10n.noCatalogItemsYet)),
                          ],
                        )
                      : ListView.separated(
                          itemCount: items.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final item = items[index];
                            final category =
                                provider.categoryName(item.categoryId);
                            final parts = <String>[
                              item.isProduct
                                  ? l10n.productLabel
                                  : l10n.serviceLabel,
                              if (item.code != null) item.code!,
                              if (category.isNotEmpty) category,
                              if (!item.active) l10n.inactiveLabel,
                            ];
                            return ListTile(
                              leading: Icon(
                                item.isProduct
                                    ? Icons.inventory_2_outlined
                                    : Icons.handyman_outlined,
                                color: item.active
                                    ? colorScheme.primary
                                    : colorScheme.outline,
                              ),
                              title: Text(
                                item.name,
                                style: TextStyle(
                                  color: item.active
                                      ? null
                                      : colorScheme.onSurfaceVariant,
                                ),
                              ),
                              subtitle: Text(parts.join(' • ')),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${MoneyUtils.format(item.salePriceCents)} $currency',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    onPressed: () => _confirmDelete(item),
                                  ),
                                ],
                              ),
                              onTap: () => _openForm(item: item),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        tooltip: l10n.newCatalogItem,
        child: const Icon(Icons.add),
      ),
    );
  }
}