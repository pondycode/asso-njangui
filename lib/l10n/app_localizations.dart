import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr')
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'AssoNjangui'**
  String get appTitle;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @members.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get members;

  /// No description provided for @funds.
  ///
  /// In en, this message translates to:
  /// **'Funds'**
  String get funds;

  /// No description provided for @loans.
  ///
  /// In en, this message translates to:
  /// **'Loans'**
  String get loans;

  /// No description provided for @transactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirth;

  /// No description provided for @membershipDate.
  ///
  /// In en, this message translates to:
  /// **'Membership Date'**
  String get membershipDate;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

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

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @approved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get approved;

  /// No description provided for @totalSavings.
  ///
  /// In en, this message translates to:
  /// **'Total Savings'**
  String get totalSavings;

  /// No description provided for @investments.
  ///
  /// In en, this message translates to:
  /// **'Investments'**
  String get investments;

  /// No description provided for @emergencyFund.
  ///
  /// In en, this message translates to:
  /// **'Emergency Fund'**
  String get emergencyFund;

  /// No description provided for @outstandingLoans.
  ///
  /// In en, this message translates to:
  /// **'Outstanding Loans'**
  String get outstandingLoans;

  /// No description provided for @totalMembers.
  ///
  /// In en, this message translates to:
  /// **'Total Members'**
  String get totalMembers;

  /// No description provided for @activeMembers.
  ///
  /// In en, this message translates to:
  /// **'Active Members'**
  String get activeMembers;

  /// No description provided for @communityFinancialManagement.
  ///
  /// In en, this message translates to:
  /// **'Community Financial Management'**
  String get communityFinancialManagement;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get changeLanguage;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @financialOverview.
  ///
  /// In en, this message translates to:
  /// **'Financial Overview'**
  String get financialOverview;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @addMember.
  ///
  /// In en, this message translates to:
  /// **'Add Member'**
  String get addMember;

  /// No description provided for @contribute.
  ///
  /// In en, this message translates to:
  /// **'Contribute'**
  String get contribute;

  /// No description provided for @newLoan.
  ///
  /// In en, this message translates to:
  /// **'New Loan'**
  String get newLoan;

  /// No description provided for @fundsOverview.
  ///
  /// In en, this message translates to:
  /// **'Funds Overview'**
  String get fundsOverview;

  /// No description provided for @noFundsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No funds available'**
  String get noFundsAvailable;

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivity;

  /// No description provided for @noRecentActivity.
  ///
  /// In en, this message translates to:
  /// **'No recent activity'**
  String get noRecentActivity;

  /// No description provided for @unknownMember.
  ///
  /// In en, this message translates to:
  /// **'Unknown Member'**
  String get unknownMember;

  /// No description provided for @searchMembers.
  ///
  /// In en, this message translates to:
  /// **'Search members...'**
  String get searchMembers;

  /// No description provided for @searchFunds.
  ///
  /// In en, this message translates to:
  /// **'Search funds...'**
  String get searchFunds;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @filterMembers.
  ///
  /// In en, this message translates to:
  /// **'Filter Members'**
  String get filterMembers;

  /// No description provided for @filterByStatus.
  ///
  /// In en, this message translates to:
  /// **'Filter by status:'**
  String get filterByStatus;

  /// No description provided for @suspended.
  ///
  /// In en, this message translates to:
  /// **'Suspended'**
  String get suspended;

  /// No description provided for @noMembersFound.
  ///
  /// In en, this message translates to:
  /// **'No members found matching your criteria'**
  String get noMembersFound;

  /// No description provided for @noMembersYet.
  ///
  /// In en, this message translates to:
  /// **'No members yet'**
  String get noMembersYet;

  /// No description provided for @tryAdjustingFilters.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search or filters'**
  String get tryAdjustingFilters;

  /// No description provided for @addFirstMember.
  ///
  /// In en, this message translates to:
  /// **'Add your first member to get started'**
  String get addFirstMember;

  /// No description provided for @investmentFunds.
  ///
  /// In en, this message translates to:
  /// **'Investment Funds'**
  String get investmentFunds;

  /// No description provided for @bulkContribution.
  ///
  /// In en, this message translates to:
  /// **'Bulk Contribution'**
  String get bulkContribution;

  /// No description provided for @contributeToMultipleFunds.
  ///
  /// In en, this message translates to:
  /// **'Contribute to multiple funds'**
  String get contributeToMultipleFunds;

  /// No description provided for @exportFundData.
  ///
  /// In en, this message translates to:
  /// **'Export Fund Data'**
  String get exportFundData;

  /// No description provided for @downloadFundInfo.
  ///
  /// In en, this message translates to:
  /// **'Download fund information'**
  String get downloadFundInfo;

  /// No description provided for @fundAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Fund Analytics'**
  String get fundAnalytics;

  /// No description provided for @viewPerformanceMetrics.
  ///
  /// In en, this message translates to:
  /// **'View performance metrics'**
  String get viewPerformanceMetrics;

  /// No description provided for @bulkOperations.
  ///
  /// In en, this message translates to:
  /// **'Bulk Operations'**
  String get bulkOperations;

  /// No description provided for @manageMultipleFunds.
  ///
  /// In en, this message translates to:
  /// **'Manage multiple funds'**
  String get manageMultipleFunds;

  /// No description provided for @fundSettings.
  ///
  /// In en, this message translates to:
  /// **'Fund Settings'**
  String get fundSettings;

  /// No description provided for @configureFundDefaults.
  ///
  /// In en, this message translates to:
  /// **'Configure fund defaults'**
  String get configureFundDefaults;

  /// No description provided for @refreshData.
  ///
  /// In en, this message translates to:
  /// **'Refresh Data'**
  String get refreshData;

  /// No description provided for @updateFundInfo.
  ///
  /// In en, this message translates to:
  /// **'Update fund information'**
  String get updateFundInfo;

  /// No description provided for @investment.
  ///
  /// In en, this message translates to:
  /// **'Investment'**
  String get investment;

  /// No description provided for @emergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get emergency;

  /// No description provided for @savings.
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get savings;

  /// No description provided for @loan.
  ///
  /// In en, this message translates to:
  /// **'Loan'**
  String get loan;

  /// No description provided for @totalFunds.
  ///
  /// In en, this message translates to:
  /// **'Total Funds'**
  String get totalFunds;

  /// No description provided for @totalValue.
  ///
  /// In en, this message translates to:
  /// **'Total Value'**
  String get totalValue;

  /// No description provided for @noFundsFound.
  ///
  /// In en, this message translates to:
  /// **'No funds found'**
  String get noFundsFound;

  /// No description provided for @createFirstFund.
  ///
  /// In en, this message translates to:
  /// **'Create your first investment fund'**
  String get createFirstFund;

  /// No description provided for @createFund.
  ///
  /// In en, this message translates to:
  /// **'Create Fund'**
  String get createFund;

  /// No description provided for @currentBalance.
  ///
  /// In en, this message translates to:
  /// **'Current Balance'**
  String get currentBalance;

  /// No description provided for @target.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get target;

  /// No description provided for @chooseExportFormat.
  ///
  /// In en, this message translates to:
  /// **'Choose export format:'**
  String get chooseExportFormat;

  /// No description provided for @csvFormat.
  ///
  /// In en, this message translates to:
  /// **'CSV Format'**
  String get csvFormat;

  /// No description provided for @spreadsheetCompatible.
  ///
  /// In en, this message translates to:
  /// **'Spreadsheet compatible'**
  String get spreadsheetCompatible;

  /// No description provided for @pdfReport.
  ///
  /// In en, this message translates to:
  /// **'PDF Report'**
  String get pdfReport;

  /// No description provided for @formattedDocument.
  ///
  /// In en, this message translates to:
  /// **'Formatted document'**
  String get formattedDocument;

  /// No description provided for @csvExportComingSoon.
  ///
  /// In en, this message translates to:
  /// **'CSV export feature coming soon'**
  String get csvExportComingSoon;

  /// No description provided for @pdfExportComingSoon.
  ///
  /// In en, this message translates to:
  /// **'PDF export feature coming soon'**
  String get pdfExportComingSoon;

  /// No description provided for @activeFunds.
  ///
  /// In en, this message translates to:
  /// **'Active Funds'**
  String get activeFunds;

  /// No description provided for @averageFundSize.
  ///
  /// In en, this message translates to:
  /// **'Average Fund Size'**
  String get averageFundSize;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @activateAllFunds.
  ///
  /// In en, this message translates to:
  /// **'Activate All Funds'**
  String get activateAllFunds;

  /// No description provided for @inactiveFunds.
  ///
  /// In en, this message translates to:
  /// **'inactive funds'**
  String get inactiveFunds;

  /// No description provided for @deactivateAllFunds.
  ///
  /// In en, this message translates to:
  /// **'Deactivate All Funds'**
  String get deactivateAllFunds;

  /// No description provided for @recalculateBalances.
  ///
  /// In en, this message translates to:
  /// **'Recalculate Balances'**
  String get recalculateBalances;

  /// No description provided for @updateAllFundBalances.
  ///
  /// In en, this message translates to:
  /// **'Update all fund balances'**
  String get updateAllFundBalances;

  /// No description provided for @defaultCurrency.
  ///
  /// In en, this message translates to:
  /// **'Default Currency'**
  String get defaultCurrency;

  /// No description provided for @centralAfricanFranc.
  ///
  /// In en, this message translates to:
  /// **'XAF (Central African Franc)'**
  String get centralAfricanFranc;

  /// No description provided for @currencySettingsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Currency settings coming soon'**
  String get currencySettingsComingSoon;

  /// No description provided for @defaultInterestRate.
  ///
  /// In en, this message translates to:
  /// **'Default Interest Rate'**
  String get defaultInterestRate;

  /// No description provided for @setDefaultRateForNewFunds.
  ///
  /// In en, this message translates to:
  /// **'Set default rate for new funds'**
  String get setDefaultRateForNewFunds;

  /// No description provided for @interestRateSettingsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Interest rate settings coming soon'**
  String get interestRateSettingsComingSoon;

  /// No description provided for @contributionFrequency.
  ///
  /// In en, this message translates to:
  /// **'Contribution Frequency'**
  String get contributionFrequency;

  /// No description provided for @defaultContributionSchedule.
  ///
  /// In en, this message translates to:
  /// **'Default contribution schedule'**
  String get defaultContributionSchedule;

  /// No description provided for @frequencySettingsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Frequency settings coming soon'**
  String get frequencySettingsComingSoon;

  /// No description provided for @fundDataRefreshed.
  ///
  /// In en, this message translates to:
  /// **'Fund data refreshed'**
  String get fundDataRefreshed;

  /// No description provided for @allFundsAlreadyActive.
  ///
  /// In en, this message translates to:
  /// **'All funds are already active'**
  String get allFundsAlreadyActive;

  /// No description provided for @activatedFunds.
  ///
  /// In en, this message translates to:
  /// **'Activated {count} funds'**
  String activatedFunds(Object count);

  /// No description provided for @errorActivatingFunds.
  ///
  /// In en, this message translates to:
  /// **'Error activating funds: {error}'**
  String errorActivatingFunds(Object error);

  /// No description provided for @confirmBulkDeactivation.
  ///
  /// In en, this message translates to:
  /// **'Confirm Bulk Deactivation'**
  String get confirmBulkDeactivation;

  /// No description provided for @confirmDeactivateAllFunds.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to deactivate all active funds? This will prevent new contributions to these funds.'**
  String get confirmDeactivateAllFunds;

  /// No description provided for @deactivateAll.
  ///
  /// In en, this message translates to:
  /// **'Deactivate All'**
  String get deactivateAll;

  /// No description provided for @bulkDeactivation.
  ///
  /// In en, this message translates to:
  /// **'Bulk deactivation'**
  String get bulkDeactivation;

  /// No description provided for @deactivatedFunds.
  ///
  /// In en, this message translates to:
  /// **'Deactivated {count} funds'**
  String deactivatedFunds(Object count);

  /// No description provided for @errorDeactivatingFunds.
  ///
  /// In en, this message translates to:
  /// **'Error deactivating funds: {error}'**
  String errorDeactivatingFunds(Object error);

  /// No description provided for @balanceRecalculationComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Balance recalculation feature coming soon'**
  String get balanceRecalculationComingSoon;

  /// No description provided for @recentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get recentTransactions;

  /// No description provided for @allTransactions.
  ///
  /// In en, this message translates to:
  /// **'All Transactions'**
  String get allTransactions;

  /// No description provided for @noTransactionsFound.
  ///
  /// In en, this message translates to:
  /// **'No transactions found'**
  String get noTransactionsFound;

  /// No description provided for @noTransactionsYet.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get noTransactionsYet;

  /// No description provided for @startMakingTransactions.
  ///
  /// In en, this message translates to:
  /// **'Start making transactions to see them here'**
  String get startMakingTransactions;

  /// No description provided for @credit.
  ///
  /// In en, this message translates to:
  /// **'Credit'**
  String get credit;

  /// No description provided for @debit.
  ///
  /// In en, this message translates to:
  /// **'Debit'**
  String get debit;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @member.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get member;

  /// No description provided for @fund.
  ///
  /// In en, this message translates to:
  /// **'Fund'**
  String get fund;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @loanRequests.
  ///
  /// In en, this message translates to:
  /// **'Loan Requests'**
  String get loanRequests;

  /// No description provided for @activeLoan.
  ///
  /// In en, this message translates to:
  /// **'Active Loans'**
  String get activeLoan;

  /// No description provided for @completedLoans.
  ///
  /// In en, this message translates to:
  /// **'Completed Loans'**
  String get completedLoans;

  /// No description provided for @noLoansFound.
  ///
  /// In en, this message translates to:
  /// **'No loans found'**
  String get noLoansFound;

  /// No description provided for @noLoansYet.
  ///
  /// In en, this message translates to:
  /// **'No loans yet'**
  String get noLoansYet;

  /// No description provided for @applyForFirstLoan.
  ///
  /// In en, this message translates to:
  /// **'Apply for your first loan to get started'**
  String get applyForFirstLoan;

  /// No description provided for @loanAmount.
  ///
  /// In en, this message translates to:
  /// **'Loan Amount'**
  String get loanAmount;

  /// No description provided for @interestRate.
  ///
  /// In en, this message translates to:
  /// **'Interest Rate'**
  String get interestRate;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @monthlyPayment.
  ///
  /// In en, this message translates to:
  /// **'Monthly Payment'**
  String get monthlyPayment;

  /// No description provided for @remainingBalance.
  ///
  /// In en, this message translates to:
  /// **'Remaining Balance'**
  String get remainingBalance;

  /// No description provided for @dueDate.
  ///
  /// In en, this message translates to:
  /// **'Due Date'**
  String get dueDate;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @contributions.
  ///
  /// In en, this message translates to:
  /// **'Contributions'**
  String get contributions;

  /// No description provided for @makeContribution.
  ///
  /// In en, this message translates to:
  /// **'Make Contribution'**
  String get makeContribution;

  /// No description provided for @contributionHistory.
  ///
  /// In en, this message translates to:
  /// **'Contribution History'**
  String get contributionHistory;

  /// No description provided for @noContributionsFound.
  ///
  /// In en, this message translates to:
  /// **'No contributions found'**
  String get noContributionsFound;

  /// No description provided for @noContributionsYet.
  ///
  /// In en, this message translates to:
  /// **'No contributions yet'**
  String get noContributionsYet;

  /// No description provided for @startContributing.
  ///
  /// In en, this message translates to:
  /// **'Start contributing to funds to see them here'**
  String get startContributing;

  /// No description provided for @selectFund.
  ///
  /// In en, this message translates to:
  /// **'Select Fund'**
  String get selectFund;

  /// No description provided for @contributionAmount.
  ///
  /// In en, this message translates to:
  /// **'Contribution Amount'**
  String get contributionAmount;

  /// No description provided for @contributionDate.
  ///
  /// In en, this message translates to:
  /// **'Contribution Date'**
  String get contributionDate;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @totalBalance.
  ///
  /// In en, this message translates to:
  /// **'Total Balance'**
  String get totalBalance;

  /// No description provided for @availableBalance.
  ///
  /// In en, this message translates to:
  /// **'Available Balance'**
  String get availableBalance;

  /// No description provided for @contribution.
  ///
  /// In en, this message translates to:
  /// **'Contribution'**
  String get contribution;

  /// No description provided for @repayment.
  ///
  /// In en, this message translates to:
  /// **'Repayment'**
  String get repayment;

  /// No description provided for @paidDate.
  ///
  /// In en, this message translates to:
  /// **'Paid Date'**
  String get paidDate;

  /// No description provided for @principal.
  ///
  /// In en, this message translates to:
  /// **'Principal'**
  String get principal;

  /// No description provided for @interest.
  ///
  /// In en, this message translates to:
  /// **'Interest'**
  String get interest;

  /// No description provided for @totalOutstanding.
  ///
  /// In en, this message translates to:
  /// **'Total Outstanding'**
  String get totalOutstanding;

  /// No description provided for @fundName.
  ///
  /// In en, this message translates to:
  /// **'Fund Name'**
  String get fundName;

  /// No description provided for @fundType.
  ///
  /// In en, this message translates to:
  /// **'Fund Type'**
  String get fundType;

  /// No description provided for @targetAmount.
  ///
  /// In en, this message translates to:
  /// **'Target Amount'**
  String get targetAmount;

  /// No description provided for @currentAmount.
  ///
  /// In en, this message translates to:
  /// **'Current Amount'**
  String get currentAmount;

  /// No description provided for @loanFund.
  ///
  /// In en, this message translates to:
  /// **'Loan Fund'**
  String get loanFund;

  /// No description provided for @memberName.
  ///
  /// In en, this message translates to:
  /// **'Member Name'**
  String get memberName;

  /// No description provided for @membershipNumber.
  ///
  /// In en, this message translates to:
  /// **'Membership Number'**
  String get membershipNumber;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @reference.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get reference;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get info;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noData;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @recordPayment.
  ///
  /// In en, this message translates to:
  /// **'Record Payment'**
  String get recordPayment;

  /// No description provided for @applyForLoan.
  ///
  /// In en, this message translates to:
  /// **'Apply for Loan'**
  String get applyForLoan;

  /// No description provided for @overdraftLimit.
  ///
  /// In en, this message translates to:
  /// **'Overdraft Limit'**
  String get overdraftLimit;

  /// No description provided for @overdraftUsed.
  ///
  /// In en, this message translates to:
  /// **'Overdraft Used'**
  String get overdraftUsed;

  /// No description provided for @availableCredit.
  ///
  /// In en, this message translates to:
  /// **'Available Credit'**
  String get availableCredit;

  /// No description provided for @monthlyInterest.
  ///
  /// In en, this message translates to:
  /// **'Monthly Interest'**
  String get monthlyInterest;

  /// No description provided for @accruedInterest.
  ///
  /// In en, this message translates to:
  /// **'Accrued Interest'**
  String get accruedInterest;

  /// No description provided for @principalBalance.
  ///
  /// In en, this message translates to:
  /// **'Principal Balance'**
  String get principalBalance;

  /// No description provided for @paymentHistory.
  ///
  /// In en, this message translates to:
  /// **'Payment History'**
  String get paymentHistory;

  /// No description provided for @balanceDetails.
  ///
  /// In en, this message translates to:
  /// **'Balance Details'**
  String get balanceDetails;

  /// No description provided for @loanDetails.
  ///
  /// In en, this message translates to:
  /// **'Loan Details'**
  String get loanDetails;

  /// No description provided for @contributionDetails.
  ///
  /// In en, this message translates to:
  /// **'Contribution Details'**
  String get contributionDetails;

  /// No description provided for @memberDetails.
  ///
  /// In en, this message translates to:
  /// **'Member Details'**
  String get memberDetails;

  /// No description provided for @fundDetails.
  ///
  /// In en, this message translates to:
  /// **'Fund Details'**
  String get fundDetails;

  /// No description provided for @userManual.
  ///
  /// In en, this message translates to:
  /// **'User Manual'**
  String get userManual;

  /// No description provided for @userManualDescription.
  ///
  /// In en, this message translates to:
  /// **'Complete guide to using the app'**
  String get userManualDescription;

  /// No description provided for @quickNavigation.
  ///
  /// In en, this message translates to:
  /// **'Quick Navigation'**
  String get quickNavigation;

  /// No description provided for @gettingStarted.
  ///
  /// In en, this message translates to:
  /// **'Getting Started'**
  String get gettingStarted;

  /// No description provided for @dashboardOverview.
  ///
  /// In en, this message translates to:
  /// **'Dashboard Overview'**
  String get dashboardOverview;

  /// No description provided for @memberManagement.
  ///
  /// In en, this message translates to:
  /// **'Member Management'**
  String get memberManagement;

  /// No description provided for @fundManagement.
  ///
  /// In en, this message translates to:
  /// **'Fund Management'**
  String get fundManagement;

  /// No description provided for @contributionManagement.
  ///
  /// In en, this message translates to:
  /// **'Contribution Management'**
  String get contributionManagement;

  /// No description provided for @loanManagement.
  ///
  /// In en, this message translates to:
  /// **'Loan Management'**
  String get loanManagement;

  /// No description provided for @transactionManagement.
  ///
  /// In en, this message translates to:
  /// **'Transaction Management'**
  String get transactionManagement;

  /// No description provided for @penaltiesManagement.
  ///
  /// In en, this message translates to:
  /// **'Penalties Management'**
  String get penaltiesManagement;

  /// No description provided for @settingsConfiguration.
  ///
  /// In en, this message translates to:
  /// **'Settings & Configuration'**
  String get settingsConfiguration;

  /// No description provided for @tipsAndBestPractices.
  ///
  /// In en, this message translates to:
  /// **'Tips & Best Practices'**
  String get tipsAndBestPractices;

  /// No description provided for @copyToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copy to clipboard'**
  String get copyToClipboard;

  /// No description provided for @sectionContentCopied.
  ///
  /// In en, this message translates to:
  /// **'Section content copied to clipboard'**
  String get sectionContentCopied;

  /// No description provided for @searchManual.
  ///
  /// In en, this message translates to:
  /// **'Search Manual'**
  String get searchManual;

  /// No description provided for @searchForTopics.
  ///
  /// In en, this message translates to:
  /// **'Search for topics, features, or keywords...'**
  String get searchForTopics;

  /// No description provided for @searchFeatureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Search feature coming soon!'**
  String get searchFeatureComingSoon;

  /// No description provided for @previousSection.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previousSection;

  /// No description provided for @nextSection.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextSection;

  /// No description provided for @penalties.
  ///
  /// In en, this message translates to:
  /// **'Penalties'**
  String get penalties;

  /// No description provided for @penaltyManagement.
  ///
  /// In en, this message translates to:
  /// **'Penalty Management'**
  String get penaltyManagement;

  /// No description provided for @penaltyRules.
  ///
  /// In en, this message translates to:
  /// **'Penalty Rules'**
  String get penaltyRules;

  /// No description provided for @applyPenalty.
  ///
  /// In en, this message translates to:
  /// **'Apply Penalty'**
  String get applyPenalty;

  /// No description provided for @penaltyType.
  ///
  /// In en, this message translates to:
  /// **'Penalty Type'**
  String get penaltyType;

  /// No description provided for @penaltyAmount.
  ///
  /// In en, this message translates to:
  /// **'Penalty Amount'**
  String get penaltyAmount;

  /// No description provided for @penaltyStatus.
  ///
  /// In en, this message translates to:
  /// **'Penalty Status'**
  String get penaltyStatus;

  /// No description provided for @penaltyReason.
  ///
  /// In en, this message translates to:
  /// **'Penalty Reason'**
  String get penaltyReason;

  /// No description provided for @lateFees.
  ///
  /// In en, this message translates to:
  /// **'Late Fees'**
  String get lateFees;

  /// No description provided for @missedContributions.
  ///
  /// In en, this message translates to:
  /// **'Missed Contributions'**
  String get missedContributions;

  /// No description provided for @loanDefaults.
  ///
  /// In en, this message translates to:
  /// **'Loan Defaults'**
  String get loanDefaults;

  /// No description provided for @meetingAbsence.
  ///
  /// In en, this message translates to:
  /// **'Meeting Absence'**
  String get meetingAbsence;

  /// No description provided for @ruleViolations.
  ///
  /// In en, this message translates to:
  /// **'Rule Violations'**
  String get ruleViolations;

  /// No description provided for @customPenalty.
  ///
  /// In en, this message translates to:
  /// **'Custom Penalty'**
  String get customPenalty;

  /// No description provided for @fixedAmount.
  ///
  /// In en, this message translates to:
  /// **'Fixed Amount'**
  String get fixedAmount;

  /// No description provided for @percentage.
  ///
  /// In en, this message translates to:
  /// **'Percentage'**
  String get percentage;

  /// No description provided for @dailyRate.
  ///
  /// In en, this message translates to:
  /// **'Daily Rate'**
  String get dailyRate;

  /// No description provided for @tieredPenalty.
  ///
  /// In en, this message translates to:
  /// **'Tiered Penalty'**
  String get tieredPenalty;

  /// No description provided for @penaltyPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get penaltyPending;

  /// No description provided for @penaltyActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get penaltyActive;

  /// No description provided for @penaltyPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get penaltyPaid;

  /// No description provided for @penaltyWaived.
  ///
  /// In en, this message translates to:
  /// **'Waived'**
  String get penaltyWaived;

  /// No description provided for @penaltyCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get penaltyCancelled;

  /// No description provided for @totalOutstandingPenalties.
  ///
  /// In en, this message translates to:
  /// **'Total Outstanding'**
  String get totalOutstandingPenalties;

  /// No description provided for @noPenaltiesFound.
  ///
  /// In en, this message translates to:
  /// **'No penalties found'**
  String get noPenaltiesFound;

  /// No description provided for @manageMemberPenalties.
  ///
  /// In en, this message translates to:
  /// **'Manage member penalties and fines'**
  String get manageMemberPenalties;

  /// No description provided for @supportTheDeveloper.
  ///
  /// In en, this message translates to:
  /// **'Support the Developer'**
  String get supportTheDeveloper;

  /// No description provided for @buyMeACoffee.
  ///
  /// In en, this message translates to:
  /// **'Buy me a coffee ☕'**
  String get buyMeACoffee;

  /// No description provided for @supportAppDevelopment.
  ///
  /// In en, this message translates to:
  /// **'Support app development'**
  String get supportAppDevelopment;

  /// No description provided for @rateTheApp.
  ///
  /// In en, this message translates to:
  /// **'Rate the App'**
  String get rateTheApp;

  /// No description provided for @leaveReview.
  ///
  /// In en, this message translates to:
  /// **'Leave a review on the app store'**
  String get leaveReview;

  /// No description provided for @shareWithFriends.
  ///
  /// In en, this message translates to:
  /// **'Share with Friends'**
  String get shareWithFriends;

  /// No description provided for @tellOthersAboutApp.
  ///
  /// In en, this message translates to:
  /// **'Tell others about this app'**
  String get tellOthersAboutApp;

  /// No description provided for @thankYouMessage.
  ///
  /// In en, this message translates to:
  /// **'Thank you for using our Association Management App! ❤️'**
  String get thankYouMessage;

  /// No description provided for @supportMessage.
  ///
  /// In en, this message translates to:
  /// **'If this app has been helpful to you and your organization, consider supporting the developer with a small contribution.'**
  String get supportMessage;

  /// No description provided for @mobileMoney.
  ///
  /// In en, this message translates to:
  /// **'📱 Mobile Money'**
  String get mobileMoney;

  /// No description provided for @copyPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Copy phone number'**
  String get copyPhoneNumber;

  /// No description provided for @mtnOrangeMoney.
  ///
  /// In en, this message translates to:
  /// **'MTN Mobile Money / Orange Money'**
  String get mtnOrangeMoney;

  /// No description provided for @suggestedAmounts.
  ///
  /// In en, this message translates to:
  /// **'💡 Suggested amounts:'**
  String get suggestedAmounts;

  /// No description provided for @coffeeAmount.
  ///
  /// In en, this message translates to:
  /// **'500 CFA ☕ Coffee'**
  String get coffeeAmount;

  /// No description provided for @snackAmount.
  ///
  /// In en, this message translates to:
  /// **'1,000 CFA 🥐 Snack'**
  String get snackAmount;

  /// No description provided for @mealAmount.
  ///
  /// In en, this message translates to:
  /// **'2,500 CFA 🍕 Meal'**
  String get mealAmount;

  /// No description provided for @generousAmount.
  ///
  /// In en, this message translates to:
  /// **'5,000 CFA ❤️ Generous'**
  String get generousAmount;

  /// No description provided for @supportHelpMessage.
  ///
  /// In en, this message translates to:
  /// **'Your support helps maintain and improve this app for everyone! 🙏'**
  String get supportHelpMessage;

  /// No description provided for @maybeLater.
  ///
  /// In en, this message translates to:
  /// **'Maybe Later'**
  String get maybeLater;

  /// No description provided for @copyNumber.
  ///
  /// In en, this message translates to:
  /// **'Copy Number'**
  String get copyNumber;

  /// No description provided for @phoneNumberCopied.
  ///
  /// In en, this message translates to:
  /// **'Phone number copied to clipboard! 📋'**
  String get phoneNumberCopied;

  /// No description provided for @duplicateContributionWarning.
  ///
  /// In en, this message translates to:
  /// **'Duplicate Contribution Warning'**
  String get duplicateContributionWarning;

  /// No description provided for @duplicateContributionMessage.
  ///
  /// In en, this message translates to:
  /// **'This member already has a contribution on the selected date:'**
  String get duplicateContributionMessage;

  /// No description provided for @existingContribution.
  ///
  /// In en, this message translates to:
  /// **'Existing Contribution'**
  String get existingContribution;

  /// No description provided for @proceedAnyway.
  ///
  /// In en, this message translates to:
  /// **'Proceed Anyway'**
  String get proceedAnyway;

  /// No description provided for @cancelContribution.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelContribution;

  /// No description provided for @contributionSettings.
  ///
  /// In en, this message translates to:
  /// **'Contribution Settings'**
  String get contributionSettings;

  /// No description provided for @setDefaultDateAndHost.
  ///
  /// In en, this message translates to:
  /// **'Set default date and host for contributions'**
  String get setDefaultDateAndHost;

  /// No description provided for @defaultDateOptions.
  ///
  /// In en, this message translates to:
  /// **'Default Date Options'**
  String get defaultDateOptions;

  /// No description provided for @alwaysUseToday.
  ///
  /// In en, this message translates to:
  /// **'Always use today\'s date'**
  String get alwaysUseToday;

  /// No description provided for @useFixedDate.
  ///
  /// In en, this message translates to:
  /// **'Use fixed default date'**
  String get useFixedDate;

  /// No description provided for @defaultHost.
  ///
  /// In en, this message translates to:
  /// **'Default Host'**
  String get defaultHost;

  /// No description provided for @selectDefaultHost.
  ///
  /// In en, this message translates to:
  /// **'Select default host member'**
  String get selectDefaultHost;

  /// No description provided for @previewSettings.
  ///
  /// In en, this message translates to:
  /// **'Preview Settings'**
  String get previewSettings;

  /// No description provided for @howDefaultsWillAppear.
  ///
  /// In en, this message translates to:
  /// **'See how defaults will appear'**
  String get howDefaultsWillAppear;

  /// No description provided for @settingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Settings saved successfully'**
  String get settingsSaved;

  /// No description provided for @monthByMonthInterest.
  ///
  /// In en, this message translates to:
  /// **'Month-by-Month Interest'**
  String get monthByMonthInterest;

  /// No description provided for @interestAccumulation.
  ///
  /// In en, this message translates to:
  /// **'Interest accumulates each month regardless of payments'**
  String get interestAccumulation;

  /// No description provided for @expectedTerm.
  ///
  /// In en, this message translates to:
  /// **'Expected Term (Months)'**
  String get expectedTerm;

  /// No description provided for @interestAccumulatesMonthly.
  ///
  /// In en, this message translates to:
  /// **'Interest accumulates monthly regardless of term'**
  String get interestAccumulatesMonthly;

  /// No description provided for @fixedMonthlyInterest.
  ///
  /// In en, this message translates to:
  /// **'Fixed monthly interest: CFA 3,150'**
  String get fixedMonthlyInterest;

  /// No description provided for @interestDue.
  ///
  /// In en, this message translates to:
  /// **'Interest Due'**
  String get interestDue;

  /// No description provided for @monthByMonthAccumulation.
  ///
  /// In en, this message translates to:
  /// **'Month-by-month accumulation'**
  String get monthByMonthAccumulation;

  /// No description provided for @interestStructure.
  ///
  /// In en, this message translates to:
  /// **'CFA 3,150 added each month since loan start'**
  String get interestStructure;

  /// No description provided for @monthsElapsed.
  ///
  /// In en, this message translates to:
  /// **'Months Elapsed'**
  String get monthsElapsed;

  /// No description provided for @monthByMonthInterestModel.
  ///
  /// In en, this message translates to:
  /// **'Month-by-Month Interest Model:'**
  String get monthByMonthInterestModel;

  /// No description provided for @monthlyInterestFixed.
  ///
  /// In en, this message translates to:
  /// **'Monthly Interest = Fixed CFA 3,150'**
  String get monthlyInterestFixed;

  /// No description provided for @totalInterestDue.
  ///
  /// In en, this message translates to:
  /// **'Total Interest Due = CFA 3,150 × {months} months = {amount}'**
  String totalInterestDue(Object amount, Object months);

  /// No description provided for @interestAccumulatesRegardless.
  ///
  /// In en, this message translates to:
  /// **'Interest accumulates each month regardless of payments'**
  String get interestAccumulatesRegardless;

  /// No description provided for @management.
  ///
  /// In en, this message translates to:
  /// **'Management'**
  String get management;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports & Analytics'**
  String get reports;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @updateAllInformation.
  ///
  /// In en, this message translates to:
  /// **'Update all information'**
  String get updateAllInformation;

  /// No description provided for @backupData.
  ///
  /// In en, this message translates to:
  /// **'Backup Data'**
  String get backupData;

  /// No description provided for @createDataBackup.
  ///
  /// In en, this message translates to:
  /// **'Create data backup'**
  String get createDataBackup;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutApp;

  /// No description provided for @appInformationAndVersion.
  ///
  /// In en, this message translates to:
  /// **'App information and version'**
  String get appInformationAndVersion;

  /// No description provided for @helpAndSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpAndSupport;

  /// No description provided for @getHelpAndContactSupport.
  ///
  /// In en, this message translates to:
  /// **'Get help and contact support'**
  String get getHelpAndContactSupport;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get exportData;

  /// No description provided for @exportToCSV.
  ///
  /// In en, this message translates to:
  /// **'Export to CSV'**
  String get exportToCSV;

  /// No description provided for @spreadsheetFormat.
  ///
  /// In en, this message translates to:
  /// **'Spreadsheet format'**
  String get spreadsheetFormat;

  /// No description provided for @exportToPDF.
  ///
  /// In en, this message translates to:
  /// **'Export to PDF'**
  String get exportToPDF;

  /// No description provided for @documentFormat.
  ///
  /// In en, this message translates to:
  /// **'Document format'**
  String get documentFormat;

  /// No description provided for @csvExport.
  ///
  /// In en, this message translates to:
  /// **'CSV Export'**
  String get csvExport;

  /// No description provided for @pdfExport.
  ///
  /// In en, this message translates to:
  /// **'PDF Export'**
  String get pdfExport;

  /// No description provided for @featureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'{feature} feature coming soon'**
  String featureComingSoon(Object feature);

  /// No description provided for @dataRefreshed.
  ///
  /// In en, this message translates to:
  /// **'Data refreshed successfully'**
  String get dataRefreshed;

  /// No description provided for @manualGettingStartedTitle.
  ///
  /// In en, this message translates to:
  /// **'🚀 Getting Started'**
  String get manualGettingStartedTitle;

  /// No description provided for @manualDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'🏠 Dashboard'**
  String get manualDashboardTitle;

  /// No description provided for @manualMemberManagementTitle.
  ///
  /// In en, this message translates to:
  /// **'👥 Member Management'**
  String get manualMemberManagementTitle;

  /// No description provided for @manualFundManagementTitle.
  ///
  /// In en, this message translates to:
  /// **'💰 Fund Management'**
  String get manualFundManagementTitle;

  /// No description provided for @manualContributionManagementTitle.
  ///
  /// In en, this message translates to:
  /// **'💳 Contribution Management'**
  String get manualContributionManagementTitle;

  /// No description provided for @manualLoanManagementTitle.
  ///
  /// In en, this message translates to:
  /// **'💸 Loan Management'**
  String get manualLoanManagementTitle;

  /// No description provided for @manualTransactionManagementTitle.
  ///
  /// In en, this message translates to:
  /// **'🧾 Transaction Management'**
  String get manualTransactionManagementTitle;

  /// No description provided for @manualPenaltiesManagementTitle.
  ///
  /// In en, this message translates to:
  /// **'⚠️ Penalties Management'**
  String get manualPenaltiesManagementTitle;

  /// No description provided for @manualSettingsConfigurationTitle.
  ///
  /// In en, this message translates to:
  /// **'⚙️ Settings & Configuration'**
  String get manualSettingsConfigurationTitle;

  /// No description provided for @manualTipsAndBestPracticesTitle.
  ///
  /// In en, this message translates to:
  /// **'💡 Tips & Best Practices'**
  String get manualTipsAndBestPracticesTitle;

  /// No description provided for @manualGettingStartedContent.
  ///
  /// In en, this message translates to:
  /// **'Welcome to the Association Management App!\n\nFIRST LAUNCH\nWhen you first open the app, you\'ll see the Dashboard with quick action buttons and summary cards. The app uses a bottom navigation bar with 5 main sections:\n\n• 🏠 Dashboard - Overview and quick actions\n• 👥 Members - Member management  \n• 💰 Funds - Fund management\n• 💳 Loans - Loan management\n• ⋯ More - Additional features and settings\n\nLANGUAGE SUPPORT\nThe app supports both French and English. To change language:\n1. Tap the language icon (🌐) in the top-right corner of the Dashboard\n2. Select your preferred language from the dropdown\n\nNAVIGATION\nUse the bottom navigation bar to switch between main sections. Swipe left/right to navigate between tabs quickly.'**
  String get manualGettingStartedContent;

  /// No description provided for @manualDashboardContent.
  ///
  /// In en, this message translates to:
  /// **'The Dashboard is your command center for quick access to common tasks.\n\nQUICK ACTIONS\n• 👤 Add Member - Register new association members\n• 💰 Contribute - Record member contributions  \n• 💳 New Loan - Apply for or process loans\n\nSUMMARY CARDS\nView key metrics at a glance:\n• Total Members - Active member count\n• Total Funds - Available fund balance\n• Active Loans - Current loan statistics\n• Recent Activity - Latest transactions\n\nTOP NAVIGATION\n• 🧾 Transactions - Quick access to transaction list\n• 🌐 Language - Switch between French/English\n\nThe dashboard automatically refreshes to show the latest information.'**
  String get manualDashboardContent;

  /// No description provided for @manualMemberManagementContent.
  ///
  /// In en, this message translates to:
  /// **'Manage all association members efficiently.\n\nADDING MEMBERS\n1. Tap \'Add Member\' from Dashboard or Members screen\n2. Fill in required information:\n   • First Name and Last Name\n   • Phone Number (for contact)\n   • Email Address (optional)\n   • Membership Date\n3. Tap \'Save\' to create the member profile\n\nMEMBER STATUS\n• Active - Can participate in all activities\n• Inactive - Limited participation\n• Suspended - Temporarily restricted\n• Pending - Awaiting approval\n\nSEARCH & FILTER\n• Use the search bar to find members quickly\n• Filter by status to view specific groups\n• Sort by name, date joined, or status\n\nMEMBER ACTIONS\n• View Details - See complete member information\n• Edit Profile - Update member information\n• View Contributions - See contribution history\n• Manage Penalties - Handle fines and penalties'**
  String get manualMemberManagementContent;

  /// No description provided for @manualFundManagementContent.
  ///
  /// In en, this message translates to:
  /// **'Create and manage different types of funds for your association.\n\nFUND TYPES\n• 💰 Savings - General savings fund\n• 📈 Investment - Investment opportunities\n• 🚨 Emergency - Emergency fund for urgent needs\n• 💳 Loan - Fund for providing loans\n\nCREATING FUNDS\n1. Go to Funds section\n2. Tap \'Create Fund\'\n3. Enter fund details:\n   • Fund Name\n   • Fund Type\n   • Description\n   • Target Amount (optional)\n4. Save to create the fund\n\nFUND MANAGEMENT\n• View fund balance and member count\n• Track contributions to each fund\n• Set fund-specific rules and targets\n• Export fund data for reporting\n\nBULK OPERATIONS\n• Activate/Deactivate multiple funds\n• Bulk contribution processing\n• Fund analytics and reporting'**
  String get manualFundManagementContent;

  /// No description provided for @manualContributionManagementContent.
  ///
  /// In en, this message translates to:
  /// **'Record and track member contributions to various funds.\n\nMAKING CONTRIBUTIONS\n1. Tap \'Contribute\' from Dashboard\n2. Select the member making the contribution\n3. Choose the fund to contribute to\n4. Enter contribution amount\n5. Set contribution date (defaults to today)\n6. Add notes if needed\n7. Submit the contribution\n\nCONTRIBUTION FEATURES\n• Duplicate detection - Warns if member already contributed on selected date\n• Multiple fund support - Contribute to different fund types\n• Contribution history - Track all past contributions\n• Default settings - Set default host and date preferences\n\nBULK CONTRIBUTIONS\n• Process multiple contributions at once\n• Import contribution data\n• Batch processing for efficiency\n\nREPORTING\n• View contribution summaries\n• Export contribution data\n• Generate contribution reports'**
  String get manualContributionManagementContent;

  /// No description provided for @manualLoanManagementContent.
  ///
  /// In en, this message translates to:
  /// **'Manage loan applications, approvals, and repayments.\n\nLOAN SYSTEM\nThe app uses a month-by-month interest model:\n• Interest accumulates each month regardless of payments\n• Fixed monthly interest rate\n• No fixed 12-month terms\n• Total amount due = Principal + (Monthly Interest × Months Elapsed)\n\nLOAN PROCESS\n1. Member applies for loan\n2. Review loan application\n3. Approve or reject loan\n4. Track loan payments and interest\n5. Monitor outstanding balances\n\nLOAN FEATURES\n• Flexible repayment terms\n• Interest calculation tracking\n• Payment history\n• Outstanding balance monitoring\n• Loan status management\n\nLOAN STATUSES\n• Pending - Awaiting approval\n• Approved - Loan approved and active\n• Completed - Fully repaid\n• Rejected - Application denied'**
  String get manualLoanManagementContent;

  /// No description provided for @manualTransactionManagementContent.
  ///
  /// In en, this message translates to:
  /// **'View and manage all financial transactions in the system.\n\nTRANSACTION TYPES\n• Contributions - Member fund contributions\n• Loan Disbursements - Loan payments to members\n• Loan Repayments - Payments from borrowers\n• Penalties - Fines and penalty payments\n• Transfers - Fund transfers between accounts\n\nTRANSACTION DETAILS\nEach transaction includes:\n• Date and time\n• Member involved\n• Amount (credit or debit)\n• Fund affected\n• Description/notes\n• Reference number\n\nTRANSACTION MANAGEMENT\n• View transaction history\n• Filter by date, member, or type\n• Search transactions\n• Export transaction data\n• Generate financial reports\n\nACCESS POINTS\n• Dashboard - Recent transactions\n• Top navigation - Full transaction list\n• Member profiles - Member-specific transactions\n• Fund details - Fund-specific transactions'**
  String get manualTransactionManagementContent;

  /// No description provided for @manualPenaltiesManagementContent.
  ///
  /// In en, this message translates to:
  /// **'Manage member penalties and fines effectively.\n\nPENALTY TYPES\n• Late Fees - For overdue payments\n• Missed Contributions - For skipped contributions\n• Loan Defaults - For loan payment delays\n• Meeting Absence - For missing meetings\n• Rule Violations - For breaking association rules\n• Custom Penalties - For other infractions\n\nPENALTY STRUCTURE\n• Fixed Amount - Set penalty amount\n• Percentage - Based on contribution/loan amount\n• Daily Rate - Accumulates daily\n• Tiered Penalty - Increases with severity\n\nPENALTY STATUS\n• Pending - Recently applied, awaiting action\n• Active - Currently in effect\n• Paid - Penalty has been paid\n• Waived - Penalty forgiven\n• Cancelled - Penalty removed\n\nPENALTY MANAGEMENT\n• Apply penalties to members\n• Track penalty payments\n• Generate penalty reports\n• Manage penalty rules and rates'**
  String get manualPenaltiesManagementContent;

  /// No description provided for @manualSettingsConfigurationContent.
  ///
  /// In en, this message translates to:
  /// **'Configure the app to match your association\'s needs.\n\nCONTRIBUTION SETTINGS\n• Default Date Options - Set automatic date preferences\n• Default Host - Choose default contribution host\n• Contribution Frequency - Set regular contribution schedules\n\nFUND SETTINGS\n• Default Currency - Set primary currency (XAF)\n• Interest Rates - Configure default loan interest rates\n• Fund Categories - Customize fund types\n\nSYSTEM SETTINGS\n• Language - Switch between French and English\n• Data Backup - Create and restore data backups\n• Export Options - Configure data export formats\n\nUSER PREFERENCES\n• Dashboard Layout - Customize dashboard appearance\n• Notification Settings - Manage app notifications\n• Security Settings - Set app security preferences\n\nDATA MANAGEMENT\n• Refresh Data - Update all information\n• Export Data - Download data in various formats\n• Backup & Restore - Protect your association data'**
  String get manualSettingsConfigurationContent;

  /// No description provided for @manualTipsAndBestPracticesContent.
  ///
  /// In en, this message translates to:
  /// **'Best practices for effective association management.\n\nDAILY OPERATIONS\n• Record contributions promptly\n• Update member information regularly\n• Review loan applications quickly\n• Monitor fund balances daily\n\nMONTHLY TASKS\n• Generate financial reports\n• Review member statuses\n• Process loan interest calculations\n• Backup association data\n\nBEST PRACTICES\n• Keep accurate records of all transactions\n• Communicate clearly with members about policies\n• Set clear contribution and loan guidelines\n• Regular data backups to prevent loss\n• Train multiple people on app usage\n\nTROUBLESHOoting\n• If app is slow, try refreshing data\n• For missing transactions, check filters\n• Contact support for technical issues\n• Keep app updated for best performance\n\nSECURITY TIPS\n• Regularly backup your data\n• Keep member information confidential\n• Use strong passwords if implemented\n• Monitor for unusual transactions\n\nGROWTH STRATEGIES\n• Track fund performance over time\n• Analyze member contribution patterns\n• Set realistic fund targets\n• Encourage regular member participation'**
  String get manualTipsAndBestPracticesContent;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'fr': return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
