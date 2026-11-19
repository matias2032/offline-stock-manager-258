import '../core/database/local_database.dart';
import '../core/quantity_utils.dart';
import '../daos/catalog_item_dao.dart';
import '../daos/item_category_dao.dart';
import '../daos/stock_movement_dao.dart';
import '../daos/supplier_dao.dart';
import '../models/catalog_item_model.dart';
import '../models/item_category_model.dart';
import '../models/stock_movement_model.dart';
import 'expense_repository.dart';

/* Business logic for the catalog: categories, products and services.
Screens and providers must never talk to the DAOs directly.

Rules enforced here (and, where possible, by CHECKs in the schema):
 - item type is immutable after creation (stock movements depend on it);
 - a product needs a cost greater than zero (single cost, no optional one);
 - services have no cost, no stock and no category;
 - a category used by a product must belong to the same store;
 - a product is created with an optional initial quantity: an INITIAL
   movement plus an expense of quantity x cost, same transaction as the item;
 - a product with stock cannot be deleted (zero it first with an adjustment);
 - deleting a category detaches its items instead of deleting them. */
class CatalogRepository {
  CatalogRepository(
    this._database,
    this._categoryDao,
    this._itemDao,
    this._stockMovementDao,
    this._expenseRepository,
    this._supplierDao,
  );

  final LocalDatabase _database;
  final ItemCategoryDao _categoryDao;
  final CatalogItemDao _itemDao;
  final StockMovementDao _stockMovementDao;
  final ExpenseRepository _expenseRepository;
  final SupplierDao _supplierDao;

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

  /* [initialQuantityMilli] (products only) is the stock the product starts
  with. It is booked like a purchase: an INITIAL movement at the product cost
  plus an expense of quantity x cost (protected, like any stock expense), all
  in the same transaction as the item. [initialStockExpenseDescription]
  arrives already localized from the UI (stored in the language active at the
  time). [initialStockSupplierId] optionally links that expense to a supplier
  of the same store; it is ignored when there is no initial stock. */
  Future<CatalogItemModel> createItem({
    required int businessUnitId,
    required String itemType,
    required String name,
    String? description,
    int? categoryId,
    String unit = 'UN',
    required int salePriceCents,
    int costPriceCents = 0,
    int initialQuantityMilli = 0,
    String? initialStockExpenseDescription,
    int? initialStockSupplierId,
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
    if (initialQuantityMilli < 0) {
      throw ArgumentError('Initial quantity cannot be negative.');
    }

    final isProduct = itemType == CatalogItemModel.typeProduct;
    if (isProduct) {
      if (costPriceCents <= 0) {
        throw ArgumentError('Product cost must be greater than zero.');
      }
    } else {
      if (categoryId != null) {
        throw ArgumentError('Services cannot have a category.');
      }
      if (initialQuantityMilli > 0) {
        throw ArgumentError('Services have no stock.');
      }
    }
    await _assertCategoryUsable(categoryId, businessUnitId);

    // The initial stock becomes an expense: it needs a total > 0 and a text.
    var initialStockCents = 0;
    if (isProduct && initialQuantityMilli > 0) {
      initialStockCents = QuantityUtils.lineSubtotalCents(
        initialQuantityMilli,
        costPriceCents,
      );
      if (initialStockCents <= 0) {
        throw ArgumentError('Initial stock total must be greater than zero.');
      }
      if (_cleanOrNull(initialStockExpenseDescription) == null) {
        throw ArgumentError('Initial stock expense description is required.');
      }
    }

    final item = CatalogItemModel(
      businessUnitId: businessUnitId,
      itemType: itemType,
      name: cleanName,
      description: _cleanOrNull(description),
      categoryId: isProduct ? categoryId : null,
      unit: _cleanUnit(unit),
      salePriceCents: salePriceCents,
      costPriceCents: isProduct ? costPriceCents : 0,
      createdAt: DateTime.now(),
    );

    return _database.runInTransaction((txn) async {
      // Same rule as a purchase: the supplier must be live and from this store.
      final supplierId = (isProduct && initialQuantityMilli > 0)
          ? initialStockSupplierId
          : null;
      if (supplierId != null) {
        final supplier = await _supplierDao.getSupplierById(
          supplierId,
          txn: txn,
        );
        if (supplier == null ||
            supplier.deleted ||
            supplier.businessUnitId != businessUnitId) {
          throw StateError('Supplier not found in the active store.');
        }
      }

      final id = await _itemDao.insertItem(item, txn: txn);

      if (isProduct && initialQuantityMilli > 0) {
        final expense = await _expenseRepository.createExpense(
          businessUnitId: businessUnitId,
          supplierId: supplierId,
          description: _cleanOrNull(initialStockExpenseDescription)!,
          amountCents: initialStockCents,
          expenseDate: item.createdAt,
          txn: txn,
        );
        await _stockMovementDao.insertMovement(
          StockMovementModel(
            businessUnitId: businessUnitId,
            catalogItemId: id,
            movementType: StockMovementModel.typeInitial,
            quantityMilli: initialQuantityMilli,
            unitCostCents: costPriceCents,
            expenseId: expense.idExpense,
            createdAt: DateTime.now(),
          ),
          txn: txn,
        );
      }
      return item.copyWith(idCatalogItem: id);
    });
  }

  /* The item type is deliberately not editable, and stock is never touched
  here: it only moves through stock movements. */
  Future<CatalogItemModel> updateItem({
    required int idCatalogItem,
    required String name,
    String? description,
    int? categoryId,
    String unit = 'UN',
    required int salePriceCents,
    int costPriceCents = 0,
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
    if (existing.isProduct) {
      if (costPriceCents <= 0) {
        throw ArgumentError('Product cost must be greater than zero.');
      }
    } else if (categoryId != null) {
      throw ArgumentError('Services cannot have a category.');
    }
    await _assertCategoryUsable(categoryId, existing.businessUnitId);

    final updated = existing.copyWith(
      name: cleanName,
      description: _cleanOrNull(description),
      clearDescription: _cleanOrNull(description) == null,
      categoryId: categoryId,
      clearCategoryId: categoryId == null,
      unit: _cleanUnit(unit),
      salePriceCents: salePriceCents,
      costPriceCents: existing.isProduct ? costPriceCents : 0,
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

  /* A product that still has stock cannot be deleted: it would disappear
  from the stock list while holding units. Give them out (adjustment out or
  loss) first; meanwhile it can simply be set inactive. */
  Future<void> deleteItem(int idCatalogItem) async {
    final existing = await _itemDao.getItemById(idCatalogItem);
    if (existing == null) throw StateError('Item not found.');
    if (existing.deleted) return;

    if (existing.isProduct) {
      final balance = await _stockMovementDao.getBalance(idCatalogItem);
      if (balance > 0) {
        throw StateError(
          'Cannot delete a product that still has stock. '
          'Zero the stock first with an adjustment.',
        );
      }
    }
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