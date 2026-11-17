import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt'),
  ];

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @helloUser.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}'**
  String helloUser(String name);

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @enterPasswordToContinue.
  ///
  /// In en, this message translates to:
  /// **'Enter your password to continue.'**
  String get enterPasswordToContinue;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @fillDetailsToStart.
  ///
  /// In en, this message translates to:
  /// **'Fill in your details to start using the app.'**
  String get fillDetailsToStart;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name *'**
  String get nameLabel;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get lastName;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get invalidEmail;

  /// No description provided for @businessName.
  ///
  /// In en, this message translates to:
  /// **'Business name'**
  String get businessName;

  /// No description provided for @currencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Currency *'**
  String get currencyLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password *'**
  String get passwordLabel;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLength;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password *'**
  String get confirmPasswordLabel;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @failedToCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Failed to create account.'**
  String get failedToCreateAccount;

  /// No description provided for @editProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfileTitle;

  /// No description provided for @updateDetailsBelow.
  ///
  /// In en, this message translates to:
  /// **'Update your account details below.'**
  String get updateDetailsBelow;

  /// No description provided for @nameFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameFieldLabel;

  /// No description provided for @nameRequiredDot.
  ///
  /// In en, this message translates to:
  /// **'Name is required.'**
  String get nameRequiredDot;

  /// No description provided for @currencyFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currencyFieldLabel;

  /// No description provided for @couldNotUpdateProfile.
  ///
  /// In en, this message translates to:
  /// **'Could not update profile.'**
  String get couldNotUpdateProfile;

  /// No description provided for @profileUpdatedRelogin.
  ///
  /// In en, this message translates to:
  /// **'Profile updated. Please log in again.'**
  String get profileUpdatedRelogin;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated.'**
  String get profileUpdated;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @changePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePasswordTitle;

  /// No description provided for @confirmCurrentPasswordPrompt.
  ///
  /// In en, this message translates to:
  /// **'Confirm your current password to set a new one.'**
  String get confirmCurrentPasswordPrompt;

  /// No description provided for @currentPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPasswordLabel;

  /// No description provided for @currentPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Current password is required.'**
  String get currentPasswordRequired;

  /// No description provided for @newPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPasswordLabel;

  /// No description provided for @newPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'New password is required.'**
  String get newPasswordRequired;

  /// No description provided for @newPasswordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters long.'**
  String get newPasswordMinLength;

  /// No description provided for @confirmNewPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get confirmNewPasswordLabel;

  /// No description provided for @passwordsDoNotMatchDot.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get passwordsDoNotMatchDot;

  /// No description provided for @couldNotChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Could not change password.'**
  String get couldNotChangePassword;

  /// No description provided for @passwordChangedRelogin.
  ///
  /// In en, this message translates to:
  /// **'Password changed. Please log in again.'**
  String get passwordChangedRelogin;

  /// No description provided for @passwordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password changed.'**
  String get passwordChanged;

  /// No description provided for @changePasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePasswordButton;

  /// No description provided for @deleteCustomer.
  ///
  /// In en, this message translates to:
  /// **'Delete customer'**
  String get deleteCustomer;

  /// No description provided for @confirmDeleteCustomerMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"? Associated sales history will be kept.'**
  String confirmDeleteCustomerMessage(String name);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @customersTitle.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get customersTitle;

  /// No description provided for @newCustomer.
  ///
  /// In en, this message translates to:
  /// **'New customer'**
  String get newCustomer;

  /// No description provided for @noCustomersYet.
  ///
  /// In en, this message translates to:
  /// **'No customers registered yet.'**
  String get noCustomersYet;

  /// No description provided for @editCustomer.
  ///
  /// In en, this message translates to:
  /// **'Edit customer'**
  String get editCustomer;

  /// No description provided for @notesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesLabel;

  /// No description provided for @createCustomer.
  ///
  /// In en, this message translates to:
  /// **'Create customer'**
  String get createCustomer;

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboardTitle;

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get hello;

  /// No description provided for @salesDoingIntro.
  ///
  /// In en, this message translates to:
  /// **'Here is how your sales are doing.'**
  String get salesDoingIntro;

  /// No description provided for @finalizedSales.
  ///
  /// In en, this message translates to:
  /// **'Finalized sales'**
  String get finalizedSales;

  /// No description provided for @totalRevenue.
  ///
  /// In en, this message translates to:
  /// **'Total revenue'**
  String get totalRevenue;

  /// No description provided for @settledCreditSales.
  ///
  /// In en, this message translates to:
  /// **'Settled credit sales'**
  String get settledCreditSales;

  /// No description provided for @dashboardComingSoonTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard coming soon'**
  String get dashboardComingSoonTitle;

  /// No description provided for @dashboardComingSoonMessage.
  ///
  /// In en, this message translates to:
  /// **'We\'re rebuilding your store dashboard for the new multi-store structure. Check back shortly.'**
  String get dashboardComingSoonMessage;

  /// No description provided for @settledCreditRevenueLabel.
  ///
  /// In en, this message translates to:
  /// **'Settled credit revenue'**
  String get settledCreditRevenueLabel;

  /// No description provided for @dashboardNoStoreSelected.
  ///
  /// In en, this message translates to:
  /// **'Select a store to see its stats.'**
  String get dashboardNoStoreSelected;

  /// No description provided for @saleCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 sales} =1{1 sale} other{{count} sales}}'**
  String saleCountLabel(int count);

  /// No description provided for @suppliersTitle.
  ///
  /// In en, this message translates to:
  /// **'Suppliers'**
  String get suppliersTitle;

  /// No description provided for @noSuppliersYet.
  ///
  /// In en, this message translates to:
  /// **'No suppliers registered yet.'**
  String get noSuppliersYet;

  /// No description provided for @newSupplier.
  ///
  /// In en, this message translates to:
  /// **'New supplier'**
  String get newSupplier;

  /// No description provided for @editSupplier.
  ///
  /// In en, this message translates to:
  /// **'Edit supplier'**
  String get editSupplier;

  /// No description provided for @deleteSupplier.
  ///
  /// In en, this message translates to:
  /// **'Delete supplier'**
  String get deleteSupplier;

  /// No description provided for @createSupplier.
  ///
  /// In en, this message translates to:
  /// **'Create supplier'**
  String get createSupplier;

  /// No description provided for @addressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get addressLabel;

  /// No description provided for @deleteSupplierConfirmationGeneric.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this supplier?'**
  String get deleteSupplierConfirmationGeneric;

  /// No description provided for @confirmDeleteSupplierMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"?'**
  String confirmDeleteSupplierMessage(String name);

  /// No description provided for @descriptionOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get descriptionOptionalLabel;

  /// No description provided for @filterExpensesTitle.
  ///
  /// In en, this message translates to:
  /// **'Filter expenses'**
  String get filterExpensesTitle;

  /// No description provided for @allLabel.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allLabel;

  /// No description provided for @supplierLabel.
  ///
  /// In en, this message translates to:
  /// **'Supplier'**
  String get supplierLabel;

  /// No description provided for @startDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get startDateLabel;

  /// No description provided for @endDateLabel.
  ///
  /// In en, this message translates to:
  /// **'End date'**
  String get endDateLabel;

  /// No description provided for @clearLabel.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearLabel;

  /// No description provided for @applyLabel.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get applyLabel;

  /// No description provided for @newExpense.
  ///
  /// In en, this message translates to:
  /// **'New expense'**
  String get newExpense;

  /// No description provided for @editExpense.
  ///
  /// In en, this message translates to:
  /// **'Edit expense'**
  String get editExpense;

  /// No description provided for @descriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionLabel;

  /// No description provided for @descriptionRequired.
  ///
  /// In en, this message translates to:
  /// **'Description is required'**
  String get descriptionRequired;

  /// No description provided for @amountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount (MZN)'**
  String get amountLabel;

  /// No description provided for @amountRequired.
  ///
  /// In en, this message translates to:
  /// **'Amount is required'**
  String get amountRequired;

  /// No description provided for @invalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Invalid amount'**
  String get invalidAmount;

  /// No description provided for @supplierOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Supplier (optional)'**
  String get supplierOptionalLabel;

  /// No description provided for @noneLabel.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get noneLabel;

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date: {date}'**
  String dateLabel(String date);

  /// No description provided for @createExpense.
  ///
  /// In en, this message translates to:
  /// **'Create expense'**
  String get createExpense;

  /// No description provided for @saveLabel.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveLabel;

  /// No description provided for @expensesTitle.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expensesTitle;

  /// No description provided for @deleteExpense.
  ///
  /// In en, this message translates to:
  /// **'Delete expense'**
  String get deleteExpense;

  /// No description provided for @confirmDeleteExpenseMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"?'**
  String confirmDeleteExpenseMessage(String name);

  /// No description provided for @deletionReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Deletion reason'**
  String get deletionReasonLabel;

  /// No description provided for @noExpensesYet.
  ///
  /// In en, this message translates to:
  /// **'No expenses registered.'**
  String get noExpensesYet;

  /// No description provided for @unknownCustomer.
  ///
  /// In en, this message translates to:
  /// **'Unknown customer'**
  String get unknownCustomer;

  /// No description provided for @customerNumber.
  ///
  /// In en, this message translates to:
  /// **'Customer #{id}'**
  String customerNumber(String id);

  /// No description provided for @enterValidPaymentAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid payment amount.'**
  String get enterValidPaymentAmount;

  /// No description provided for @paymentExceedsRemainingDebt.
  ///
  /// In en, this message translates to:
  /// **'Payment exceeds the remaining debt.'**
  String get paymentExceedsRemainingDebt;

  /// No description provided for @paymentRegistered.
  ///
  /// In en, this message translates to:
  /// **'Payment registered.'**
  String get paymentRegistered;

  /// No description provided for @couldNotRegisterPayment.
  ///
  /// In en, this message translates to:
  /// **'Could not register payment.'**
  String get couldNotRegisterPayment;

  /// No description provided for @cancelSale.
  ///
  /// In en, this message translates to:
  /// **'Cancel sale'**
  String get cancelSale;

  /// No description provided for @cancellationReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Cancellation reason'**
  String get cancellationReasonLabel;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @cancelSaleButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel Sale'**
  String get cancelSaleButton;

  /// No description provided for @couldNotCancelSale.
  ///
  /// In en, this message translates to:
  /// **'Could not cancel sale.'**
  String get couldNotCancelSale;

  /// No description provided for @creditSaleTitle.
  ///
  /// In en, this message translates to:
  /// **'Credit Sale'**
  String get creditSaleTitle;

  /// No description provided for @saleNotFound.
  ///
  /// In en, this message translates to:
  /// **'Sale not found.'**
  String get saleNotFound;

  /// No description provided for @totalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get totalLabel;

  /// No description provided for @paidSoFarLabel.
  ///
  /// In en, this message translates to:
  /// **'Paid so far'**
  String get paidSoFarLabel;

  /// No description provided for @remainingDebtLabel.
  ///
  /// In en, this message translates to:
  /// **'Remaining debt'**
  String get remainingDebtLabel;

  /// No description provided for @statusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get statusLabel;

  /// No description provided for @paymentStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment status'**
  String get paymentStatusLabel;

  /// No description provided for @dueDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Due date'**
  String get dueDateLabel;

  /// No description provided for @registerPayment.
  ///
  /// In en, this message translates to:
  /// **'Register payment'**
  String get registerPayment;

  /// No description provided for @amountFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amountFieldLabel;

  /// No description provided for @enterValidAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount'**
  String get enterValidAmount;

  /// No description provided for @paymentMethodLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get paymentMethodLabel;

  /// No description provided for @cashMethod.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cashMethod;

  /// No description provided for @bankTransferMethod.
  ///
  /// In en, this message translates to:
  /// **'Bank transfer'**
  String get bankTransferMethod;

  /// No description provided for @mpesaMethod.
  ///
  /// In en, this message translates to:
  /// **'M-Pesa'**
  String get mpesaMethod;

  /// No description provided for @emolaMethod.
  ///
  /// In en, this message translates to:
  /// **'E-Mola'**
  String get emolaMethod;

  /// No description provided for @otherMethod.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get otherMethod;

  /// No description provided for @notesOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get notesOptionalLabel;

  /// No description provided for @paymentHistory.
  ///
  /// In en, this message translates to:
  /// **'Payment history'**
  String get paymentHistory;

  /// No description provided for @noPaymentsYet.
  ///
  /// In en, this message translates to:
  /// **'No payments registered yet.'**
  String get noPaymentsYet;

  /// No description provided for @creditSalesTitle.
  ///
  /// In en, this message translates to:
  /// **'Credit Sales'**
  String get creditSalesTitle;

  /// No description provided for @noOutstandingCreditSales.
  ///
  /// In en, this message translates to:
  /// **'No outstanding credit sales.'**
  String get noOutstandingCreditSales;

  /// No description provided for @creditSaleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{reference} — {description}\nOwed: {owed} {currency} • Paid so far: {paid} {currency}'**
  String creditSaleSubtitle(
    String reference,
    String description,
    String owed,
    String currency,
    String paid,
  );

  /// No description provided for @salesGroupLabel.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get salesGroupLabel;

  /// No description provided for @finishedSalesLabel.
  ///
  /// In en, this message translates to:
  /// **'Finished Sales'**
  String get finishedSalesLabel;

  /// No description provided for @categoriesLabel.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categoriesLabel;

  /// No description provided for @financialStatementsLabel.
  ///
  /// In en, this message translates to:
  /// **'Financial Statements'**
  String get financialStatementsLabel;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// No description provided for @changeThemeLabel.
  ///
  /// In en, this message translates to:
  /// **'Change Theme'**
  String get changeThemeLabel;

  /// No description provided for @confirmLogoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Logout'**
  String get confirmLogoutTitle;

  /// No description provided for @confirmLogoutMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get confirmLogoutMessage;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// No description provided for @statementDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Statement Detail'**
  String get statementDetailTitle;

  /// No description provided for @salesCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Sales ({count})'**
  String salesCountLabel(int count);

  /// No description provided for @expensesCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Expenses ({count})'**
  String expensesCountLabel(int count);

  /// No description provided for @balanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balanceLabel;

  /// No description provided for @salesSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get salesSectionTitle;

  /// No description provided for @noSalesInPeriod.
  ///
  /// In en, this message translates to:
  /// **'No sales in this period.'**
  String get noSalesInPeriod;

  /// No description provided for @expensesSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expensesSectionTitle;

  /// No description provided for @noExpensesInPeriod.
  ///
  /// In en, this message translates to:
  /// **'No expenses in this period.'**
  String get noExpensesInPeriod;

  /// No description provided for @generateStatementTitle.
  ///
  /// In en, this message translates to:
  /// **'Generate Statement'**
  String get generateStatementTitle;

  /// No description provided for @periodLabel.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get periodLabel;

  /// No description provided for @selectBothDatesMessage.
  ///
  /// In en, this message translates to:
  /// **'Select both a start and an end date.'**
  String get selectBothDatesMessage;

  /// No description provided for @endDateBeforeStartDateMessage.
  ///
  /// In en, this message translates to:
  /// **'End date cannot be before start date.'**
  String get endDateBeforeStartDateMessage;

  /// No description provided for @selectStartDate.
  ///
  /// In en, this message translates to:
  /// **'Select start date'**
  String get selectStartDate;

  /// No description provided for @selectEndDate.
  ///
  /// In en, this message translates to:
  /// **'Select end date'**
  String get selectEndDate;

  /// No description provided for @startDatePrefix.
  ///
  /// In en, this message translates to:
  /// **'Start: {date}'**
  String startDatePrefix(String date);

  /// No description provided for @endDatePrefix.
  ///
  /// In en, this message translates to:
  /// **'End: {date}'**
  String endDatePrefix(String date);

  /// No description provided for @generateButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get generateButtonLabel;

  /// No description provided for @financialStatementsTitle.
  ///
  /// In en, this message translates to:
  /// **'Financial Statements'**
  String get financialStatementsTitle;

  /// No description provided for @noStatementsYet.
  ///
  /// In en, this message translates to:
  /// **'No statements generated yet.'**
  String get noStatementsYet;

  /// No description provided for @deleteStatementTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete statement'**
  String get deleteStatementTitle;

  /// No description provided for @confirmDeleteStatementMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete statement {name}? This cannot be undone.'**
  String confirmDeleteStatementMessage(String name);

  /// No description provided for @couldNotDeleteStatement.
  ///
  /// In en, this message translates to:
  /// **'Could not delete statement.'**
  String get couldNotDeleteStatement;

  /// No description provided for @generateStatementTooltip.
  ///
  /// In en, this message translates to:
  /// **'Generate statement'**
  String get generateStatementTooltip;

  /// No description provided for @generatedOnPrefix.
  ///
  /// In en, this message translates to:
  /// **'Generated {date}'**
  String generatedOnPrefix(String date);

  /// No description provided for @nameRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequiredMessage;

  /// No description provided for @createCategoryButton.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get createCategoryButton;

  /// No description provided for @newSaleTitle.
  ///
  /// In en, this message translates to:
  /// **'New Sale'**
  String get newSaleTitle;

  /// No description provided for @selectCustomerMessage.
  ///
  /// In en, this message translates to:
  /// **'Select a customer.'**
  String get selectCustomerMessage;

  /// No description provided for @enterWalkInNameMessage.
  ///
  /// In en, this message translates to:
  /// **'Enter a walk-in customer name.'**
  String get enterWalkInNameMessage;

  /// No description provided for @enterValidInitialPaymentMessage.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid initial payment.'**
  String get enterValidInitialPaymentMessage;

  /// No description provided for @initialPaymentExceedsTotalMessage.
  ///
  /// In en, this message translates to:
  /// **'Initial payment cannot exceed the sale total.'**
  String get initialPaymentExceedsTotalMessage;

  /// No description provided for @descriptionRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'Description is required'**
  String get descriptionRequiredMessage;

  /// No description provided for @totalAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Total amount'**
  String get totalAmountLabel;

  /// No description provided for @enterValidAmountMessage.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount'**
  String get enterValidAmountMessage;

  /// No description provided for @normalLabel.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get normalLabel;

  /// No description provided for @creditLabel.
  ///
  /// In en, this message translates to:
  /// **'Credit'**
  String get creditLabel;

  /// No description provided for @useExistingCustomerLabel.
  ///
  /// In en, this message translates to:
  /// **'Use existing customer'**
  String get useExistingCustomerLabel;

  /// No description provided for @associateExistingCustomerOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Associate an existing customer (optional)'**
  String get associateExistingCustomerOptionalLabel;

  /// No description provided for @customerLabel.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customerLabel;

  /// No description provided for @walkInCustomerNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Walk-in customer name'**
  String get walkInCustomerNameLabel;

  /// No description provided for @addDueDateOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Add a due date (optional)'**
  String get addDueDateOptionalLabel;

  /// No description provided for @dueDatePrefix.
  ///
  /// In en, this message translates to:
  /// **'Due: {date}'**
  String dueDatePrefix(String date);

  /// No description provided for @initialPaymentOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Initial payment (optional)'**
  String get initialPaymentOptionalLabel;

  /// No description provided for @initialPaymentHelperText.
  ///
  /// In en, this message translates to:
  /// **'Leave empty if nothing was paid yet — the full amount stays owed.'**
  String get initialPaymentHelperText;

  /// No description provided for @createSaleButton.
  ///
  /// In en, this message translates to:
  /// **'Create Sale'**
  String get createSaleButton;

  /// No description provided for @finishedSalesTitle.
  ///
  /// In en, this message translates to:
  /// **'Finished Sales'**
  String get finishedSalesTitle;

  /// No description provided for @creditSalesTooltip.
  ///
  /// In en, this message translates to:
  /// **'Credit sales'**
  String get creditSalesTooltip;

  /// No description provided for @typeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get typeLabel;

  /// No description provided for @noFinishedSalesYet.
  ///
  /// In en, this message translates to:
  /// **'No finished sales yet.'**
  String get noFinishedSalesYet;

  /// No description provided for @newSaleTooltip.
  ///
  /// In en, this message translates to:
  /// **'New sale'**
  String get newSaleTooltip;

  /// No description provided for @cancelSaleTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel sale'**
  String get cancelSaleTitle;

  /// No description provided for @backLabel.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backLabel;

  /// No description provided for @noCustomerLabel.
  ///
  /// In en, this message translates to:
  /// **'No customer'**
  String get noCustomerLabel;

  /// No description provided for @customerNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Customer #{id}'**
  String customerNumberLabel(int id);

  /// No description provided for @immediateLabel.
  ///
  /// In en, this message translates to:
  /// **'Immediate'**
  String get immediateLabel;

  /// No description provided for @noInstallmentsRegistered.
  ///
  /// In en, this message translates to:
  /// **'No installments registered.'**
  String get noInstallmentsRegistered;

  /// No description provided for @paidInInstallmentsMessage.
  ///
  /// In en, this message translates to:
  /// **'Paid in {count} {count, plural, =0{installments} one{installment} other{installments}}:'**
  String paidInInstallmentsMessage(int count);

  /// No description provided for @splashLoading.
  ///
  /// In en, this message translates to:
  /// **'Preparing your experience...'**
  String get splashLoading;

  /// No description provided for @switchStoreTooltip.
  ///
  /// In en, this message translates to:
  /// **'Switch store'**
  String get switchStoreTooltip;

  /// No description provided for @storesTitle.
  ///
  /// In en, this message translates to:
  /// **'Stores'**
  String get storesTitle;

  /// No description provided for @newStore.
  ///
  /// In en, this message translates to:
  /// **'New store'**
  String get newStore;

  /// No description provided for @storeNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Store name'**
  String get storeNameLabel;

  /// No description provided for @storeNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Store name is required'**
  String get storeNameRequired;

  /// No description provided for @renameStoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename store'**
  String get renameStoreTitle;

  /// No description provided for @setAsDefault.
  ///
  /// In en, this message translates to:
  /// **'Set as default'**
  String get setAsDefault;

  /// No description provided for @defaultStoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultStoreLabel;

  /// No description provided for @deleteStoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete store'**
  String get deleteStoreTitle;

  /// No description provided for @confirmDeleteStoreMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"?'**
  String confirmDeleteStoreMessage(String name);

  /// No description provided for @couldNotDeleteStore.
  ///
  /// In en, this message translates to:
  /// **'Could not delete store.'**
  String get couldNotDeleteStore;

  /// No description provided for @couldNotCreateStore.
  ///
  /// In en, this message translates to:
  /// **'Could not create store.'**
  String get couldNotCreateStore;

  /// No description provided for @couldNotRenameStore.
  ///
  /// In en, this message translates to:
  /// **'Could not rename store.'**
  String get couldNotRenameStore;

  /// No description provided for @currentStoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Current store'**
  String get currentStoreLabel;

  /// No description provided for @allStoresLabel.
  ///
  /// In en, this message translates to:
  /// **'All stores'**
  String get allStoresLabel;

  /// No description provided for @perStoreBreakdownTitle.
  ///
  /// In en, this message translates to:
  /// **'Breakdown by store'**
  String get perStoreBreakdownTitle;

  /// No description provided for @consolidatedStatementLabel.
  ///
  /// In en, this message translates to:
  /// **'Consolidated statement (all stores)'**
  String get consolidatedStatementLabel;

  /// No description provided for @consolidatedStatementDescription.
  ///
  /// In en, this message translates to:
  /// **'Sums the data from every store for this period'**
  String get consolidatedStatementDescription;

  /// No description provided for @archiveStoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Archive store'**
  String get archiveStoreTitle;

  /// No description provided for @confirmArchiveStoreMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to archive \"{name}\"? This store\'s data (sales, customers, statements) is preserved, but it will no longer appear as an active store.'**
  String confirmArchiveStoreMessage(Object name);

  /// No description provided for @archiveLabel.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archiveLabel;

  /// No description provided for @couldNotArchiveStore.
  ///
  /// In en, this message translates to:
  /// **'Could not archive the store.'**
  String get couldNotArchiveStore;

  /// No description provided for @backupRestoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore'**
  String get backupRestoreTitle;

  /// No description provided for @backupSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Create backup'**
  String get backupSectionTitle;

  /// No description provided for @backupSectionDescription.
  ///
  /// In en, this message translates to:
  /// **'Generates a file with all your data and opens the share menu so you can save it somewhere safe (cloud drive, email, USB...). Since the app is fully offline, this file is your only way to recover data or move it to another device.'**
  String get backupSectionDescription;

  /// No description provided for @createBackupButton.
  ///
  /// In en, this message translates to:
  /// **'Create backup'**
  String get createBackupButton;

  /// No description provided for @backupCreatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Backup saved to: {path}'**
  String backupCreatedMessage(String path);

  /// No description provided for @backupFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Could not create the backup.'**
  String get backupFailedMessage;

  /// No description provided for @restoreSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore backup'**
  String get restoreSectionTitle;

  /// No description provided for @restoreSectionDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose a previously created backup file. Data already on this device is kept — only missing or older records are updated with the backup\'s data.'**
  String get restoreSectionDescription;

  /// No description provided for @restoreBackupButton.
  ///
  /// In en, this message translates to:
  /// **'Choose backup file'**
  String get restoreBackupButton;

  /// No description provided for @restoreConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore backup?'**
  String get restoreConfirmTitle;

  /// No description provided for @restoreConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This merges the backup into your current data. Nothing on this device is deleted: for each record, whichever version is more recent — the one already here or the one in the backup — is kept.'**
  String get restoreConfirmMessage;

  /// No description provided for @restoreConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get restoreConfirmButton;

  /// No description provided for @restoreSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Restore complete: {inserted} new, {updated} updated, {skipped} unchanged.'**
  String restoreSuccessMessage(int inserted, int updated, int skipped);

  /// No description provided for @saleCreatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Sale created successfully.'**
  String get saleCreatedMessage;

  /// No description provided for @discardSaleTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard sale?'**
  String get discardSaleTitle;

  /// No description provided for @discardSaleMessage.
  ///
  /// In en, this message translates to:
  /// **'The data you entered will be lost.'**
  String get discardSaleMessage;

  /// No description provided for @discardLabel.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discardLabel;

  /// No description provided for @keepEditingLabel.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get keepEditingLabel;

  /// No description provided for @restoreFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Could not restore the backup.'**
  String get restoreFailedMessage;

  /// No description provided for @shareSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Share backup'**
  String get shareSectionTitle;

  /// No description provided for @shareSectionDescriptionEmpty.
  ///
  /// In en, this message translates to:
  /// **'Create a backup first, then you can share that exact file (email, cloud drive, USB...) if you want an extra copy off this device.'**
  String get shareSectionDescriptionEmpty;

  /// No description provided for @shareSectionDescriptionReady.
  ///
  /// In en, this message translates to:
  /// **'Ready to share: {fileName}'**
  String shareSectionDescriptionReady(String fileName);

  /// No description provided for @shareBackupButton.
  ///
  /// In en, this message translates to:
  /// **'Share backup'**
  String get shareBackupButton;

  /// No description provided for @shareFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Could not open the share menu.'**
  String get shareFailedMessage;

  /// No description provided for @generatePdfTooltip.
  ///
  /// In en, this message translates to:
  /// **'Generate PDF'**
  String get generatePdfTooltip;

  /// No description provided for @referenceColumnLabel.
  ///
  /// In en, this message translates to:
  /// **'Ref.'**
  String get referenceColumnLabel;

  /// No description provided for @dateColumnLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateColumnLabel;

  /// No description provided for @storeColumnLabel.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get storeColumnLabel;

  /// No description provided for @periodToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get periodToday;

  /// No description provided for @periodLast24Hours.
  ///
  /// In en, this message translates to:
  /// **'1 day'**
  String get periodLast24Hours;

  /// No description provided for @periodOneWeek.
  ///
  /// In en, this message translates to:
  /// **'1 week'**
  String get periodOneWeek;

  /// No description provided for @periodOneMonth.
  ///
  /// In en, this message translates to:
  /// **'1 month'**
  String get periodOneMonth;

  /// No description provided for @periodThreeMonths.
  ///
  /// In en, this message translates to:
  /// **'3 months'**
  String get periodThreeMonths;

  /// No description provided for @periodSixMonths.
  ///
  /// In en, this message translates to:
  /// **'6 months'**
  String get periodSixMonths;

  /// No description provided for @periodOneYear.
  ///
  /// In en, this message translates to:
  /// **'1 year'**
  String get periodOneYear;

  /// No description provided for @periodCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get periodCustom;

  /// No description provided for @splashTip1.
  ///
  /// In en, this message translates to:
  /// **'Register a sale in seconds, right from your phone.'**
  String get splashTip1;

  /// No description provided for @splashTip2.
  ///
  /// In en, this message translates to:
  /// **'Every sale gets its own reference. No more lost notes.'**
  String get splashTip2;

  /// No description provided for @splashTip3.
  ///
  /// In en, this message translates to:
  /// **'Cash, M-Pesa, e-Mola or bank transfer: you choose how you get paid.'**
  String get splashTip3;

  /// No description provided for @splashTip4.
  ///
  /// In en, this message translates to:
  /// **'Know exactly how much you sold today.'**
  String get splashTip4;

  /// No description provided for @splashTip5.
  ///
  /// In en, this message translates to:
  /// **'Sold on credit? Never forget who owes you.'**
  String get splashTip5;

  /// No description provided for @splashTip6.
  ///
  /// In en, this message translates to:
  /// **'Register each payment and watch the debt shrink.'**
  String get splashTip6;

  /// No description provided for @splashTip7.
  ///
  /// In en, this message translates to:
  /// **'Split a debt into installments, one payment at a time.'**
  String get splashTip7;

  /// No description provided for @splashTip8.
  ///
  /// In en, this message translates to:
  /// **'A badge shows how many credit sales are still open.'**
  String get splashTip8;

  /// No description provided for @splashTip9.
  ///
  /// In en, this message translates to:
  /// **'Track every expense, from rent to restocking.'**
  String get splashTip9;

  /// No description provided for @splashTip10.
  ///
  /// In en, this message translates to:
  /// **'Keep your suppliers organized in one place.'**
  String get splashTip10;

  /// No description provided for @splashTip11.
  ///
  /// In en, this message translates to:
  /// **'Money going out matters as much as money coming in.'**
  String get splashTip11;

  /// No description provided for @splashTip12.
  ///
  /// In en, this message translates to:
  /// **'Filter expenses by supplier or date and find anything fast.'**
  String get splashTip12;

  /// No description provided for @splashTip13.
  ///
  /// In en, this message translates to:
  /// **'Generate a financial statement for any period.'**
  String get splashTip13;

  /// No description provided for @splashTip14.
  ///
  /// In en, this message translates to:
  /// **'Sales minus expenses: your balance, crystal clear.'**
  String get splashTip14;

  /// No description provided for @splashTip15.
  ///
  /// In en, this message translates to:
  /// **'Turn your statement into a PDF, ready to print or share.'**
  String get splashTip15;

  /// No description provided for @splashTip16.
  ///
  /// In en, this message translates to:
  /// **'Statements are frozen in time, so the numbers never change on you.'**
  String get splashTip16;

  /// No description provided for @splashTip17.
  ///
  /// In en, this message translates to:
  /// **'Several stores? Manage them all in one app.'**
  String get splashTip17;

  /// No description provided for @splashTip18.
  ///
  /// In en, this message translates to:
  /// **'Switch between stores with a single tap.'**
  String get splashTip18;

  /// No description provided for @splashTip19.
  ///
  /// In en, this message translates to:
  /// **'See the whole group in one consolidated statement.'**
  String get splashTip19;

  /// No description provided for @splashTip20.
  ///
  /// In en, this message translates to:
  /// **'Compare how each store contributes to your total.'**
  String get splashTip20;

  /// No description provided for @splashTip21.
  ///
  /// In en, this message translates to:
  /// **'Know your customers and their purchase history.'**
  String get splashTip21;

  /// No description provided for @splashTip22.
  ///
  /// In en, this message translates to:
  /// **'Works fully offline. No internet, no problem.'**
  String get splashTip22;

  /// No description provided for @splashTip23.
  ///
  /// In en, this message translates to:
  /// **'Your data stays on your device, protected by your password.'**
  String get splashTip23;

  /// No description provided for @splashTip24.
  ///
  /// In en, this message translates to:
  /// **'Create a backup today and sleep easy tomorrow.'**
  String get splashTip24;

  /// No description provided for @welcomeToMiniTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Mini'**
  String get welcomeToMiniTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Do you already have a backup from another device or a previous installation?'**
  String get welcomeSubtitle;

  /// No description provided for @welcomeRestoreButton.
  ///
  /// In en, this message translates to:
  /// **'Restore from backup'**
  String get welcomeRestoreButton;

  /// No description provided for @welcomeCreateNewButton.
  ///
  /// In en, this message translates to:
  /// **'Start from scratch'**
  String get welcomeCreateNewButton;

  /// No description provided for @restorePreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup found'**
  String get restorePreviewTitle;

  /// No description provided for @restorePreviewSummary.
  ///
  /// In en, this message translates to:
  /// **'Reference: {reference}\nDate: {date}\nAccount: {userName}\nStores: {storeCount}\nSales: {saleCount}'**
  String restorePreviewSummary(
    String reference,
    String date,
    String userName,
    int storeCount,
    int saleCount,
  );

  /// No description provided for @restorePreviewConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restorePreviewConfirmButton;

  /// No description provided for @restoreFreshSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Backup restored. Sign in with the password from that backup.'**
  String get restoreFreshSuccessMessage;

  /// No description provided for @backupErrorInvalidFile.
  ///
  /// In en, this message translates to:
  /// **'The selected file is not a valid JSON backup.'**
  String get backupErrorInvalidFile;

  /// No description provided for @backupErrorUnrecognized.
  ///
  /// In en, this message translates to:
  /// **'This file is not a recognized backup.'**
  String get backupErrorUnrecognized;

  /// No description provided for @backupErrorNoUser.
  ///
  /// In en, this message translates to:
  /// **'This backup has no account data, so it cannot be restored here.'**
  String get backupErrorNoUser;

  /// No description provided for @backupErrorNoStore.
  ///
  /// In en, this message translates to:
  /// **'This backup has no stores, so it cannot be restored here.'**
  String get backupErrorNoStore;

  /// No description provided for @backupErrorNewerVersion.
  ///
  /// In en, this message translates to:
  /// **'This backup was created by a newer version of the app. Update the app and try again.'**
  String get backupErrorNewerVersion;

  /// No description provided for @backupErrorIntegrity.
  ///
  /// In en, this message translates to:
  /// **'The backup data is inconsistent. Nothing was restored.'**
  String get backupErrorIntegrity;

  /// No description provided for @activationTitle.
  ///
  /// In en, this message translates to:
  /// **'Activate Mini'**
  String get activationTitle;

  /// No description provided for @activationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the activation code you received with your purchase. An internet connection is needed only this once.'**
  String get activationSubtitle;

  /// No description provided for @activationCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Activation code'**
  String get activationCodeLabel;

  /// No description provided for @activationCodeRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your activation code'**
  String get activationCodeRequired;

  /// No description provided for @activationButton.
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get activationButton;

  /// No description provided for @activationErrorInvalidCode.
  ///
  /// In en, this message translates to:
  /// **'This code is not valid. Check it and try again.'**
  String get activationErrorInvalidCode;

  /// No description provided for @activationErrorAlreadyUsed.
  ///
  /// In en, this message translates to:
  /// **'This code is already in use on another device. Contact support to move your license.'**
  String get activationErrorAlreadyUsed;

  /// No description provided for @activationErrorRevoked.
  ///
  /// In en, this message translates to:
  /// **'This license is no longer active. Contact support.'**
  String get activationErrorRevoked;

  /// No description provided for @activationErrorRateLimited.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Wait a few minutes and try again.'**
  String get activationErrorRateLimited;

  /// No description provided for @activationErrorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Could not reach the activation server. Check your internet connection and try again.'**
  String get activationErrorNetwork;

  /// No description provided for @activationErrorDevice.
  ///
  /// In en, this message translates to:
  /// **'Could not identify this device.'**
  String get activationErrorDevice;

  /// No description provided for @activationErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Activation failed. Please try again.'**
  String get activationErrorGeneric;

  /// No description provided for @revenueMixTitle.
  ///
  /// In en, this message translates to:
  /// **'Revenue mix'**
  String get revenueMixTitle;

  /// No description provided for @immediateRevenueLabel.
  ///
  /// In en, this message translates to:
  /// **'Immediate revenue'**
  String get immediateRevenueLabel;

  /// No description provided for @revenueTrendTitle.
  ///
  /// In en, this message translates to:
  /// **'Revenue over time'**
  String get revenueTrendTitle;

  /// No description provided for @peakLabel.
  ///
  /// In en, this message translates to:
  /// **'Peak'**
  String get peakLabel;

  /// No description provided for @catalogTitle.
  ///
  /// In en, this message translates to:
  /// **'Catalog'**
  String get catalogTitle;

  /// No description provided for @newCatalogItem.
  ///
  /// In en, this message translates to:
  /// **'New item'**
  String get newCatalogItem;

  /// No description provided for @editCatalogItem.
  ///
  /// In en, this message translates to:
  /// **'Edit item'**
  String get editCatalogItem;

  /// No description provided for @createCatalogItem.
  ///
  /// In en, this message translates to:
  /// **'Create item'**
  String get createCatalogItem;

  /// No description provided for @noCatalogItemsYet.
  ///
  /// In en, this message translates to:
  /// **'No products or services registered yet.'**
  String get noCatalogItemsYet;

  /// No description provided for @deleteCatalogItem.
  ///
  /// In en, this message translates to:
  /// **'Delete item'**
  String get deleteCatalogItem;

  /// No description provided for @confirmDeleteCatalogItemMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"? Past sales keep their history.'**
  String confirmDeleteCatalogItemMessage(String name);

  /// No description provided for @searchLabel.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchLabel;

  /// No description provided for @productLabel.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get productLabel;

  /// No description provided for @serviceLabel.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get serviceLabel;

  /// No description provided for @itemNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get itemNameLabel;

  /// No description provided for @itemCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Code (optional)'**
  String get itemCodeLabel;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// No description provided for @noCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'No category'**
  String get noCategoryLabel;

  /// No description provided for @unitLabel.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unitLabel;

  /// No description provided for @salePriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Sale price'**
  String get salePriceLabel;

  /// No description provided for @costPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Cost price'**
  String get costPriceLabel;

  /// No description provided for @costPriceHelperText.
  ///
  /// In en, this message translates to:
  /// **'Reference cost. Updated automatically when you register a purchase.'**
  String get costPriceHelperText;

  /// No description provided for @trackStockLabel.
  ///
  /// In en, this message translates to:
  /// **'Track stock'**
  String get trackStockLabel;

  /// No description provided for @trackStockHelperText.
  ///
  /// In en, this message translates to:
  /// **'Quantity goes down with each sale and up with each purchase.'**
  String get trackStockHelperText;

  /// No description provided for @minStockLabel.
  ///
  /// In en, this message translates to:
  /// **'Minimum stock (alert)'**
  String get minStockLabel;

  /// No description provided for @activeLabel.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get activeLabel;

  /// No description provided for @inactiveLabel.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactiveLabel;

  /// No description provided for @newCategory.
  ///
  /// In en, this message translates to:
  /// **'New category'**
  String get newCategory;

  /// No description provided for @renameCategory.
  ///
  /// In en, this message translates to:
  /// **'Rename category'**
  String get renameCategory;

  /// No description provided for @categoryNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Category name'**
  String get categoryNameLabel;

  /// No description provided for @deleteCategory.
  ///
  /// In en, this message translates to:
  /// **'Delete category'**
  String get deleteCategory;

  /// No description provided for @confirmDeleteCategoryMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"? Products in this category will be kept, just without a category.'**
  String confirmDeleteCategoryMessage(String name);

  /// No description provided for @noCategoriesYet.
  ///
  /// In en, this message translates to:
  /// **'No categories yet.'**
  String get noCategoriesYet;

  /// No description provided for @stockTitle.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get stockTitle;

  /// No description provided for @lowStockFilterLabel.
  ///
  /// In en, this message translates to:
  /// **'Low stock ({count})'**
  String lowStockFilterLabel(int count);

  /// No description provided for @belowMinimumLabel.
  ///
  /// In en, this message translates to:
  /// **'Below minimum'**
  String get belowMinimumLabel;

  /// No description provided for @stockMinLabel.
  ///
  /// In en, this message translates to:
  /// **'Min: {min}'**
  String stockMinLabel(String min);

  /// No description provided for @noStockItemsYet.
  ///
  /// In en, this message translates to:
  /// **'No products registered yet.'**
  String get noStockItemsYet;

  /// No description provided for @noInitialStockLabel.
  ///
  /// In en, this message translates to:
  /// **'No initial stock'**
  String get noInitialStockLabel;

  /// No description provided for @deletedLabel.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get deletedLabel;

  /// No description provided for @stockHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Stock history'**
  String get stockHistoryTitle;

  /// No description provided for @noMovementsYet.
  ///
  /// In en, this message translates to:
  /// **'No movements yet.'**
  String get noMovementsYet;

  /// No description provided for @stockPurchaseButton.
  ///
  /// In en, this message translates to:
  /// **'Register purchase'**
  String get stockPurchaseButton;

  /// No description provided for @stockPurchaseTitle.
  ///
  /// In en, this message translates to:
  /// **'Stock purchase'**
  String get stockPurchaseTitle;

  /// No description provided for @initialStockButton.
  ///
  /// In en, this message translates to:
  /// **'Set initial stock'**
  String get initialStockButton;

  /// No description provided for @adjustStockButton.
  ///
  /// In en, this message translates to:
  /// **'Adjust stock'**
  String get adjustStockButton;

  /// No description provided for @quantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantityLabel;

  /// No description provided for @unitCostLabel.
  ///
  /// In en, this message translates to:
  /// **'Unit cost'**
  String get unitCostLabel;

  /// No description provided for @unitCostOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Unit cost (optional)'**
  String get unitCostOptionalLabel;

  /// No description provided for @purchaseTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total: {amount}'**
  String purchaseTotalLabel(String amount);

  /// No description provided for @enterValidQuantityMessage.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid quantity'**
  String get enterValidQuantityMessage;

  /// No description provided for @noteRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'A note is required for this movement'**
  String get noteRequiredMessage;

  /// No description provided for @movementTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Movement type'**
  String get movementTypeLabel;

  /// No description provided for @stockMovementSaved.
  ///
  /// In en, this message translates to:
  /// **'Movement registered.'**
  String get stockMovementSaved;

  /// No description provided for @stockPurchaseExpenseDescription.
  ///
  /// In en, this message translates to:
  /// **'Acquisition: {quantity} × {name}'**
  String stockPurchaseExpenseDescription(String quantity, String name);

  /// No description provided for @stockPurchaseTag.
  ///
  /// In en, this message translates to:
  /// **'Stock purchase'**
  String get stockPurchaseTag;

  /// No description provided for @stockExpenseLockedMessage.
  ///
  /// In en, this message translates to:
  /// **'This expense comes from a stock purchase and cannot be edited or deleted.'**
  String get stockExpenseLockedMessage;

  /// No description provided for @movementInitial.
  ///
  /// In en, this message translates to:
  /// **'Initial stock'**
  String get movementInitial;

  /// No description provided for @movementPurchase.
  ///
  /// In en, this message translates to:
  /// **'Purchase'**
  String get movementPurchase;

  /// No description provided for @movementSale.
  ///
  /// In en, this message translates to:
  /// **'Sale'**
  String get movementSale;

  /// No description provided for @movementSaleReversal.
  ///
  /// In en, this message translates to:
  /// **'Sale reversal'**
  String get movementSaleReversal;

  /// No description provided for @movementAdjustmentIn.
  ///
  /// In en, this message translates to:
  /// **'Adjustment (in)'**
  String get movementAdjustmentIn;

  /// No description provided for @movementAdjustmentOut.
  ///
  /// In en, this message translates to:
  /// **'Exit (internal use / correction)'**
  String get movementAdjustmentOut;

  /// No description provided for @movementLoss.
  ///
  /// In en, this message translates to:
  /// **'Loss'**
  String get movementLoss;

  /// No description provided for @saleItemsTitle.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get saleItemsTitle;

  /// No description provided for @addItemButton.
  ///
  /// In en, this message translates to:
  /// **'Add item'**
  String get addItemButton;

  /// No description provided for @selectItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Select item'**
  String get selectItemTitle;

  /// No description provided for @removeItemTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove item'**
  String get removeItemTooltip;

  /// No description provided for @unitPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Unit price'**
  String get unitPriceLabel;

  /// No description provided for @lineSubtotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Subtotal: {amount}'**
  String lineSubtotalLabel(String amount);

  /// No description provided for @stockAvailableLabel.
  ///
  /// In en, this message translates to:
  /// **'In stock: {quantity} {unit}'**
  String stockAvailableLabel(String quantity, String unit);

  /// No description provided for @outOfStockLabel.
  ///
  /// In en, this message translates to:
  /// **'Out of stock'**
  String get outOfStockLabel;

  /// No description provided for @noSellableItemsYet.
  ///
  /// In en, this message translates to:
  /// **'No active products or services in the catalog yet.'**
  String get noSellableItemsYet;

  /// No description provided for @reportsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reportsTitle;

  /// No description provided for @lowStockTabLabel.
  ///
  /// In en, this message translates to:
  /// **'Low stock'**
  String get lowStockTabLabel;

  /// No description provided for @stockValueLabel.
  ///
  /// In en, this message translates to:
  /// **'Stock value'**
  String get stockValueLabel;

  /// No description provided for @marginTabLabel.
  ///
  /// In en, this message translates to:
  /// **'Margin'**
  String get marginTabLabel;

  /// No description provided for @noLowStockItems.
  ///
  /// In en, this message translates to:
  /// **'No products below their minimum stock.'**
  String get noLowStockItems;

  /// No description provided for @noStockValueYet.
  ///
  /// In en, this message translates to:
  /// **'No stock on hand yet.'**
  String get noStockValueYet;

  /// No description provided for @itemsWithoutCostNote.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item has no cost price and is valued at 0.} other{{count} items have no cost price and are valued at 0.}}'**
  String itemsWithoutCostNote(int count);

  /// No description provided for @noCostLabel.
  ///
  /// In en, this message translates to:
  /// **'No cost set'**
  String get noCostLabel;

  /// No description provided for @marginNoSalesYet.
  ///
  /// In en, this message translates to:
  /// **'No sales with items in this period.'**
  String get marginNoSalesYet;

  /// No description provided for @costOfGoodsLabel.
  ///
  /// In en, this message translates to:
  /// **'Cost of goods sold'**
  String get costOfGoodsLabel;

  /// No description provided for @marginLabel.
  ///
  /// In en, this message translates to:
  /// **'Margin'**
  String get marginLabel;

  /// No description provided for @reportsInfoNote.
  ///
  /// In en, this message translates to:
  /// **'For information only. These figures are not part of the statement balance, which stays cash-based.'**
  String get reportsInfoNote;

  /// No description provided for @productsTitle.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get productsTitle;

  /// No description provided for @servicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get servicesTitle;

  /// No description provided for @productCategoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Product categories'**
  String get productCategoriesTitle;

  /// No description provided for @newProduct.
  ///
  /// In en, this message translates to:
  /// **'New product'**
  String get newProduct;

  /// No description provided for @editProduct.
  ///
  /// In en, this message translates to:
  /// **'Edit product'**
  String get editProduct;

  /// No description provided for @createProduct.
  ///
  /// In en, this message translates to:
  /// **'Create product'**
  String get createProduct;

  /// No description provided for @newService.
  ///
  /// In en, this message translates to:
  /// **'New service'**
  String get newService;

  /// No description provided for @editService.
  ///
  /// In en, this message translates to:
  /// **'Edit service'**
  String get editService;

  /// No description provided for @createService.
  ///
  /// In en, this message translates to:
  /// **'Create service'**
  String get createService;

  /// No description provided for @noProductsYet.
  ///
  /// In en, this message translates to:
  /// **'No products registered yet.'**
  String get noProductsYet;

  /// No description provided for @noServicesYet.
  ///
  /// In en, this message translates to:
  /// **'No services registered yet.'**
  String get noServicesYet;

  /// No description provided for @initialQuantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Initial quantity'**
  String get initialQuantityLabel;

  /// No description provided for @initialQuantityHelperText.
  ///
  /// In en, this message translates to:
  /// **'Stock you already have. No expense is created. For new purchases, create the product and then use \"Move stock\".'**
  String get initialQuantityHelperText;

  /// No description provided for @serviceUnitHelperText.
  ///
  /// In en, this message translates to:
  /// **'e.g. hour, service'**
  String get serviceUnitHelperText;

  /// No description provided for @moveStockButton.
  ///
  /// In en, this message translates to:
  /// **'Move stock'**
  String get moveStockButton;

  /// No description provided for @movementEntryOption.
  ///
  /// In en, this message translates to:
  /// **'Entry (purchase)'**
  String get movementEntryOption;

  /// No description provided for @insufficientStockMessage.
  ///
  /// In en, this message translates to:
  /// **'Only {quantity} {unit} in stock'**
  String insufficientStockMessage(String quantity, String unit);

  /// No description provided for @cannotDeleteProductWithStockMessage.
  ///
  /// In en, this message translates to:
  /// **'This product still has stock. Register an Exit or a Loss first (or set the product inactive).'**
  String get cannotDeleteProductWithStockMessage;

  /// No description provided for @allTypesLabel.
  ///
  /// In en, this message translates to:
  /// **'All types'**
  String get allTypesLabel;

  /// No description provided for @allProductsLabel.
  ///
  /// In en, this message translates to:
  /// **'All products'**
  String get allProductsLabel;

  /// No description provided for @loadMoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get loadMoreLabel;

  /// No description provided for @noLowStockProductsMessage.
  ///
  /// In en, this message translates to:
  /// **'No products with low stock.'**
  String get noLowStockProductsMessage;

  /// No description provided for @saleDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Sale details'**
  String get saleDetailTitle;

  /// No description provided for @okLabel.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get okLabel;

  /// No description provided for @customItemOption.
  ///
  /// In en, this message translates to:
  /// **'Custom item'**
  String get customItemOption;

  /// No description provided for @customItemOptionHint.
  ///
  /// In en, this message translates to:
  /// **'Type a name and a price (no stock)'**
  String get customItemOptionHint;

  /// No description provided for @customItemDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom item'**
  String get customItemDialogTitle;

  /// No description provided for @customItemNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Item name'**
  String get customItemNameLabel;

  /// No description provided for @customItemNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter the item name'**
  String get customItemNameRequired;

  /// No description provided for @customItemTag.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get customItemTag;

  /// No description provided for @outOfStockNotice.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" is out of stock and cannot be sold.'**
  String outOfStockNotice(String name);

  /// No description provided for @insufficientStockDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Not enough stock'**
  String get insufficientStockDialogTitle;

  /// No description provided for @insufficientStockDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Not enough stock of \"{name}\". Only {quantity} {unit} in stock.'**
  String insufficientStockDialogMessage(
    String name,
    String quantity,
    String unit,
  );

  /// No description provided for @itemUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Item unavailable'**
  String get itemUnavailableTitle;

  /// No description provided for @itemUnavailableMessage.
  ///
  /// In en, this message translates to:
  /// **'One of the items is no longer available (it was deactivated or deleted). It is marked in the cart; remove it to continue.'**
  String get itemUnavailableMessage;

  /// No description provided for @itemUnavailableLine.
  ///
  /// In en, this message translates to:
  /// **'This item is no longer available'**
  String get itemUnavailableLine;

  /// No description provided for @saleNeedsItemsMessage.
  ///
  /// In en, this message translates to:
  /// **'Add at least one item to the sale.'**
  String get saleNeedsItemsMessage;

  /// No description provided for @cartClearedStoreChangedMessage.
  ///
  /// In en, this message translates to:
  /// **'The store changed, so the items were removed from the sale.'**
  String get cartClearedStoreChangedMessage;

  /// No description provided for @lossesTabLabel.
  ///
  /// In en, this message translates to:
  /// **'Losses'**
  String get lossesTabLabel;

  /// No description provided for @lossesTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Value of losses'**
  String get lossesTotalLabel;

  /// No description provided for @noLossesInPeriod.
  ///
  /// In en, this message translates to:
  /// **'No losses in this period.'**
  String get noLossesInPeriod;

  /// No description provided for @customItemsSalesTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom items'**
  String get customItemsSalesTitle;

  /// No description provided for @customItemsSalesNote.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 line sold} other{{count} lines sold}} without cost. Not included in the margin above.'**
  String customItemsSalesNote(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
