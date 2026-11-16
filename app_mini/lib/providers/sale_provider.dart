import 'package:flutter/foundation.dart';
import '../models/sale_item_model.dart';
import '../models/sale_model.dart';
import '../repositories/sale_repository.dart';
import 'business_unit_provider.dart';

/* Thin UI state holder for the sale module (sale, sale_item, sale_installment,sale_payment). 
Zero business logic — only calls SaleRepository and
exposes loading/error/data for the UI. Listens to BusinessUnitProvider 
so switching the active business unit reloads every unit-scoped list 
automatically. */
class SaleProvider extends ChangeNotifier {
  SaleProvider(this._saleRepository, this._businessUnitProvider) {
    _businessUnitProvider.addListener(_onActiveUnitChanged);
  }

  final SaleRepository _saleRepository;
  final BusinessUnitProvider _businessUnitProvider;

  List<SaleModel> _sales = [];
  List<SaleModel> _creditSales = [];
  SaleModel? _currentSale;
  List<SaleInstallmentModel> _installments = [];
  List<SalePaymentModel> _payments = [];

  // Lines of the sales shown in the main list, keyed by sale id.
  Map<int, List<SaleItemModel>> _saleItemsBySale = {};

  // Lines of the sale open in the detail screen.
  List<SaleItemModel> _currentSaleItems = [];

  // Catalog items offered by the item picker (own loading flag, so the
  // sale form does not flicker while the user searches).
  List<SellableItem> _sellableItems = [];
  bool _isLoadingSellable = false;

  bool _isLoading = false;
  String? _errorMessage;

  // Remembers the last filters used in loadSales, so mutations (create,
  // cancel, payment) and store switches can refresh the list with the
  // same view active.
  int? _lastCustomerId;
  String? _lastSaleType;
  DateTime? _lastStartDate;
  DateTime? _lastEndDate;

  // Whether loadCreditSales was ever called — lets mutations decide
  // whether it's worth refreshing that list too. Filters for it are kept
  // separately since it's shown on its own screen.
  bool _creditSalesLoaded = false;
  int? _lastCreditCustomerId;
  DateTime? _lastCreditStartDate;
  DateTime? _lastCreditEndDate;

  // Remembers which sale's installments/payments are currently loaded, so
  // registerPayment/cancelSale can keep the detail screen in sync.
  int? _currentSaleId;

  // Count of not-yet-finalized credit sales — drives the sidebar badge.
  // Kept separate from _creditSales so any screen can trigger/read it
  // without paying for the full credit-sales list load.
  int _outstandingCreditCount = 0;

  List<SaleModel> get sales => _sales;
  List<SaleModel> get creditSales => _creditSales;
  SaleModel? get currentSale => _currentSale;
  List<SaleInstallmentModel> get installments => _installments;
  List<SalePaymentModel> get payments => _payments;
  List<SaleItemModel> get saleItems => _currentSaleItems;
  List<SellableItem> get sellableItems => _sellableItems;
  bool get isLoadingSellable => _isLoadingSellable;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get outstandingCreditCount => _outstandingCreditCount;

  /// Lines of a sale of the main list (empty for free sales).
  List<SaleItemModel> itemsFor(int saleId) =>
      _saleItemsBySale[saleId] ?? const [];

  int? get _activeUnitId => _businessUnitProvider.activeBusinessUnit?.idBusinessUnit;

/* Loads the main sales list: every NORMAL sale, plus CREDIT sales only
  once they're finalized (COMPLETED/CANCELLED). Active credit sales
  live in loadCreditSales instead. */
  Future<void> loadSales({
    int? customerId,
    String? saleType,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _lastCustomerId = customerId;
    _lastSaleType = saleType;
    _lastStartDate = startDate;
    _lastEndDate = endDate;

    final unitId = _activeUnitId;
    if (unitId == null) {
      _sales = [];
      _saleItemsBySale = {};
      notifyListeners();
      return;
    }

    _setLoading(true);
    try {
      _sales = await _saleRepository.getSalesForSalesList(
        businessUnitId: unitId,
        customerId: customerId,
        saleType: saleType,
        startDate: startDate,
        endDate: endDate,
      );
      _saleItemsBySale = await _saleRepository
          .getItemsForSales(_sales.map((s) => s.idSale!).toList());
      _errorMessage = null;
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _setLoading(false);
    }
  }

/* Loads the credit sales list screen: active (unpaid) credit sales only.
 Once a credit sale is fully paid or cancelled it disappears from here and shows up in loadSales instead. */

  Future<void> loadCreditSales({
    int? customerId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _creditSalesLoaded = true;
    _lastCreditCustomerId = customerId;
    _lastCreditStartDate = startDate;
    _lastCreditEndDate = endDate;

    final unitId = _activeUnitId;
    if (unitId == null) {
      _creditSales = [];
      notifyListeners();
      return;
    }

    _setLoading(true);
    try {
      _creditSales = await _saleRepository.getOutstandingCreditSales(
        businessUnitId: unitId,
        customerId: customerId,
        startDate: startDate,
        endDate: endDate,
      );
      _errorMessage = null;
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// Free sale: manual description and total, no lines.
  Future<bool> createSale({
    required String description,
    required int totalAmountCents,
    String saleType = 'NORMAL',
    int? customerId,
    String? walkInCustomerName,
    DateTime? creditDueDate,
    String? notes,
    // Optional down payment for a CREDIT sale; leave null/0 for no entry
    // (the full total starts out as outstanding debt).
    int? initialPaymentCents,
    String initialPaymentMethod = 'CASH',
  }) async {
    final unitId = _activeUnitId;
    if (unitId == null) {
      _errorMessage = 'No active business unit selected.';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    try {
      await _saleRepository.createSale(
        businessUnitId: unitId,
        description: description,
        totalAmountCents: totalAmountCents,
        saleType: saleType,
        customerId: customerId,
        walkInCustomerName: walkInCustomerName,
        creditDueDate: creditDueDate,
        notes: notes,
        initialPaymentCents: initialPaymentCents,
        initialPaymentMethod: initialPaymentMethod,
      );
      await _refreshSales();
      if (_creditSalesLoaded) await _refreshCreditSales();
      await loadOutstandingCreditCount();
      _errorMessage = null;
      return true;
    } catch (error) {
      _errorMessage = error.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Sale made of catalog lines; the total is computed by the repository.
  Future<bool> createSaleWithItems({
    required List<SaleLineInput> lines,
    String saleType = 'NORMAL',
    int? customerId,
    String? walkInCustomerName,
    DateTime? creditDueDate,
    String? notes,
    int? initialPaymentCents,
    String initialPaymentMethod = 'CASH',
  }) async {
    final unitId = _activeUnitId;
    if (unitId == null) {
      _errorMessage = 'No active business unit selected.';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    try {
      await _saleRepository.createSaleWithItems(
        businessUnitId: unitId,
        lines: lines,
        saleType: saleType,
        customerId: customerId,
        walkInCustomerName: walkInCustomerName,
        creditDueDate: creditDueDate,
        notes: notes,
        initialPaymentCents: initialPaymentCents,
        initialPaymentMethod: initialPaymentMethod,
      );
      await _refreshSales();
      if (_creditSalesLoaded) await _refreshCreditSales();
      await loadOutstandingCreditCount();
      _errorMessage = null;
      return true;
    } catch (error) {
      _errorMessage = error.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> cancelSale({
    required int saleId,
    required String cancellationReason,
  }) async {
    _setLoading(true);
    try {
      await _saleRepository.cancelSale(
        saleId: saleId,
        cancellationReason: cancellationReason,
      );
      await _refreshSales();
      if (_creditSalesLoaded) await _refreshCreditSales();
      if (_currentSaleId == saleId) {
        await _refreshSaleDetail(saleId);
      }
      _errorMessage = null;
      return true;
    } catch (error) {
      _errorMessage = error.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> registerPayment({
    required int saleId,
    required int paidAmountCents,
    String paymentMethod = 'CASH',
    String? notes,
  }) async {
    _setLoading(true);
    try {
      await _saleRepository.registerPayment(
        saleId: saleId,
        paidAmountCents: paidAmountCents,
        paymentMethod: paymentMethod,
        notes: notes,
      );
      await _refreshSales();
      if (_creditSalesLoaded) await _refreshCreditSales();
      if (_currentSaleId == saleId) {
        await _refreshSaleDetail(saleId);
      }
      _errorMessage = null;
      return true;
    } catch (error) {
      _errorMessage = error.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

/* Loads a sale's installments, payments and lines together — used by the
  sale detail screen. Subsequent registerPayment/cancelSale calls for
  this same saleId keep this data in sync automatically. */
  Future<void> loadSaleDetail(int saleId) async {
    _currentSaleId = saleId;
    _setLoading(true);
    try {
      await _refreshSaleDetail(saleId);
      _errorMessage = null;
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _setLoading(false);
    }
  }

  /* Loads the catalog items the item picker offers (active items of the
  store, tracked products with their balance). */
  Future<void> loadSellableItems({String? search}) async {
    final unitId = _activeUnitId;
    if (unitId == null) {
      _sellableItems = [];
      notifyListeners();
      return;
    }

    _isLoadingSellable = true;
    notifyListeners();
    try {
      _sellableItems = await _saleRepository.getSellableItems(
        businessUnitId: unitId,
        search: search,
      );
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoadingSellable = false;
      notifyListeners();
    }
  }

/* Refreshes the sidebar badge count. Best-effort: a failure here
  shouldn't surface as a page-level error, so it doesn't touch
  _errorMessage/_isLoading. No-op if there's no active store yet. */
  Future<void> loadOutstandingCreditCount() async {
    final unitId = _activeUnitId;
    if (unitId == null) {
      _outstandingCreditCount = 0;
      notifyListeners();
      return;
    }
    try {
      _outstandingCreditCount =
          await _saleRepository.countOutstandingCreditSales(businessUnitId: unitId);
      notifyListeners();
    } catch (_) {
      // Badge is non-critical; silently keep the last known value.
    }
  }


  Future<void> _refreshSales() async {
    final unitId = _activeUnitId;
    if (unitId == null) {
      _sales = [];
      _saleItemsBySale = {};
      return;
    }
    _sales = await _saleRepository.getSalesForSalesList(
      businessUnitId: unitId,
      customerId: _lastCustomerId,
      saleType: _lastSaleType,
      startDate: _lastStartDate,
      endDate: _lastEndDate,
    );
    _saleItemsBySale = await _saleRepository
        .getItemsForSales(_sales.map((s) => s.idSale!).toList());
  }

  Future<void> _refreshCreditSales() async {
    final unitId = _activeUnitId;
    if (unitId == null) {
      _creditSales = [];
      return;
    }
    _creditSales = await _saleRepository.getOutstandingCreditSales(
      businessUnitId: unitId,
      customerId: _lastCreditCustomerId,
      startDate: _lastCreditStartDate,
      endDate: _lastCreditEndDate,
    );
  }

  Future<void> _refreshSaleDetail(int saleId) async {
    _currentSale = await _saleRepository.getSaleById(saleId);
    _installments = await _saleRepository.getInstallmentsBySale(saleId);
    _payments = await _saleRepository.getPaymentsBySale(saleId);
    _currentSaleItems = await _saleRepository.getSaleItems(saleId);
  }

/* Standalone lookup of a sale's installments, independent from the
  loadSaleDetail/_currentSale flow. Meant to be called per-row from a
  FutureBuilder, so it never touches isLoading/errorMessage or detail-screen state. */
  Future<List<SaleInstallmentModel>> installmentsForSale(int saleId) {
    return _saleRepository.getInstallmentsBySale(saleId);
  }

/* Reloads every unit-scoped list/stat currently in use when the
  active business unit changes. Detail state (_currentSale, etc.) is
  intentionally left untouched. */
  void _onActiveUnitChanged() {
    loadSales(
      customerId: _lastCustomerId,
      saleType: _lastSaleType,
      startDate: _lastStartDate,
      endDate: _lastEndDate,
    );
    if (_creditSalesLoaded) {
      loadCreditSales(
        customerId: _lastCreditCustomerId,
        startDate: _lastCreditStartDate,
        endDate: _lastCreditEndDate,
      );
    }
    loadOutstandingCreditCount();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _businessUnitProvider.removeListener(_onActiveUnitChanged);
    super.dispose();
  }
}