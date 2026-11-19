import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:mini/l10n/app_localizations.dart';

import '../../core/money_utils.dart';
import '../../models/sale_model.dart';
import '../../providers/business_unit_provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/sale_provider.dart';
import '../../providers/user_provider.dart';
import '/widgets/sale_item_lines.dart';
import '/widgets/text_input_dialog.dart';
/* The single detail screen of a sale (NORMAL or CREDIT). Shows header,
lines (if any), totals and payment history. The payment form and the cancel
action appear only for a CREDIT sale that is still open.

A sale without lines (leftover from the old free sale) just shows its
description and totals. The screen belongs to one store: it closes itself if
the active store changes. Not named route => never restored on app resume. */
class SaleDetailScreen extends StatefulWidget {
  const SaleDetailScreen({super.key, required this.saleId});

  final int saleId;

  @override
  State<SaleDetailScreen> createState() => _SaleDetailScreenState();
}

class _SaleDetailScreenState extends State<SaleDetailScreen> {
  final _paymentFormKey = GlobalKey<FormState>();
  final _paymentAmountController = TextEditingController();
  final _paymentNotesController = TextEditingController();
  String _paymentMethod = 'CASH';

  late final BusinessUnitProvider _unitProvider;
  late final int? _initialUnitId;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _unitProvider = context.read<BusinessUnitProvider>();
    _initialUnitId = _unitProvider.activeBusinessUnit?.idBusinessUnit;
    _unitProvider.addListener(_onUnitChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final saleProvider = context.read<SaleProvider>();
      context.read<CustomerProvider>().loadCustomers();
      saleProvider.loadOutstandingCreditCount();
      await saleProvider.loadSaleDetail(widget.saleId);
      if (mounted) setState(() => _loaded = true);
    });
  }

  @override
  void dispose() {
    _unitProvider.removeListener(_onUnitChanged);
    _paymentAmountController.dispose();
    _paymentNotesController.dispose();
    super.dispose();
  }

  void _onUnitChanged() {
    final current = _unitProvider.activeBusinessUnit?.idBusinessUnit;
    if (current != _initialUnitId && mounted) {
      Navigator.of(context).pop();
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

  Future<void> _submitPayment(int remainingCents) async {
    if (!_paymentFormKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context)!;
    final amountCents = MoneyUtils.parseToCents(_paymentAmountController.text);
    if (amountCents <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.enterValidPaymentAmount)),
      );
      return;
    }
    if (amountCents > remainingCents) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.paymentExceedsRemainingDebt)),
      );
      return;
    }

    final notes = _paymentNotesController.text.trim();
    final success = await context.read<SaleProvider>().registerPayment(
          saleId: widget.saleId,
          paidAmountCents: amountCents,
          paymentMethod: _paymentMethod,
          notes: notes.isEmpty ? null : notes,
        );

    if (!mounted) return;

    if (success) {
      _paymentAmountController.clear();
      _paymentNotesController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.paymentRegistered)),
      );
    } else {
      final error = context.read<SaleProvider>().errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? l10n.couldNotRegisterPayment)),
      );
    }
  }

  Future<void> _confirmCancel() async {
    final l10n = AppLocalizations.of(context)!;
    final reason = await showTextInputDialog(
      context,
      title: l10n.cancelSale,
      label: l10n.cancellationReasonLabel,
      confirmLabel: l10n.cancelSaleButton,
      cancelLabel: l10n.back,
    );
    if (reason == null || !mounted) return;

    final success = await context.read<SaleProvider>().cancelSale(
          saleId: widget.saleId,
          cancellationReason: reason,
        );
    if (!success && mounted) {
      final error = context.read<SaleProvider>().errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? l10n.couldNotCancelSale)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<SaleProvider>();
    final sale = provider.currentSale;
    final currency = context.watch<UserProvider>().user?.currency ?? 'MZN';
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    if (!_loaded || sale == null || sale.idSale != widget.saleId) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.saleDetailTitle)),
        body: (!_loaded || provider.isLoading)
            ? const Center(child: CircularProgressIndicator())
            : Center(child: Text(l10n.saleNotFound)),
      );
    }

    final saleItems = provider.saleItems;
    final payments = provider.payments;
    final remainingCents = sale.totalAmountCents - sale.paidAmountCents;
    final isOpenCredit = sale.isCredit &&
        (sale.saleStatus == 'OPEN' || sale.saleStatus == 'OUTSTANDING');

    return Scaffold(
      appBar: AppBar(
        title: Text(sale.reference),
        actions: [
          if (isOpenCredit)
            IconButton(
              icon: const Icon(Icons.cancel_outlined),
              tooltip: l10n.cancelSale,
              onPressed: _confirmCancel,
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _customerName(sale),
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(sale.description),
                  const SizedBox(height: 12),
                  _InfoRow(
                    label: l10n.typeLabel,
                    value: sale.isCredit ? l10n.creditLabel : l10n.immediateLabel,
                  ),
                  _InfoRow(label: l10n.statusLabel, value: sale.saleStatus),
                  if (sale.isCredit)
                    _InfoRow(
                      label: l10n.paymentStatusLabel,
                      value: sale.paymentStatus,
                    ),
                  _InfoRow(
                    label: l10n.dateColumnLabel,
                    value: dateFormat.format(sale.saleDate.toLocal()),
                  ),
                  if (sale.creditDueDate != null)
                    _InfoRow(
                      label: l10n.dueDateLabel,
                      value: '${sale.creditDueDate!.toLocal()}'.split(' ').first,
                    ),
                  if (sale.cancellationReason != null)
                    _InfoRow(
                      label: l10n.cancellationReasonLabel,
                      value: sale.cancellationReason!,
                    ),
                  if (sale.notes != null)
                    _InfoRow(label: l10n.notesLabel, value: sale.notes!),
                  const Divider(height: 24),
                  _InfoRow(
                    label: l10n.totalLabel,
                    value:
                        '${MoneyUtils.format(sale.totalAmountCents)} $currency',
                  ),
                  if (sale.isCredit) ...[
                    _InfoRow(
                      label: l10n.paidSoFarLabel,
                      value:
                          '${MoneyUtils.format(sale.paidAmountCents)} $currency',
                    ),
                    _InfoRow(
                      label: l10n.remainingDebtLabel,
                      value: '${MoneyUtils.format(remainingCents)} $currency',
                      valueColor:
                          remainingCents > 0 ? Colors.red : Colors.green,
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (saleItems.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SaleItemLines(
                  title: l10n.saleItemsTitle,
                  items: saleItems,
                  currency: currency,
                ),
              ),
            ),
          ],
          if (isOpenCredit) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _paymentFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.registerPayment,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _paymentAmountController,
                        decoration:
                            InputDecoration(labelText: l10n.amountFieldLabel),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        validator: (value) =>
                            MoneyUtils.parseToCents(value ?? '') <= 0
                                ? l10n.enterValidAmount
                                : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _paymentMethod,
                        decoration: InputDecoration(
                            labelText: l10n.paymentMethodLabel),
                        items: [
                          DropdownMenuItem(
                              value: 'CASH', child: Text(l10n.cashMethod)),
                          DropdownMenuItem(
                              value: 'BANK_TRANSFER',
                              child: Text(l10n.bankTransferMethod)),
                          DropdownMenuItem(
                              value: 'MPESA', child: Text(l10n.mpesaMethod)),
                          DropdownMenuItem(
                              value: 'EMOLA', child: Text(l10n.emolaMethod)),
                          DropdownMenuItem(
                              value: 'OTHER', child: Text(l10n.otherMethod)),
                        ],
                        onChanged: (value) =>
                            setState(() => _paymentMethod = value!),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _paymentNotesController,
                        decoration: InputDecoration(
                            labelText: l10n.notesOptionalLabel),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: provider.isLoading
                            ? null
                            : () => _submitPayment(remainingCents),
                        child: provider.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(l10n.registerPayment),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          if (sale.isCredit) ...[
            const SizedBox(height: 16),
            Text(l10n.paymentHistory,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (payments.isEmpty)
              Text(l10n.noPaymentsYet)
            else
              ...payments.map(
                (payment) => Card(
                  child: ListTile(
                    title: Text(
                      '${MoneyUtils.format(payment.paidAmountCents)} $currency'
                      ' • ${payment.paymentMethod}',
                    ),
                    subtitle:
                        Text(dateFormat.format(payment.paidAt.toLocal())),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(fontWeight: FontWeight.w600, color: valueColor),
            ),
          ),
        ],
      ),
    );
  }
}