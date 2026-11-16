import '../core/database/local_database.dart';
import '../daos/catalog_item_dao.dart';
import '../daos/item_category_dao.dart';
import '../daos/stock_movement_dao.dart';
import '../models/catalog_item_model.dart';
import '../models/item_category_model.dart';

/* Business logic for the catalog: categories, products and services.
Screens and providers must never talk to the DAOs directly.

Rules enforced here (not in the DB layer):
 - services never track stock;
 - item type is immutable after creation (stock movements depend on it);
 - a category used by an item must belong to the same store;
 - deleting a category detaches its items instead of deleting them. */
class CatalogRepository {
  CatalogRepository(
    this._database,
    this._categoryDao,
    this._itemDao,
    this._stockMovementDao,
  );

  final LocalDatabase _database;
  final ItemCategoryDao _categoryDao;
  final CatalogItemDao _itemDao;
  final StockMovementDao _stockMovementDao;

  // categories

  Future<List<ItemCategoryModel>> getAllCategories({
    required int businessUnitId,
  }) {
    return _categoryDao.getAllCategories(businessUnitId: businessUnitId);
  }

  Future<ItemCategoryModel> createCategory({
    required int businessUnitId,
    required String name,
  }) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty) {
      throw ArgumentError('Category name cannot be empty.');
    }
    if (await _categoryDao.nameExists(
      businessUnitId: businessUnitId,
      name: cleanName,
    )) {
      throw ArgumentError('A category with this name already exists.');
    }

    final category = ItemCategoryModel(
      businessUnitId: businessUnitId,
      name: cleanName,
      createdAt: DateTime.now(),
    );
    final id = await _categoryDao.insertCategory(category);
    return category.copyWith(idItemCategory: id);
  }

  Future<ItemCategoryModel> renameCategory({
    required int idItemCategory,
    required String name,
  }) async {
    final existing = await _categoryDao.getCategoryById(idItemCategory);
    if (existing == null || existing.deleted) {
      throw StateError('Category not found.');
    }
    final cleanName = name.trim();
    if (cleanName.isEmpty) {
      throw ArgumentError('Category name cannot be empty.');
    }
    if (await _categoryDao.nameExists(
      businessUnitId: existing.businessUnitId,
      name: cleanName,
      excludeId: idItemCategory,
    )) {
      throw ArgumentError('A category with this name already exists.');
    }

    final updated = existing.copyWith(name: cleanName);
    await _categoryDao.updateCategory(updated);
    return updated;
  }

  Future<void> deleteCategory(int idItemCategory) async {
    final existing = await _categoryDao.getCategoryById(idItemCategory);
    if (existing == null) throw StateError('Category not found.');
    if (existing.deleted) return;

    await _database.runInTransaction((txn) async {
      await _itemDao.clearCategory(idItemCategory, txn: txn);
      await _categoryDao.softDeleteCategory(idItemCategory, txn: txn);
    });
  }

  // items

  Future<List<CatalogItemModel>> getAllItems({
    required int businessUnitId,
    String? itemType,
    int? categoryId,
    String? search,
    bool onlyActive = false,
  }) {
    return _itemDao.getAllItems(
      businessUnitId: businessUnitId,
      itemType: itemType,
      categoryId: categoryId,
      search: search,
      onlyActive: onlyActive,
    );
  }

  Future<CatalogItemModel?> getItemById(int idCatalogItem) {
    return _itemDao.getItemById(idCatalogItem);
  }

  Future<CatalogItemModel> createItem({
    required int businessUnitId,
    required String itemType,
    required String name,
    String? code,
    String? description,
    int? categoryId,
    String unit = 'UN',
    required int salePriceCents,
    int costPriceCents = 0,
    bool trackStock = false,
    int minStockMilli = 0,
  }) async {
    if (itemType != CatalogItemModel.typeProduct &&
        itemType != CatalogItemModel.typeService) {
      throw ArgumentError('Invalid item type.');
    }
    final cleanName = name.trim();
    if (cleanName.isEmpty) {
      throw ArgumentError('Item name cannot be empty.');
    }
    if (salePriceCents <= 0) {
      throw ArgumentError('Sale price must be greater than zero.');
    }
    if (costPriceCents < 0) {
      throw ArgumentError('Cost price cannot be negative.');
    }
    if (minStockMilli < 0) {
      throw ArgumentError('Minimum stock cannot be negative.');
    }

    final isProduct = itemType == CatalogItemModel.typeProduct;
    final cleanCode = _cleanOrNull(code);

    if (cleanCode != null &&
        await _itemDao.codeExists(
          businessUnitId: businessUnitId,
          code: cleanCode,
        )) {
      throw ArgumentError('An item with this code already exists.');
    }
    await _assertCategoryUsable(categoryId, businessUnitId);

    final item = CatalogItemModel(
      businessUnitId: businessUnitId,
      itemType: itemType,
      code: cleanCode,
      name: cleanName,
      description: _cleanOrNull(description),
      categoryId: categoryId,
      unit: _cleanUnit(unit),
      salePriceCents: salePriceCents,
      costPriceCents: costPriceCents,
      // Services never track stock (also enforced by a CHECK in the schema).
      trackStock: isProduct && trackStock,
      minStockMilli: isProduct && trackStock ? minStockMilli : 0,
      createdAt: DateTime.now(),
    );

    final id = await _itemDao.insertItem(item);
    return item.copyWith(idCatalogItem: id);
  }

  /* The item type is deliberately not editable. */
  Future<CatalogItemModel> updateItem({
    required int idCatalogItem,
    required String name,
    String? code,
    String? description,
    int? categoryId,
    String unit = 'UN',
    required int salePriceCents,
    int costPriceCents = 0,
    bool trackStock = false,
    int minStockMilli = 0,
  }) async {
    final existing = await _itemDao.getItemById(idCatalogItem);
    if (existing == null) throw StateError('Item not found.');
    if (existing.deleted) throw StateError('Cannot update a deleted item.');

    final cleanName = name.trim();
    if (cleanName.isEmpty) {
      throw ArgumentError('Item name cannot be empty.');
    }
    if (salePriceCents <= 0) {
      throw ArgumentError('Sale price must be greater than zero.');
    }
    if (costPriceCents < 0) {
      throw ArgumentError('Cost price cannot be negative.');
    }
    if (minStockMilli < 0) {
      throw ArgumentError('Minimum stock cannot be negative.');
    }

    final cleanCode = _cleanOrNull(code);
    if (cleanCode != null &&
        await _itemDao.codeExists(
          businessUnitId: existing.businessUnitId,
          code: cleanCode,
          excludeId: idCatalogItem,
        )) {
      throw ArgumentError('An item with this code already exists.');
    }
    await _assertCategoryUsable(categoryId, existing.businessUnitId);

    final effectiveTrack = existing.isProduct && trackStock;

    /* Turning tracking off while stock remains would hide that stock from
    the stock list. Zero it with an adjustment first. */
    if (existing.trackStock && !effectiveTrack) {
      final balance = await _stockMovementDao.getBalance(idCatalogItem);
      if (balance > 0) {
        throw StateError(
          'Cannot turn off stock tracking while the item still has stock.',
        );
      }
    }

    final updated = existing.copyWith(
      name: cleanName,
      code: cleanCode,
      clearCode: cleanCode == null,
      description: _cleanOrNull(description),
      clearDescription: _cleanOrNull(description) == null,
      categoryId: categoryId,
      clearCategoryId: categoryId == null,
      unit: _cleanUnit(unit),
      salePriceCents: salePriceCents,
      costPriceCents: costPriceCents,
      trackStock: effectiveTrack,
      minStockMilli: effectiveTrack ? minStockMilli : 0,
    );

    await _itemDao.updateItem(updated);
    return updated;
  }

  Future<void> setItemActive(int idCatalogItem, bool active) async {
    final existing = await _itemDao.getItemById(idCatalogItem);
    if (existing == null) throw StateError('Item not found.');
    if (existing.deleted) throw StateError('Cannot change a deleted item.');
    await _itemDao.setActive(idCatalogItem, active);
  }

  Future<void> deleteItem(int idCatalogItem) async {
    final existing = await _itemDao.getItemById(idCatalogItem);
    if (existing == null) throw StateError('Item not found.');
    if (existing.deleted) return;
    await _itemDao.softDeleteItem(idCatalogItem);
  }

  // helpers

  Future<void> _assertCategoryUsable(int? categoryId, int businessUnitId) async {
    if (categoryId == null) return;
    final category = await _categoryDao.getCategoryById(categoryId);
    if (category == null ||
        category.deleted ||
        category.businessUnitId != businessUnitId) {
      throw ArgumentError('Invalid category for this store.');
    }
  }

  String _cleanUnit(String unit) {
    final trimmed = unit.trim();
    return trimmed.isEmpty ? 'UN' : trimmed.toUpperCase();
  }

  String? _cleanOrNull(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}