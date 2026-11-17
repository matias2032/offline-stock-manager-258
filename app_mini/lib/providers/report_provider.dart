import 'package:flutter/foundation.dart';

import '../models/report_models.dart';
import '../models/sale_model.dart';
import '../repositories/report_repository.dart';
import 'business_unit_provider.dart';

/* Thin UI state holder for the reports, scoped to the active business unit.
Zero business logic. The stock report also feeds the dashboard summary card
(lowStockCount / stockValueCents). Margin and losses share one period. Each
report has a request counter: a response that arrives for an older request
(or a previous store) is discarded. */
class ReportProvider extends ChangeNotifier {
  ReportProvider(this._repository, this._businessUnitProvider) {
    _businessUnitProvider.addListener(_onActiveUnitChanged);
  }

  final ReportRepository _repository;
  final BusinessUnitProvider _businessUnitProvider;

  StockReport? _stockReport;
  MarginReport? _marginReport;
  LossReport? _lossReport;
  DashboardPeriod _period = DashboardPeriod.oneMonth;

  bool _isLoadingStock = false;
  bool _isLoadingMargin = false;
  bool _isLoadingLosses = false;
  bool _marginLoaded = false;
  bool _lossesLoaded = false;
  String? _errorMessage;

  int _stockRequest = 0;
  int _marginRequest = 0;
  int _lossRequest = 0;

  StockReport? get stockReport => _stockReport;
  MarginReport? get marginReport => _marginReport;
  LossReport? get lossReport => _lossReport;
  DashboardPeriod get period => _period;
  bool get isLoadingStock => _isLoadingStock;
  bool get isLoadingMargin => _isLoadingMargin;
  bool get isLoadingLosses => _isLoadingLosses;
  String? get errorMessage => _errorMessage;

  int get lowStockCount => _stockReport?.lowStockCount ?? 0;
  int get stockValueCents => _stockReport?.totalValueCents ?? 0;

  int? get _activeUnitId =>
      _businessUnitProvider.activeBusinessUnit?.idBusinessUnit;

  Future<void> loadStock() async {
    final request = ++_stockRequest;
    final unitId = _activeUnitId;
    if (unitId == null) {
      _stockReport = null;
      _isLoadingStock = false;
      notifyListeners();
      return;
    }

    _isLoadingStock = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final report = await _repository.getStockReport(businessUnitId: unitId);
      if (request != _stockRequest) return;
      _stockReport = report;
    } catch (error) {
      if (request != _stockRequest) return;
      _errorMessage = error.toString();
    } finally {
      if (request == _stockRequest) {
        _isLoadingStock = false;
        notifyListeners();
      }
    }
  }

  Future<void> loadMargin() async {
    _marginLoaded = true;
    final request = ++_marginRequest;
    final unitId = _activeUnitId;
    if (unitId == null) {
      _marginReport = null;
      _isLoadingMargin = false;
      notifyListeners();
      return;
    }

    _isLoadingMargin = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final report = await _repository.getMarginReport(
        businessUnitId: unitId,
        period: _period,
      );
      if (request != _marginRequest) return;
      _marginReport = report;
    } catch (error) {
      if (request != _marginRequest) return;
      _errorMessage = error.toString();
    } finally {
      if (request == _marginRequest) {
        _isLoadingMargin = false;
        notifyListeners();
      }
    }
  }

  Future<void> loadLosses() async {
    _lossesLoaded = true;
    final request = ++_lossRequest;
    final unitId = _activeUnitId;
    if (unitId == null) {
      _lossReport = null;
      _isLoadingLosses = false;
      notifyListeners();
      return;
    }

    _isLoadingLosses = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final report = await _repository.getLossReport(
        businessUnitId: unitId,
        period: _period,
      );
      if (request != _lossRequest) return;
      _lossReport = report;
    } catch (error) {
      if (request != _lossRequest) return;
      _errorMessage = error.toString();
    } finally {
      if (request == _lossRequest) {
        _isLoadingLosses = false;
        notifyListeners();
      }
    }
  }

  /// One period for margin and losses; reloads whichever was already loaded.
  Future<void> setPeriod(DashboardPeriod period) async {
    if (period == _period) return;
    _period = period;
    await Future.wait([
      if (_marginLoaded) loadMargin(),
      if (_lossesLoaded) loadLosses(),
    ]);
  }

  void _onActiveUnitChanged() {
    // Every report belongs to the previous store: drop it, then reload.
    _stockReport = null;
    _marginReport = null;
    _lossReport = null;
    loadStock();
    if (_marginLoaded) loadMargin();
    if (_lossesLoaded) loadLosses();
  }

  @override
  void dispose() {
    _businessUnitProvider.removeListener(_onActiveUnitChanged);
    super.dispose();
  }
}