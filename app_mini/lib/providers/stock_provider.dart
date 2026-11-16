import 'package:flutter/foundation.dart';

import '../models/stock_movement_model.dart';
import '../repositories/stock_repository.dart';
import 'business_unit_provider.dart';

/* Thin UI state holder for stock, scoped to the active business unit.
Zero business logic. After every write it reloads the balances (with the
same search) and the history of the item being viewed. */
class StockProvider extends ChangeNotifier {
  StockProvider(this._repository, this._businessUnitProvider) {
    _businessUnitProvider.addListener(_onActiveUnitChanged);
  }

  final StockRepository _repository;
  final BusinessUnitProvider _businessUnitProvider;

  List<StockBalanceRow> _rows = [];
  List<StockMovementModel> _movements = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _search = '';
  int? _historyItemId;

  List<StockBalanceRow> get rows => _rows;
  List<StockMovementModel> get movements => _movements;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get lowStockCount => _rows.where((r) => r.isLow).length;

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
    notifyListeners();
  }

  Future<void> loadBalances({String? search, bool keepFilters = false}) async {
    if (!keepFilters) _search = search ?? '';

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
      );
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMovements(int catalogItemId) async {
    _historyItemId = catalogItemId;
    try {
      _movements = await _repository.getMovements(catalogItemId);
    } catch (error) {
      _errorMessage = error.toString();
    }
    notifyListeners();
  }

  /// Runs [action], then refreshes balances and the open history. Returns success.
  Future<bool> _run(Future<void> Function(int unitId) action) async {
    final unitId = _activeUnitId;
    if (unitId == null) {
      _errorMessage = 'No active business unit selected.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await action(unitId);
      await loadBalances(keepFilters: true);
      final openItem = _historyItemId;
      if (openItem != null) await loadMovements(openItem);
      return true;
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

  Future<bool> registerInitialStock({
    required int catalogItemId,
    required int quantityMilli,
    int? unitCostCents,
    String? notes,
  }) =>
      _run(
        (unitId) => _repository.registerInitialStock(
          businessUnitId: unitId,
          catalogItemId: catalogItemId,
          quantityMilli: quantityMilli,
          unitCostCents: unitCostCents,
          notes: notes,
        ),
      );

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
    _historyItemId = null;
    _movements = [];
    loadBalances(keepFilters: true);
  }

  @override
  void dispose() {
    _businessUnitProvider.removeListener(_onActiveUnitChanged);
    super.dispose();
  }
}