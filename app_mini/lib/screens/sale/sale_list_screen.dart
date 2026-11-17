import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/sale_model.dart';
import '../../providers/customer_provider.dart';
import '../../providers/sale_provider.dart';
import '../../providers/user_provider.dart';
import 'sale_detail_screen.dart';
import '/widgets/app_sidebar.dart';
import 'package:mini/l10n/app_localizations.dart';

/*Lists finished sales only: every NORMAL sale (always COMPLETED), plus CREDIT sales once they're settled (COMPLETED or CANCELLED). 
Active credit sales live in CreditSaleListScreen instead. Each row shows the
generated description (names only, no quantities); tapping it opens the
sale detail screen.*/
class SaleListScreen extends StatefulWidget {
  const SaleListScreen({super.key});

  @override
  State<SaleListScreen> createState() => _SaleListScreenState();
}

class _SaleListScreenState extends State<SaleListScreen> {
  String? _saleTypeFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerProvider>().loadCustomers();
      context.read<SaleProvider>().loadOutstandingCreditCount();
      _applyFilters();
    });
  }

  void _applyFilters() {
    context.read<SaleProvider>().loadSales(
          saleType: _saleTypeFilter,
        );
  }

  Future<void> _openDetail(SaleModel sale) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SaleDetailScreen(saleId: sale.idSale!),
      ),
    );
    if (!mounted) return;
    context.read<SaleProvider>().loadOutstandingCreditCount();
    _applyFilters();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'COMPLETED':
        return Colors.green;
      case 'OUTSTANDING':
        return Colors.orange;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Theme.of(context).colorScheme.onSurfaceVariant;
    }
  }

  String _customerName(SaleModel sale) {
    final l10n = AppLocalizations.of(context)!;
    if (sale.walkInCustomerName != null) return sale.walkInCustomerName!;
    if (sale.customerId == null) return l10n.noCustomerLabel;
    final customers = context.read<CustomerProvider>().customers;
    for (final customer in customers) {
      if (customer.idCustomer == sale.customerId) return customer.name;
    }
    return l10n.customerNumberLabel(sale.customerId!);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final saleProvider = context.watch<SaleProvider>();
    final sales = saleProvider.sales;
    final isLoading = saleProvider.isLoading;
    final currency = context.watch<UserProvider>().user?.currency ?? 'MZN';
    final amountFormat = NumberFormat('#,##0.00');

    return Scaffold(
      appBar: AppBar(title: Text(l10n.finishedSalesTitle)),
      drawer: AppSidebar(
        currentRoute: '/sale',
        creditSalesBadgeCount: saleProvider.outstandingCreditCount,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: DropdownButtonFormField<String?>(
              initialValue: _saleTypeFilter,
              decoration: InputDecoration(labelText: l10n.typeLabel),
              items: [
                DropdownMenuItem<String?>(
                    value: null, child: Text(l10n.allLabel)),
                DropdownMenuItem<String?>(
                    value: 'NORMAL', child: Text(l10n.normalLabel)),
                DropdownMenuItem<String?>(
                    value: 'CREDIT', child: Text(l10n.creditLabel)),
              ],
              onChanged: (value) {
                setState(() => _saleTypeFilter = value);
                _applyFilters();
              },
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => _applyFilters(),
              child: isLoading && sales.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : sales.isEmpty
                      ? ListView(
                          children: [
                            const SizedBox(height: 120),
                            Center(child: Text(l10n.noFinishedSalesYet)),
                            const SizedBox(height: 16),
                            // Discoverability shortcut only; the list itself stays read-only.
                            Center(
                              child: FilledButton.icon(
                                onPressed: () => Navigator.of(context)
                                    .pushReplacementNamed('/sale/new'),
                                icon: const Icon(Icons.add),
                                label: Text(l10n.createSaleButton),
                              ),
                            ),
                          ],
                        )
                      : ListView.separated(
                          itemCount: sales.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final sale = sales[index];
                            final color = _statusColor(sale.saleStatus);
                            return ListTile(
                              title: Text(
                                  '${sale.reference} — ${sale.description}'),
                              subtitle: Text(
                                '${_customerName(sale)} • '
                                '${sale.isCredit ? l10n.creditLabel : l10n.immediateLabel}\n'
                                '${amountFormat.format(sale.totalAmountCents / 100)} $currency',
                              ),
                              isThreeLine: true,
                              trailing: Chip(
                                label: Text(sale.saleStatus),
                                backgroundColor: color.withOpacity(0.15),
                                labelStyle: TextStyle(color: color),
                              ),
                              onTap: () => _openDetail(sale),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }
}