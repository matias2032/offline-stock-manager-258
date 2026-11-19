// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get signIn => 'Sign in';

  @override
  String helloUser(String name) {
    return 'Hello, $name';
  }

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get enterPasswordToContinue => 'Enter your password to continue.';

  @override
  String get password => 'Password';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get createAccount => 'Create account';

  @override
  String get welcome => 'Welcome';

  @override
  String get fillDetailsToStart =>
      'Fill in your details to start using the app.';

  @override
  String get nameLabel => 'Name *';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get lastName => 'Last name';

  @override
  String get phone => 'Phone';

  @override
  String get email => 'Email';

  @override
  String get invalidEmail => 'Invalid email';

  @override
  String get businessName => 'Business name';

  @override
  String get currencyLabel => 'Currency *';

  @override
  String get passwordLabel => 'Password *';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters';

  @override
  String get confirmPasswordLabel => 'Confirm password *';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get failedToCreateAccount => 'Failed to create account.';

  @override
  String get editProfileTitle => 'Edit Profile';

  @override
  String get updateDetailsBelow => 'Update your account details below.';

  @override
  String get nameFieldLabel => 'Name';

  @override
  String get nameRequiredDot => 'Name is required.';

  @override
  String get currencyFieldLabel => 'Currency';

  @override
  String get couldNotUpdateProfile => 'Could not update profile.';

  @override
  String get profileUpdatedRelogin => 'Profile updated. Please log in again.';

  @override
  String get profileUpdated => 'Profile updated.';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get changePasswordTitle => 'Change Password';

  @override
  String get confirmCurrentPasswordPrompt =>
      'Confirm your current password to set a new one.';

  @override
  String get currentPasswordLabel => 'Current password';

  @override
  String get currentPasswordRequired => 'Current password is required.';

  @override
  String get newPasswordLabel => 'New password';

  @override
  String get newPasswordRequired => 'New password is required.';

  @override
  String get newPasswordMinLength =>
      'Password must be at least 6 characters long.';

  @override
  String get confirmNewPasswordLabel => 'Confirm new password';

  @override
  String get passwordsDoNotMatchDot => 'Passwords do not match.';

  @override
  String get couldNotChangePassword => 'Could not change password.';

  @override
  String get passwordChangedRelogin => 'Password changed. Please log in again.';

  @override
  String get passwordChanged => 'Password changed.';

  @override
  String get changePasswordButton => 'Change password';

  @override
  String get deleteCustomer => 'Delete customer';

  @override
  String confirmDeleteCustomerMessage(String name) {
    return 'Are you sure you want to delete \"$name\"? Associated sales history will be kept.';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get customersTitle => 'Customers';

  @override
  String get newCustomer => 'New customer';

  @override
  String get noCustomersYet => 'No customers registered yet.';

  @override
  String get editCustomer => 'Edit customer';

  @override
  String get notesLabel => 'Notes';

  @override
  String get createCustomer => 'Create customer';

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String get hello => 'Hello';

  @override
  String get salesDoingIntro => 'Here is how your sales are doing.';

  @override
  String get finalizedSales => 'Finalized sales';

  @override
  String get totalRevenue => 'Total revenue';

  @override
  String get settledCreditSales => 'Settled credit sales';

  @override
  String get dashboardComingSoonTitle => 'Dashboard coming soon';

  @override
  String get dashboardComingSoonMessage =>
      'We\'re rebuilding your store dashboard for the new multi-store structure. Check back shortly.';

  @override
  String get settledCreditRevenueLabel => 'Settled credit revenue';

  @override
  String get dashboardNoStoreSelected => 'Select a store to see its stats.';

  @override
  String saleCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sales',
      one: '1 sale',
      zero: '0 sales',
    );
    return '$_temp0';
  }

  @override
  String get suppliersTitle => 'Suppliers';

  @override
  String get noSuppliersYet => 'No suppliers registered yet.';

  @override
  String get newSupplier => 'New supplier';

  @override
  String get editSupplier => 'Edit supplier';

  @override
  String get deleteSupplier => 'Delete supplier';

  @override
  String get createSupplier => 'Create supplier';

  @override
  String get addressLabel => 'Address';

  @override
  String get deleteSupplierConfirmationGeneric =>
      'Are you sure you want to delete this supplier?';

  @override
  String confirmDeleteSupplierMessage(String name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String get descriptionOptionalLabel => 'Description (optional)';

  @override
  String get filterExpensesTitle => 'Filter expenses';

  @override
  String get allLabel => 'All';

  @override
  String get supplierLabel => 'Supplier';

  @override
  String get startDateLabel => 'Start date';

  @override
  String get endDateLabel => 'End date';

  @override
  String get clearLabel => 'Clear';

  @override
  String get applyLabel => 'Apply';

  @override
  String get newExpense => 'New expense';

  @override
  String get editExpense => 'Edit expense';

  @override
  String get descriptionLabel => 'Description';

  @override
  String get descriptionRequired => 'Description is required';

  @override
  String get amountLabel => 'Amount (MZN)';

  @override
  String get amountRequired => 'Amount is required';

  @override
  String get invalidAmount => 'Invalid amount';

  @override
  String get supplierOptionalLabel => 'Supplier (optional)';

  @override
  String get noneLabel => 'None';

  @override
  String dateLabel(String date) {
    return 'Date: $date';
  }

  @override
  String get createExpense => 'Create expense';

  @override
  String get saveLabel => 'Save';

  @override
  String get expensesTitle => 'Expenses';

  @override
  String get deleteExpense => 'Delete expense';

  @override
  String confirmDeleteExpenseMessage(String name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String get deletionReasonLabel => 'Deletion reason';

  @override
  String get noExpensesYet => 'No expenses registered.';

  @override
  String get unknownCustomer => 'Unknown customer';

  @override
  String customerNumber(String id) {
    return 'Customer #$id';
  }

  @override
  String get enterValidPaymentAmount => 'Enter a valid payment amount.';

  @override
  String get paymentExceedsRemainingDebt =>
      'Payment exceeds the remaining debt.';

  @override
  String get paymentRegistered => 'Payment registered.';

  @override
  String get couldNotRegisterPayment => 'Could not register payment.';

  @override
  String get cancelSale => 'Cancel sale';

  @override
  String get cancellationReasonLabel => 'Cancellation reason';

  @override
  String get back => 'Back';

  @override
  String get cancelSaleButton => 'Cancel Sale';

  @override
  String get couldNotCancelSale => 'Could not cancel sale.';

  @override
  String get creditSaleTitle => 'Credit Sale';

  @override
  String get saleNotFound => 'Sale not found.';

  @override
  String get totalLabel => 'Total';

  @override
  String get paidSoFarLabel => 'Paid so far';

  @override
  String get remainingDebtLabel => 'Remaining debt';

  @override
  String get statusLabel => 'Status';

  @override
  String get paymentStatusLabel => 'Payment status';

  @override
  String get dueDateLabel => 'Due date';

  @override
  String get registerPayment => 'Register payment';

  @override
  String get amountFieldLabel => 'Amount';

  @override
  String get enterValidAmount => 'Enter a valid amount';

  @override
  String get paymentMethodLabel => 'Payment method';

  @override
  String get cashMethod => 'Cash';

  @override
  String get bankTransferMethod => 'Bank transfer';

  @override
  String get mpesaMethod => 'M-Pesa';

  @override
  String get emolaMethod => 'E-Mola';

  @override
  String get otherMethod => 'Other';

  @override
  String get notesOptionalLabel => 'Notes (optional)';

  @override
  String get paymentHistory => 'Payment history';

  @override
  String get noPaymentsYet => 'No payments registered yet.';

  @override
  String get creditSalesTitle => 'Credit Sales';

  @override
  String get noOutstandingCreditSales => 'No outstanding credit sales.';

  @override
  String creditSaleSubtitle(
    String reference,
    String description,
    String owed,
    String currency,
    String paid,
  ) {
    return '$reference — $description\nOwed: $owed $currency • Paid so far: $paid $currency';
  }

  @override
  String get salesGroupLabel => 'Sales';

  @override
  String get finishedSalesLabel => 'Finished Sales';

  @override
  String get categoriesLabel => 'Categories';

  @override
  String get financialStatementsLabel => 'Financial Statements';

  @override
  String get logOut => 'Log Out';

  @override
  String get changeThemeLabel => 'Change Theme';

  @override
  String get confirmLogoutTitle => 'Confirm Logout';

  @override
  String get confirmLogoutMessage => 'Are you sure you want to log out?';

  @override
  String get languageLabel => 'Language';

  @override
  String get statementDetailTitle => 'Statement Detail';

  @override
  String salesCountLabel(int count) {
    return 'Sales ($count)';
  }

  @override
  String expensesCountLabel(int count) {
    return 'Expenses ($count)';
  }

  @override
  String get balanceLabel => 'Balance';

  @override
  String get salesSectionTitle => 'Sales';

  @override
  String get noSalesInPeriod => 'No sales in this period.';

  @override
  String get expensesSectionTitle => 'Expenses';

  @override
  String get noExpensesInPeriod => 'No expenses in this period.';

  @override
  String get generateStatementTitle => 'Generate Statement';

  @override
  String get periodLabel => 'Period';

  @override
  String get selectBothDatesMessage => 'Select both a start and an end date.';

  @override
  String get endDateBeforeStartDateMessage =>
      'End date cannot be before start date.';

  @override
  String get selectStartDate => 'Select start date';

  @override
  String get selectEndDate => 'Select end date';

  @override
  String startDatePrefix(String date) {
    return 'Start: $date';
  }

  @override
  String endDatePrefix(String date) {
    return 'End: $date';
  }

  @override
  String get generateButtonLabel => 'Generate';

  @override
  String get financialStatementsTitle => 'Financial Statements';

  @override
  String get noStatementsYet => 'No statements generated yet.';

  @override
  String get deleteStatementTitle => 'Delete statement';

  @override
  String confirmDeleteStatementMessage(String name) {
    return 'Delete statement $name? This cannot be undone.';
  }

  @override
  String get couldNotDeleteStatement => 'Could not delete statement.';

  @override
  String get generateStatementTooltip => 'Generate statement';

  @override
  String generatedOnPrefix(String date) {
    return 'Generated $date';
  }

  @override
  String get nameRequiredMessage => 'Name is required';

  @override
  String get createCategoryButton => 'Create';

  @override
  String get newSaleTitle => 'New Sale';

  @override
  String get selectCustomerMessage => 'Select a customer.';

  @override
  String get enterWalkInNameMessage => 'Enter a walk-in customer name.';

  @override
  String get enterValidInitialPaymentMessage =>
      'Enter a valid initial payment.';

  @override
  String get initialPaymentExceedsTotalMessage =>
      'Initial payment cannot exceed the sale total.';

  @override
  String get descriptionRequiredMessage => 'Description is required';

  @override
  String get totalAmountLabel => 'Total amount';

  @override
  String get enterValidAmountMessage => 'Enter a valid amount';

  @override
  String get normalLabel => 'Normal';

  @override
  String get creditLabel => 'Credit';

  @override
  String get useExistingCustomerLabel => 'Use existing customer';

  @override
  String get associateExistingCustomerOptionalLabel =>
      'Associate an existing customer (optional)';

  @override
  String get customerLabel => 'Customer';

  @override
  String get walkInCustomerNameLabel => 'Walk-in customer name';

  @override
  String get addDueDateOptionalLabel => 'Add a due date (optional)';

  @override
  String dueDatePrefix(String date) {
    return 'Due: $date';
  }

  @override
  String get initialPaymentOptionalLabel => 'Initial payment (optional)';

  @override
  String get initialPaymentHelperText =>
      'Leave empty if nothing was paid yet — the full amount stays owed.';

  @override
  String get createSaleButton => 'Create Sale';

  @override
  String get finishedSalesTitle => 'Finished Sales';

  @override
  String get creditSalesTooltip => 'Credit sales';

  @override
  String get typeLabel => 'Type';

  @override
  String get noFinishedSalesYet => 'No finished sales yet.';

  @override
  String get newSaleTooltip => 'New sale';

  @override
  String get cancelSaleTitle => 'Cancel sale';

  @override
  String get backLabel => 'Back';

  @override
  String get noCustomerLabel => 'No customer';

  @override
  String customerNumberLabel(int id) {
    return 'Customer #$id';
  }

  @override
  String get immediateLabel => 'Immediate';

  @override
  String get noInstallmentsRegistered => 'No installments registered.';

  @override
  String paidInInstallmentsMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'installments',
      one: 'installment',
      zero: 'installments',
    );
    return 'Paid in $count $_temp0:';
  }

  @override
  String get splashLoading => 'Preparing your experience...';

  @override
  String get switchStoreTooltip => 'Switch store';

  @override
  String get storesTitle => 'Stores';

  @override
  String get newStore => 'New store';

  @override
  String get storeNameLabel => 'Store name';

  @override
  String get storeNameRequired => 'Store name is required';

  @override
  String get renameStoreTitle => 'Rename store';

  @override
  String get setAsDefault => 'Set as default';

  @override
  String get defaultStoreLabel => 'Default';

  @override
  String get deleteStoreTitle => 'Delete store';

  @override
  String confirmDeleteStoreMessage(String name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String get couldNotDeleteStore => 'Could not delete store.';

  @override
  String get couldNotCreateStore => 'Could not create store.';

  @override
  String get couldNotRenameStore => 'Could not rename store.';

  @override
  String get currentStoreLabel => 'Current store';

  @override
  String get allStoresLabel => 'All stores';

  @override
  String get perStoreBreakdownTitle => 'Breakdown by store';

  @override
  String get consolidatedStatementLabel =>
      'Consolidated statement (all stores)';

  @override
  String get consolidatedStatementDescription =>
      'Sums the data from every store for this period';

  @override
  String get archiveStoreTitle => 'Archive store';

  @override
  String confirmArchiveStoreMessage(Object name) {
    return 'Are you sure you want to archive \"$name\"? This store\'s data (sales, customers, statements) is preserved, but it will no longer appear as an active store.';
  }

  @override
  String get archiveLabel => 'Archive';

  @override
  String get couldNotArchiveStore => 'Could not archive the store.';

  @override
  String get backupRestoreTitle => 'Backup & Restore';

  @override
  String get backupSectionTitle => 'Create backup';

  @override
  String get backupSectionDescription =>
      'Generates a file with all your data and opens the share menu so you can save it somewhere safe (cloud drive, email, USB...). Since the app is fully offline, this file is your only way to recover data or move it to another device.';

  @override
  String get createBackupButton => 'Create backup';

  @override
  String backupCreatedMessage(String path) {
    return 'Backup saved to: $path';
  }

  @override
  String get backupFailedMessage => 'Could not create the backup.';

  @override
  String get restoreSectionTitle => 'Restore backup';

  @override
  String get restoreSectionDescription =>
      'Choose a previously created backup file. Data already on this device is kept — only missing or older records are updated with the backup\'s data.';

  @override
  String get restoreBackupButton => 'Choose backup file';

  @override
  String get restoreConfirmTitle => 'Restore backup?';

  @override
  String get restoreConfirmMessage =>
      'This merges the backup into your current data. Nothing on this device is deleted: for each record, whichever version is more recent — the one already here or the one in the backup — is kept.';

  @override
  String get restoreConfirmButton => 'Continue';

  @override
  String restoreSuccessMessage(int inserted, int updated, int skipped) {
    return 'Restore complete: $inserted new, $updated updated, $skipped unchanged.';
  }

  @override
  String get saleCreatedMessage => 'Sale created successfully.';

  @override
  String get discardSaleTitle => 'Discard sale?';

  @override
  String get discardSaleMessage => 'The data you entered will be lost.';

  @override
  String get discardLabel => 'Discard';

  @override
  String get keepEditingLabel => 'Keep editing';

  @override
  String get restoreFailedMessage => 'Could not restore the backup.';

  @override
  String get shareSectionTitle => 'Share backup';

  @override
  String get shareSectionDescriptionEmpty =>
      'Create a backup first, then you can share that exact file (email, cloud drive, USB...) if you want an extra copy off this device.';

  @override
  String shareSectionDescriptionReady(String fileName) {
    return 'Ready to share: $fileName';
  }

  @override
  String get shareBackupButton => 'Share backup';

  @override
  String get shareFailedMessage => 'Could not open the share menu.';

  @override
  String get generatePdfTooltip => 'Generate PDF';

  @override
  String get referenceColumnLabel => 'Ref.';

  @override
  String get dateColumnLabel => 'Date';

  @override
  String get storeColumnLabel => 'Store';

  @override
  String get periodToday => 'Today';

  @override
  String get periodLast24Hours => '1 day';

  @override
  String get periodOneWeek => '1 week';

  @override
  String get periodOneMonth => '1 month';

  @override
  String get periodThreeMonths => '3 months';

  @override
  String get periodSixMonths => '6 months';

  @override
  String get periodOneYear => '1 year';

  @override
  String get periodCustom => 'Custom';

  @override
  String get splashTip1 => 'Register a sale in seconds, right from your phone.';

  @override
  String get splashTip2 =>
      'Every sale gets its own reference. No more lost notes.';

  @override
  String get splashTip3 =>
      'Cash, M-Pesa, e-Mola or bank transfer: you choose how you get paid.';

  @override
  String get splashTip4 => 'Know exactly how much you sold today.';

  @override
  String get splashTip5 => 'Sold on credit? Never forget who owes you.';

  @override
  String get splashTip6 => 'Register each payment and watch the debt shrink.';

  @override
  String get splashTip7 =>
      'Split a debt into installments, one payment at a time.';

  @override
  String get splashTip8 =>
      'A badge shows how many credit sales are still open.';

  @override
  String get splashTip9 => 'Track every expense, from rent to restocking.';

  @override
  String get splashTip10 => 'Keep your suppliers organized in one place.';

  @override
  String get splashTip11 =>
      'Money going out matters as much as money coming in.';

  @override
  String get splashTip12 =>
      'Filter expenses by supplier or date and find anything fast.';

  @override
  String get splashTip13 => 'Generate a financial statement for any period.';

  @override
  String get splashTip14 =>
      'Sales minus expenses: your balance, crystal clear.';

  @override
  String get splashTip15 =>
      'Turn your statement into a PDF, ready to print or share.';

  @override
  String get splashTip16 =>
      'Statements are frozen in time, so the numbers never change on you.';

  @override
  String get splashTip17 => 'Several stores? Manage them all in one app.';

  @override
  String get splashTip18 => 'Switch between stores with a single tap.';

  @override
  String get splashTip19 =>
      'See the whole group in one consolidated statement.';

  @override
  String get splashTip20 => 'Compare how each store contributes to your total.';

  @override
  String get splashTip21 => 'Know your customers and their purchase history.';

  @override
  String get splashTip22 => 'Works fully offline. No internet, no problem.';

  @override
  String get splashTip23 =>
      'Your data stays on your device, protected by your password.';

  @override
  String get splashTip24 => 'Create a backup today and sleep easy tomorrow.';

  @override
  String get welcomeToMiniTitle => 'Welcome to Mini';

  @override
  String get welcomeSubtitle =>
      'Do you already have a backup from another device or a previous installation?';

  @override
  String get welcomeRestoreButton => 'Restore from backup';

  @override
  String get welcomeCreateNewButton => 'Start from scratch';

  @override
  String get restorePreviewTitle => 'Backup found';

  @override
  String restorePreviewSummary(
    String reference,
    String date,
    String userName,
    int storeCount,
    int saleCount,
  ) {
    return 'Reference: $reference\nDate: $date\nAccount: $userName\nStores: $storeCount\nSales: $saleCount';
  }

  @override
  String get restorePreviewConfirmButton => 'Restore';

  @override
  String get restoreFreshSuccessMessage =>
      'Backup restored. Sign in with the password from that backup.';

  @override
  String get backupErrorInvalidFile =>
      'The selected file is not a valid JSON backup.';

  @override
  String get backupErrorUnrecognized => 'This file is not a recognized backup.';

  @override
  String get backupErrorNoUser =>
      'This backup has no account data, so it cannot be restored here.';

  @override
  String get backupErrorNoStore =>
      'This backup has no stores, so it cannot be restored here.';

  @override
  String get backupErrorNewerVersion =>
      'This backup was created by a newer version of the app. Update the app and try again.';

  @override
  String get backupErrorIntegrity =>
      'The backup data is inconsistent. Nothing was restored.';

  @override
  String get activationTitle => 'Activate Mini';

  @override
  String get activationSubtitle =>
      'Enter the activation code you received with your purchase. An internet connection is needed only this once.';

  @override
  String get activationCodeLabel => 'Activation code';

  @override
  String get activationCodeRequired => 'Enter your activation code';

  @override
  String get activationButton => 'Activate';

  @override
  String get activationErrorInvalidCode =>
      'This code is not valid. Check it and try again.';

  @override
  String get activationErrorAlreadyUsed =>
      'This code is already in use on another device. Contact support to move your license.';

  @override
  String get activationErrorRevoked =>
      'This license is no longer active. Contact support.';

  @override
  String get activationErrorRateLimited =>
      'Too many attempts. Wait a few minutes and try again.';

  @override
  String get activationErrorNetwork =>
      'Could not reach the activation server. Check your internet connection and try again.';

  @override
  String get activationErrorDevice => 'Could not identify this device.';

  @override
  String get activationErrorGeneric => 'Activation failed. Please try again.';

  @override
  String get revenueMixTitle => 'Revenue mix';

  @override
  String get immediateRevenueLabel => 'Immediate revenue';

  @override
  String get revenueTrendTitle => 'Revenue over time';

  @override
  String get peakLabel => 'Peak';

  @override
  String get catalogTitle => 'Catalog';

  @override
  String get newCatalogItem => 'New item';

  @override
  String get editCatalogItem => 'Edit item';

  @override
  String get createCatalogItem => 'Create item';

  @override
  String get noCatalogItemsYet => 'No products or services registered yet.';

  @override
  String get deleteCatalogItem => 'Delete item';

  @override
  String confirmDeleteCatalogItemMessage(String name) {
    return 'Are you sure you want to delete \"$name\"? Past sales keep their history.';
  }

  @override
  String get searchLabel => 'Search';

  @override
  String get productLabel => 'Product';

  @override
  String get serviceLabel => 'Service';

  @override
  String get itemNameLabel => 'Name';

  @override
  String get itemCodeLabel => 'Code (optional)';

  @override
  String get categoryLabel => 'Category';

  @override
  String get noCategoryLabel => 'No category';

  @override
  String get unitLabel => 'Unit';

  @override
  String get salePriceLabel => 'Sale price';

  @override
  String get costPriceLabel => 'Cost price';

  @override
  String get costPriceHelperText =>
      'Reference cost. Updated automatically when you register a purchase.';

  @override
  String get trackStockLabel => 'Track stock';

  @override
  String get trackStockHelperText =>
      'Quantity goes down with each sale and up with each purchase.';

  @override
  String get minStockLabel => 'Minimum stock (alert)';

  @override
  String get activeLabel => 'Active';

  @override
  String get inactiveLabel => 'Inactive';

  @override
  String get newCategory => 'New category';

  @override
  String get renameCategory => 'Rename category';

  @override
  String get categoryNameLabel => 'Category name';

  @override
  String get deleteCategory => 'Delete category';

  @override
  String confirmDeleteCategoryMessage(String name) {
    return 'Delete \"$name\"? Products in this category will be kept, just without a category.';
  }

  @override
  String get noCategoriesYet => 'No categories yet.';

  @override
  String get stockTitle => 'Stock';

  @override
  String lowStockFilterLabel(int count) {
    return 'Low stock ($count)';
  }

  @override
  String get belowMinimumLabel => 'Below minimum';

  @override
  String stockMinLabel(String min) {
    return 'Min: $min';
  }

  @override
  String get noStockItemsYet => 'No products registered yet.';

  @override
  String get noInitialStockLabel => 'No initial stock';

  @override
  String get deletedLabel => 'Deleted';

  @override
  String get stockHistoryTitle => 'Stock history';

  @override
  String get noMovementsYet => 'No movements yet.';

  @override
  String get stockPurchaseButton => 'Register purchase';

  @override
  String get stockPurchaseTitle => 'Stock purchase';

  @override
  String get initialStockButton => 'Set initial stock';

  @override
  String get adjustStockButton => 'Adjust stock';

  @override
  String get quantityLabel => 'Quantity';

  @override
  String get unitCostLabel => 'Unit cost';

  @override
  String get unitCostOptionalLabel => 'Unit cost (optional)';

  @override
  String purchaseTotalLabel(String amount) {
    return 'Total: $amount';
  }

  @override
  String get enterValidQuantityMessage => 'Enter a valid quantity';

  @override
  String get noteRequiredMessage => 'A note is required for this movement';

  @override
  String get movementTypeLabel => 'Movement type';

  @override
  String get stockMovementSaved => 'Movement registered.';

  @override
  String stockPurchaseExpenseDescription(String quantity, String name) {
    return 'Acquisition: $quantity × $name';
  }

  @override
  String get stockPurchaseTag => 'Stock purchase';

  @override
  String get stockExpenseLockedMessage =>
      'This expense comes from a stock purchase and cannot be edited or deleted.';

  @override
  String get movementInitial => 'Initial stock';

  @override
  String get movementPurchase => 'Purchase';

  @override
  String get movementSale => 'Sale';

  @override
  String get movementSaleReversal => 'Sale reversal';

  @override
  String get movementAdjustmentIn => 'Adjustment (in)';

  @override
  String get movementAdjustmentOut => 'Exit (internal use / correction)';

  @override
  String get movementLoss => 'Loss';

  @override
  String get saleItemsTitle => 'Items';

  @override
  String get addItemButton => 'Add item';

  @override
  String get selectItemTitle => 'Select item';

  @override
  String get removeItemTooltip => 'Remove item';

  @override
  String get unitPriceLabel => 'Unit price';

  @override
  String lineSubtotalLabel(String amount) {
    return 'Subtotal: $amount';
  }

  @override
  String stockAvailableLabel(String quantity, String unit) {
    return 'In stock: $quantity $unit';
  }

  @override
  String get outOfStockLabel => 'Out of stock';

  @override
  String get noSellableItemsYet =>
      'No active products or services in the catalog yet.';

  @override
  String get reportsTitle => 'Reports';

  @override
  String get lowStockTabLabel => 'Low stock';

  @override
  String get stockValueLabel => 'Stock value';

  @override
  String get marginTabLabel => 'Margin';

  @override
  String get noLowStockItems => 'No products below their minimum stock.';

  @override
  String get noStockValueYet => 'No stock on hand yet.';

  @override
  String itemsWithoutCostNote(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items have no cost price and are valued at 0.',
      one: '1 item has no cost price and is valued at 0.',
    );
    return '$_temp0';
  }

  @override
  String get noCostLabel => 'No cost set';

  @override
  String get marginNoSalesYet => 'No sales with items in this period.';

  @override
  String get costOfGoodsLabel => 'Cost of goods sold';

  @override
  String get marginLabel => 'Margin';

  @override
  String get reportsInfoNote =>
      'For information only. These figures are not part of the statement balance, which stays cash-based.';

  @override
  String get productsTitle => 'Products';

  @override
  String get servicesTitle => 'Services';

  @override
  String get productCategoriesTitle => 'Product categories';

  @override
  String get newProduct => 'New product';

  @override
  String get editProduct => 'Edit product';

  @override
  String get createProduct => 'Create product';

  @override
  String get newService => 'New service';

  @override
  String get editService => 'Edit service';

  @override
  String get createService => 'Create service';

  @override
  String get noProductsYet => 'No products registered yet.';

  @override
  String get noServicesYet => 'No services registered yet.';

  @override
  String get initialQuantityLabel => 'Initial quantity';

  @override
  String get initialQuantityHelperText =>
      'Stock you already have. It is recorded as an expense (quantity × cost). For later purchases, use \"Move stock\".';

  @override
  String get serviceUnitHelperText => 'e.g. hour, service';

  @override
  String get moveStockButton => 'Move stock';

  @override
  String get movementEntryOption => 'Entry (purchase)';

  @override
  String insufficientStockMessage(String quantity, String unit) {
    return 'Only $quantity $unit in stock';
  }

  @override
  String get cannotDeleteProductWithStockMessage =>
      'This product still has stock. Register an Exit or a Loss first (or set the product inactive).';

  @override
  String get allTypesLabel => 'All types';

  @override
  String get allProductsLabel => 'All products';

  @override
  String get loadMoreLabel => 'Load more';

  @override
  String get noLowStockProductsMessage => 'No products with low stock.';

  @override
  String get saleDetailTitle => 'Sale details';

  @override
  String get okLabel => 'OK';

  @override
  String get customItemTag => 'Custom';

  @override
  String outOfStockNotice(String name) {
    return '\"$name\" is out of stock and cannot be sold.';
  }

  @override
  String get insufficientStockDialogTitle => 'Not enough stock';

  @override
  String insufficientStockDialogMessage(
    String name,
    String quantity,
    String unit,
  ) {
    return 'Not enough stock of \"$name\". Only $quantity $unit in stock.';
  }

  @override
  String get itemUnavailableTitle => 'Item unavailable';

  @override
  String get itemUnavailableMessage =>
      'One of the items is no longer available (it was deactivated or deleted). It is marked in the cart; remove it to continue.';

  @override
  String get itemUnavailableLine => 'This item is no longer available';

  @override
  String get saleNeedsItemsMessage => 'Add at least one item to the sale.';

  @override
  String get cartClearedStoreChangedMessage =>
      'The store changed, so the items were removed from the sale.';

  @override
  String get lossesTabLabel => 'Losses';

  @override
  String get lossesTotalLabel => 'Value of losses';

  @override
  String get noLossesInPeriod => 'No losses in this period.';

  @override
  String get customItemsSalesTitle => 'Custom items';

  @override
  String customItemsSalesNote(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lines sold',
      one: '1 line sold',
    );
    return '$_temp0 without cost. Not included in the margin above.';
  }

  @override
  String get initialStockSupplierHelperText =>
      'The initial stock is already recorded as an expense. Choose a supplier to link it, or leave it empty.';

  @override
  String get pressBackAgainToExit => 'Tap Back again to exit';
}
