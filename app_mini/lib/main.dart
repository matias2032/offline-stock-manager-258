//main.dart
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'app_imports.dart';

// Debug switch: set to true to wipe local database on every startup.
const bool _debugResetDatabaseOnStart = false;

// Single instance: MaterialApp can rebuild (theme/locale) without re-attaching a new observer.
final _resumeRouteObserver = ResumeRouteObserver();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding.instance.addObserver(ResumeLifecycleObserver());

  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  if (kDebugMode && _debugResetDatabaseOnStart) {
    debugPrint('🧨 Apagando BD SQLite local (business_manager.db)...');
    await LocalDatabase.instance.resetDatabase();
    debugPrint('✅ BD apagada. Será recriada no primeiro acesso.');
  }

  final localeProvider = LocaleProvider();
  await localeProvider.loadSavedLocale();

  runApp(MyApp(localeProvider: localeProvider));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.localeProvider});

  final LocaleProvider localeProvider;

  @override
  Widget build(BuildContext context) {
    final localDatabase = LocalDatabase.instance;
    final userDao = UserDao(localDatabase);

// Repositories and DAOs initialization.
// Order matters: a DAO/repository must be created before whoever uses it.
    final businessUnitDao = BusinessUnitDao();
    final businessUnitRepository = BusinessUnitRepository(dao: businessUnitDao);
    final userRepository = UserRepository(localDatabase, userDao, businessUnitRepository);

    final customerDao = CustomerDao(localDatabase);
    final customerRepository = CustomerRepository(localDatabase, customerDao);

    final supplierDao = SupplierDao(localDatabase);
    final supplierRepository = SupplierRepository(localDatabase, supplierDao);

    final expenseDao = ExpenseDao(localDatabase);
    final expenseRepository = ExpenseRepository(localDatabase, expenseDao);

    // Catalog and stock DAOs come before the sale repository, which uses them.
    final itemCategoryDao = ItemCategoryDao(localDatabase);
    final catalogItemDao = CatalogItemDao(localDatabase);
    final stockMovementDao = StockMovementDao(localDatabase);

    final saleDao = SaleDao(localDatabase);
    final saleItemDao = SaleItemDao(localDatabase);
    final saleRepository = SaleRepository(
      localDatabase,
      saleDao,
      businessUnitDao,
      saleItemDao,
      catalogItemDao,
      stockMovementDao,
    );

    final financialStatementDao = FinancialStatementDao(localDatabase);
    final financialStatementRepository = FinancialStatementRepository(
      localDatabase,
      financialStatementDao,
      businessUnitDao,
    );

    final catalogRepository = CatalogRepository(
      localDatabase,
      itemCategoryDao,
      catalogItemDao,
      stockMovementDao,
      expenseRepository,
      supplierDao,
    );

    final stockRepository = StockRepository(
      localDatabase,
      stockMovementDao,
      catalogItemDao,
      supplierDao,
      expenseRepository,
    );

    // Read-only reports (low stock, stock value, margin per item).
    final reportRepository = ReportRepository(stockMovementDao, saleItemDao);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
ChangeNotifierProvider.value(value: localeProvider),
ChangeNotifierProvider(create: (_) => UserProvider(userRepository)),

// BusinessUnitProvider must be initialized before dependent providers
        ChangeNotifierProvider(
          create: (_) => BusinessUnitProvider(
            repository: businessUnitRepository,
          )..loadUnits(),
        ),
        ChangeNotifierProxyProvider<BusinessUnitProvider, DashboardProvider>(
          create: (context) => DashboardProvider(
            saleRepository,
            context.read<BusinessUnitProvider>(),
          ),
          update: (_, businessUnitProvider, previous) =>
              previous ?? DashboardProvider(saleRepository, businessUnitProvider),
        ),

        ChangeNotifierProxyProvider<BusinessUnitProvider, CustomerProvider>(
          create: (context) => CustomerProvider(
            customerRepository,
            context.read<BusinessUnitProvider>(),
          ),
          update: (_, __, previous) => previous!,
        ),
        ChangeNotifierProxyProvider<BusinessUnitProvider, SupplierProvider>(
          create: (context) => SupplierProvider(
            supplierRepository,
            context.read<BusinessUnitProvider>(),
          ),
          update: (_, __, previous) => previous!,
        ),
        ChangeNotifierProxyProvider<BusinessUnitProvider, ExpenseProvider>(
          create: (context) => ExpenseProvider(
            expenseRepository,
            context.read<BusinessUnitProvider>(),
          ),
          update: (_, __, previous) => previous!,
        ),
        ChangeNotifierProxyProvider<BusinessUnitProvider, SaleProvider>(
          create: (context) => SaleProvider(
            saleRepository,
            context.read<BusinessUnitProvider>(),
          ),
          update: (_, __, previous) => previous!,
        ),
        ChangeNotifierProxyProvider<BusinessUnitProvider, FinancialStatementProvider>(
          create: (context) => FinancialStatementProvider(
            financialStatementRepository,
            context.read<BusinessUnitProvider>(),
          ),
          update: (_, __, previous) => previous!,
        ),
        ChangeNotifierProxyProvider<BusinessUnitProvider, CatalogProvider>(
          create: (context) => CatalogProvider(
            catalogRepository,
            context.read<BusinessUnitProvider>(),
          ),
          update: (_, __, previous) => previous!,
        ),
        ChangeNotifierProxyProvider<BusinessUnitProvider, StockProvider>(
          create: (context) => StockProvider(
            stockRepository,
            context.read<BusinessUnitProvider>(),
          ),
          update: (_, __, previous) => previous!,
        ),
        ChangeNotifierProxyProvider<BusinessUnitProvider, ReportProvider>(
          create: (context) => ReportProvider(
            reportRepository,
            context.read<BusinessUnitProvider>(),
          ),
          update: (_, __, previous) => previous!,
        ),
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, themeProvider, localeProvider, _) => MaterialApp(
          title: 'Mini',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeProvider.themeMode,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: localeProvider.locale,
          navigatorObservers: [_resumeRouteObserver],
          routes: {
            '/activate': (_) => const ActivationScreen(),
            '/welcome': (_) => const WelcomeScreen(),
            '/onboarding': (_) => const OnboardingScreen(),
            '/login': (_) => const LoginScreen(),
            '/dashboard': (_) => const DashboardScreen(),
            '/customer': (_) => const CustomerListScreen(),
            '/supplier': (_) => const SupplierListScreen(),
            '/expense': (_) => const ExpenseListScreen(),
            '/sale': (_) => const SaleListScreen(),
            '/sale/new': (_) => const SaleFormScreen(),
            '/credit-sale': (_) => const CreditSaleListScreen(),
            '/products': (_) => const ProductListScreen(),
            '/products/categories': (_) => const ItemCategoryScreen(),
            '/services': (_) => const ServiceListScreen(),
            '/stock': (_) => const StockListScreen(),
            '/reports': (_) => const ReportsScreen(),
            '/sale/financial-statement': (_) => const FinancialStatementListScreen(),
            '/sale/financial-statement/generate': (_) =>
                const FinancialStatementGenerateScreen(),
            '/edit-profile': (_) => const EditProfileScreen(),
            '/change-password': (_) => const ChangePasswordScreen(),
            '/business-unit-management': (_) => const BusinessUnitManagementScreen(),
            '/settings/backup': (_) => const BackupScreen(),
          },
          home: const SplashScreen(),
        ),
      ),
    );
  }
}