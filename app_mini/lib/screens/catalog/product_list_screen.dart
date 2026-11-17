import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mini/l10n/app_localizations.dart';

import '../../core/money_utils.dart';
import '../../core/quantity_utils.dart';
import '../../models/catalog_item_model.dart';
import '../../models/stock_movement_model.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/sale_provider.dart';
import '../../providers/stock_provider.dart';
import '../../providers/user_provider.dart';
import '/widgets/app_sidebar.dart';
import 'product_form_screen.dart';

/* Products of the active store with price and quantity side by side. Data
comes from ONE query (StockProvider -> getBalances); the CatalogProvider only
supplies the category names. Red quantity at or below the fixed alert
threshold, "Out of stock" at zero. Deleted products are hidden here (they
only appear in Stock while they still hold units). Categories are reached
only from this screen. */
class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Fresh entry: filters reset.
      context.read<StockProvider>().loadBalances();
      context
          .read<CatalogProvider>()
          .loadCatalog(itemType: CatalogItemModel.typeProduct);
      context.read<SaleProvider>().loadOutstandingCreditCount();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _reload({bool keepCategory = true}) async {
    final stock = context.read<StockProvider>();
    final catalog = context.read<CatalogProvider>();
    final categoryId = keepCategory ? stock.categoryFilter : null;
    await catalog.loadCatalog(itemType: CatalogItemModel.typeProduct);
    await stock.loadBalances(
      search: _searchController.text,
      categoryId: categoryId,
    );
  }

  void _filterCategory(int? categoryId) {
    context.read<StockProvider>().loadBalances(
          search: _searchController.text,
          categoryId: categoryId,
        );
  }

  void _openForm({StockBalanceRow? row}) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => ProductFormScreen(row: row)))
        .then((_) {
      if (mounted) _reload();
    });
  }

  void _openCategories() {
    Navigator.of(context).pushNamed('/products/categories').then((_) {
      // The active category filter may have been deleted: drop it.
      if (mounted) _reload(keepCategory: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final stock = context.watch<StockProvider>();
    final catalog = context.watch<CatalogProvider>();
    final currency = context.watch<UserProvider>().user?.currency ?? 'MZN';
    final colorScheme = Theme.of(context).colorScheme;
    final rows = stock.rows.where((r) => !r.item.deleted).toList();
    final categories = catalog.categories;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.productsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.category_outlined),
            tooltip: l10n.productCategoriesTitle,
            onPressed: _openCategories,
          ),
        ],
      ),
      drawer: AppSidebar(
        currentRoute: '/products',
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
              onChanged: (value) =>
                  context.read<StockProvider>().loadBalances(
                        search: value,
                        categoryId: stock.categoryFilter,
                      ),
            ),
          ),
          if (categories.isNotEmpty)
            SizedBox(
              height: 52,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(l10n.allLabel),
                      selected: stock.categoryFilter == null,
                      onSelected: (_) => _filterCategory(null),
                    ),
                  ),
                  ...categories.map(
                    (c) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(c.name),
                        selected: stock.categoryFilter == c.idItemCategory,
                        onSelected: (_) => _filterCategory(c.idItemCategory),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _reload,
              child: stock.isLoading && stock.rows.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : rows.isEmpty
                      ? ListView(
                          children: [
                            const SizedBox(height: 120),
                            Center(child: Text(l10n.noProductsYet)),
                          ],
                        )
                      : ListView.separated(
                          itemCount: rows.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final row = rows[index];
                            final item = row.item;
                            final category =
                                catalog.categoryName(item.categoryId);
                            final parts = <String>[
                              if (category.isNotEmpty) category,
                              if (!item.active) l10n.inactiveLabel,
                            ];
                            return ListTile(
                              leading: Icon(
                                Icons.inventory_2_outlined,
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
                              subtitle: parts.isEmpty
                                  ? null
                                  : Text(parts.join(' • ')),
                              trailing: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${MoneyUtils.format(item.salePriceCents)} $currency',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    row.isOutOfStock
                                        ? l10n.outOfStockLabel
                                        : '${QuantityUtils.format(row.balanceMilli)} ${item.unit}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: row.isLow
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: row.isLow
                                          ? colorScheme.error
                                          : colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () => _openForm(row: row),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        tooltip: l10n.newProduct,
        child: const Icon(Icons.add),
      ),
    );
  }
}