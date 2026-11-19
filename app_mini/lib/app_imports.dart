/* Barrel file: re-exports every project file that main.dart wires together,
so main.dart needs a single project import instead of ~60.

Rules:
 - Import this ONLY from main.dart. Importing it from other files would hide
   real dependencies and can create circular imports.
 - Only project files are exported here. Third-party packages (flutter,
   provider, sqflite...) stay imported where they are used.
 - Ordered by dependency layer: infra -> daos -> repositories -> providers
   -> screens. */

// Infra, theme and localization
export 'core/database/local_database.dart';
export 'core/app_route_observer.dart';
export 'theme/app_theme.dart';
export 'package:mini/l10n/app_localizations.dart';

// DAOs
export 'daos/user_dao.dart';
export 'daos/business_unit_dao.dart';
export 'daos/customer_dao.dart';
export 'daos/supplier_dao.dart';
export 'daos/expense_dao.dart';
export 'daos/sale_dao.dart';
export 'daos/sale_item_dao.dart';
export 'daos/financial_statement_dao.dart';
export 'daos/item_category_dao.dart';
export 'daos/catalog_item_dao.dart';
export 'daos/stock_movement_dao.dart';

// Repositories
export 'repositories/business_unit_repository.dart';
export 'repositories/user_repository.dart';
export 'repositories/customer_repository.dart';
export 'repositories/supplier_repository.dart';
export 'repositories/expense_repository.dart';
export 'repositories/sale_repository.dart';
export 'repositories/financial_statement_repository.dart';
export 'repositories/catalog_repository.dart';
export 'repositories/stock_repository.dart';
export 'repositories/report_repository.dart';

// Providers
export 'providers/theme_provider.dart';
export 'providers/locale_provider.dart';
export 'providers/user_provider.dart';
export 'providers/business_unit_provider.dart';
export 'providers/dashboard_provider.dart';
export 'providers/customer_provider.dart';
export 'providers/supplier_provider.dart';
export 'providers/expense_provider.dart';
export 'providers/sale_provider.dart';
export 'providers/financial_statement_provider.dart';
export 'providers/catalog_provider.dart';
export 'providers/stock_provider.dart';
export 'providers/report_provider.dart';

// Screens
export 'screens/splash/splash_screen.dart';
export 'screens/user/activation_screen.dart';
export 'screens/user/welcome_screen.dart';
export 'screens/user/onboarding_screen.dart';
export 'screens/user/login_screen.dart';
export 'screens/user/edit_profile_screen.dart';
export 'screens/user/change_password_screen.dart';
export 'screens/dashboard/dashboard_screen.dart';
export 'screens/customer/customer_list_screen.dart';
export 'screens/supplier/supplier_list_screen.dart';
export 'screens/expense/expense_list_screen.dart';
export 'screens/sale/sale_list_screen.dart';
export 'screens/sale/sale_form_screen.dart';
export 'screens/sale/credit_sale_list_screen.dart';
export 'screens/sale/financial_statement_list_screen.dart';
export 'screens/sale/financial_statement_generate_screen.dart';
export 'screens/sale/financial_statement_detail_screen.dart';
export 'screens/business_unit/business_unit_management_screen.dart';
export 'screens/settings/backup_screen.dart';
export 'screens/catalog/product_list_screen.dart';
export 'screens/catalog/service_list_screen.dart';
export 'screens/catalog/item_category_screen.dart';
export 'screens/stock/stock_list_screen.dart';
export 'screens/report/reports_screen.dart';