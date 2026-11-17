import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mini/l10n/app_localizations.dart';

import '../../core/money_utils.dart';
import '../../models/catalog_item_model.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/sale_provider.dart';
import '../../providers/user_provider.dart';
import '/widgets/app_sidebar.dart';
import 'service_form_screen.dart';

/* Services of the active store: name, unit, price and an "Inactive" tag.
Services have no category, cost or stock. */
class ServiceListScreen extends StatefulWidget {
  const ServiceListScreen({super.key});

  @override
  State<ServiceListScreen> createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends State<ServiceListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reload();
      context.read<SaleProvider>().loadOutstandingCreditCount();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _reload() {
    return context.read<CatalogProvider>().loadCatalog(
          itemType: CatalogItemModel.typeService,
          search: _searchController.text,
        );
  }

  void _openForm({CatalogItemModel? item}) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => ServiceFormScreen(item: item)))
        .then((_) {
      if (mounted) _reload();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<CatalogProvider>();
    final currency = context.watch<UserProvider>().user?.currency ?? 'MZN';
    final colorScheme = Theme.of(context).colorScheme;
    final items = provider.items;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.servicesTitle)),
      drawer: AppSidebar(
        currentRoute: '/services',
        creditSalesBadgeCount:
            context.watch<SaleProvider>().outstandingCreditCount,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: l10n.searchLabel,
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (_) => _reload(),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _reload,
              child: provider.isLoading && items.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : items.isEmpty
                      ? ListView(
                          children: [
                            const SizedBox(height: 120),
                            Center(child: Text(l10n.noServicesYet)),
                          ],
                        )
                      : ListView.separated(
                          itemCount: items.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final item = items[index];
                            final parts = <String>[
                              item.unit,
                              if (!item.active) l10n.inactiveLabel,
                            ];
                            return ListTile(
                              leading: Icon(
                                Icons.handyman_outlined,
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
                              trailing: Text(
                                '${MoneyUtils.format(item.salePriceCents)} $currency',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
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
        tooltip: l10n.newService,
        child: const Icon(Icons.add),
      ),
    );
  }
}