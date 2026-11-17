import 'package:flutter/foundation.dart';

import '../core/insufficient_stock_exception.dart';
import '../models/stock_movement_model.dart';
import '../repositories/stock_repository.dart';
import 'business_unit_provider.dart';

/* Thin UI state holder for stock, scoped to the active business unit.
Zero business logic. After every write it reloads the balances (with the
same search). The movement history (read-only, paged, filtered) is loaded by
its own screen. */
class StockProvider extends ChangeNotifier {
  StockProvider(this._repository, this._businessUnitProvider) {
    _businessUnitProvider.addListener(_onActiveUnitChanged);
  }

  final StockRepository _repository;
  final BusinessUnitProvider _businessUnitProvider;

  List<StockBalanceRow> _rows = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _search = '';
  int? _categoryFilter;

  // Global movement history: paged and filtered by type and/or product.
  static const int _historyPageSize = 100;
  List<StockMovementRow> _history = [];
  List<StockBalanceRow> _historyProducts = [];
  bool _isLoadingHistory = false;
  bool _historyHasMore = false;
  String? _historyTypeFilter;
  int? _historyItemFilter;

  /// Incremented on every new history load; a response that arrives for an
  /// older request (or a previous store) is discarded.
  int _historyRequest = 0;
  /// Set when the last write failed for lack of stock (null otherwise), so
  /// the UI can show a localized message instead of [errorMessage].
  InsufficientStockException? _insufficientStock;

  List<StockBalanceRow> get rows => _rows;
  List<StockMovementRow> get history => _history;
  List<StockBalanceRow> get historyProducts => _historyProducts;
  bool get isLoadingHistory => _isLoadingHistory;
  bool get historyHasMore => _historyHasMore;
  String? get historyTypeFilter => _historyTypeFilter;
  int? get historyItemFilter => _historyItemFilter; 
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  InsufficientStockException? get insufficientStock => _insufficientStock;
  int get lowStockCount => _rows.where((r) => r.isLow).length;
  int? get categoryFilter => _categoryFilter;
  int? get _activeUnitId =>
      _businessUnitProvider.activeBusinessUnit?.idBusinessUnit;

  StockBalanceRow? rowFor(int catalogItemId) {
    for (final row in _rows) {
      if (row.item.idCatalogItem == catalogItemId) return row;
    }
    return null;
  }

  void clearError() {
    _errorMessage = null;
    _insufficientStock = null;
    notifyListeners();
  }

  Future<void> loadBalances({
    String? search,
    int? categoryId,
    bool keepFilters = false,
  }) async {
    if (!keepFilters) {
      _search = search ?? '';
      _categoryFilter = categoryId;
    }
    final unitId = _activeUnitId;
    if (unitId == null) {
      _rows = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _rows = await _repository.getBalances(
        businessUnitId: unitId,
        search: _search,
        categoryId: _categoryFilter,
      );
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// First page of the history with the given filters (a fresh entry resets
  /// them; [keepFilters] reloads with the current ones).
  Future<void> loadHistory({
    int? catalogItemId,
    String? movementType,
    bool keepFilters = false,
  }) async {
    if (!keepFilters) {
      _historyItemFilter = catalogItemId;
      _historyTypeFilter = movementType;
    }

    final unitId = _activeUnitId;
    if (unitId == null) {
      _history = [];
      _historyHasMore = false;
      notifyListeners();
      return;
    }

    final request = ++_historyRequest;
    _isLoadingHistory = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final page = await _repository.getHistory(
        businessUnitId: unitId,
        catalogItemId: _historyItemFilter,
        movementType: _historyTypeFilter,
        limit: _historyPageSize,
      );
      if (request != _historyRequest) return;
      _history = page;
      _historyHasMore = page.length == _historyPageSize;
    } catch (error) {
      if (request != _historyRequest) return;
      _errorMessage = error.toString();
    } finally {
      if (request == _historyRequest) {
        _isLoadingHistory = false;
        notifyListeners();
      }
    }
  }

  /// Next page, appended to the current list.
  Future<void> loadMoreHistory() async {
    final unitId = _activeUnitId;
    if (unitId == null || _isLoadingHistory || !_historyHasMore) return;

    final request = ++_historyRequest;
    _isLoadingHistory = true;
    notifyListeners();

    try {
      final page = await _repository.getHistory(
        businessUnitId: unitId,
        catalogItemId: _historyItemFilter,
        movementType: _historyTypeFilter,
        limit: _historyPageSize,
        offset: _history.length,
      );
      if (request != _historyRequest) return;
      _history = [..._history, ...page];
      _historyHasMore = page.length == _historyPageSize;
    } catch (error) {
      if (request != _historyRequest) return;
      _errorMessage = error.toString();
    } finally {
      if (request == _historyRequest) {
        _isLoadingHistory = false;
        notifyListeners();
      }
    }
  }

  /* Products offered by the history's product filter. Loaded separately from
  [rows] so the search/category filters of the stock list do not shrink it. */
  Future<void> loadHistoryProducts() async {
    final unitId = _activeUnitId;
    if (unitId == null) {
      _historyProducts = [];
      notifyListeners();
      return;
    }

    try {
      final products = await _repository.getBalances(businessUnitId: unitId);
      if (_activeUnitId != unitId) return; // store changed meanwhile
      _historyProducts = products;
    } catch (error) {
      _errorMessage = error.toString();
    }
    notifyListeners();
  }

  /// Runs [action], then refreshes balances. Returns success.
  Future<bool> _run(Future<void> Function(int unitId) action) async {
    final unitId = _activeUnitId;
    if (unitId == null) {
      _errorMessage = 'No active business unit selected.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    _insufficientStock = null;
    notifyListeners();

    try {
      await action(unitId);
      await loadBalances(keepFilters: true);
      return true;
    } on InsufficientStockException catch (error) {
      _insufficientStock = error;
      _errorMessage = error.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (error) {
      _errorMessage = error.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> registerPurchase({
    required int catalogItemId,
    required int quantityMilli,
    required int unitCostCents,
    int? supplierId,
    required DateTime purchaseDate,
    required String expenseDescription,
    String? notes,
  }) =>
      _run(
        (unitId) => _repository.registerPurchase(
          businessUnitId: unitId,
          catalogItemId: catalogItemId,
          quantityMilli: quantityMilli,
          unitCostCents: unitCostCents,
          supplierId: supplierId,
          purchaseDate: purchaseDate,
          expenseDescription: expenseDescription,
          notes: notes,
        ),
      );

//removed

  Future<bool> registerAdjustment({
    required int catalogItemId,
    required String movementType,
    required int quantityMilli,
    String? notes,
  }) =>
      _run(
        (unitId) => _repository.registerAdjustment(
          businessUnitId: unitId,
          catalogItemId: catalogItemId,
          movementType: movementType,
          quantityMilli: quantityMilli,
          notes: notes,
        ),
      );

  void _onActiveUnitChanged() {
    // Filters and history belong to the previous store.
    _historyRequest++; // discards any in-flight history load
    _isLoadingHistory = false;
    _history = [];
    _historyProducts = [];
    _historyHasMore = false;
    _historyItemFilter = null;
    _historyTypeFilter = null;
    _categoryFilter = null;
    loadBalances(keepFilters: true);
  }
  
  @override
  void dispose() {
    _businessUnitProvider.removeListener(_onActiveUnitChanged);
    super.dispose();
  }
}