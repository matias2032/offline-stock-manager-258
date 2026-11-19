import 'package:flutter/foundation.dart';

import '../models/catalog_item_model.dart';
import '../models/item_category_model.dart';
import '../repositories/catalog_repository.dart';
import 'business_unit_provider.dart';

/* Thin UI state holder for the catalog (items + categories), scoped to the
active business unit. Zero business logic. Remembers the last filters so
mutations and store switches refresh the same view. */
class CatalogProvider extends ChangeNotifier {
  CatalogProvider(this._repository, this._businessUnitProvider) {
    _businessUnitProvider.addListener(_onActiveUnitChanged);
  }

  final CatalogRepository _repository;
  final BusinessUnitProvider _businessUnitProvider;

  List<CatalogItemModel> _items = [];
  List<ItemCategoryModel> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;

  String? _itemTypeFilter;
  int? _categoryFilter;
  String _search = '';

  List<CatalogItemModel> get items => _items;
  List<ItemCategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get itemTypeFilter => _itemTypeFilter;
  int? get categoryFilter => _categoryFilter;

  int? get _activeUnitId =>
      _businessUnitProvider.activeBusinessUnit?.idBusinessUnit;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String categoryName(int? categoryId) {
    if (categoryId == null) return '';
    for (final c in _categories) {
      if (c.idItemCategory == categoryId) return c.name;
    }
    return '';
  }

  Future<void> loadCatalog({
    String? itemType,
    int? categoryId,
    String? search,
    bool keepFilters = false,
  }) async {
    if (!keepFilters) {
      _itemTypeFilter = itemType;
      _categoryFilter = categoryId;
      _search = search ?? '';
    }

    final unitId = _activeUnitId;
    if (unitId == null) {
      _items = [];
      _categories = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _categories = await _repository.getAllCategories(businessUnitId: unitId);
      _items = await _repository.getAllItems(
        businessUnitId: unitId,
        itemType: _itemTypeFilter,
        categoryId: _categoryFilter,
        search: _search,
      );
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Runs [action], then reloads with the current filters. Returns success.
  Future<bool> _mutate(Future<void> Function(int unitId) action) async {
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
      await loadCatalog(keepFilters: true);
      return true;
    } catch (error) {
      _errorMessage = error.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // categories

  Future<bool> createCategory(String name) => _mutate(
        (unitId) => _repository.createCategory(
          businessUnitId: unitId,
          name: name,
        ),
      );

  Future<bool> renameCategory(int idItemCategory, String name) => _mutate(
        (_) => _repository.renameCategory(
          idItemCategory: idItemCategory,
          name: name,
        ),
      );

  Future<bool> deleteCategory(int idItemCategory) => _mutate((_) async {
        await _repository.deleteCategory(idItemCategory);
        if (_categoryFilter == idItemCategory) _categoryFilter = null;
      });

  // items

  Future<bool> createItem({
    required String itemType,
    required String name,
    String? description,
    int? categoryId,
    String unit = 'UN',
    required int salePriceCents,
    int costPriceCents = 0,    int initialQuantityMilli = 0,
    String? initialStockExpenseDescription,
    int? initialStockSupplierId,
  }) =>
      _mutate(
        (unitId) => _repository.createItem(
          businessUnitId: unitId,
          itemType: itemType,
          name: name,
          description: description,
          categoryId: categoryId,
          unit: unit,
          salePriceCents: salePriceCents,
          costPriceCents: costPriceCents,
          initialQuantityMilli: initialQuantityMilli,
          initialStockExpenseDescription: initialStockExpenseDescription,
          initialStockSupplierId: initialStockSupplierId,
        ),
      );

  Future<bool> updateItem({
    required int idCatalogItem,
    required String name,
    String? description,
    int? categoryId,
    String unit = 'UN',
    required int salePriceCents,
    int costPriceCents = 0,
  }) =>
      _mutate(
        (_) => _repository.updateItem(
          idCatalogItem: idCatalogItem,
          name: name,
          description: description,
          categoryId: categoryId,
          unit: unit,
          salePriceCents: salePriceCents,
          costPriceCents: costPriceCents,
        ),
      );

  Future<bool> setItemActive(int idCatalogItem, bool active) =>
      _mutate((_) => _repository.setItemActive(idCatalogItem, active));

  Future<bool> deleteItem(int idCatalogItem) =>
      _mutate((_) => _repository.deleteItem(idCatalogItem));

  void _onActiveUnitChanged() {
    // A category filter belongs to the previous store; drop it.
    _categoryFilter = null;
    loadCatalog(keepFilters: true);
  }

  @override
  void dispose() {
    _businessUnitProvider.removeListener(_onActiveUnitChanged);
    super.dispose();
  }
}