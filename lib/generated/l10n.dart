// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name =
        (locale.countryCode?.isEmpty ?? false)
            ? locale.languageCode
            : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Language`
  String get language {
    return Intl.message('Language', name: 'language', desc: '', args: []);
  }

  /// `Logout`
  String get logout {
    return Intl.message('Logout', name: 'logout', desc: '', args: []);
  }

  /// `Personal Finance`
  String get personalFinance {
    return Intl.message(
      'Personal Finance',
      name: 'personalFinance',
      desc: '',
      args: [],
    );
  }

  /// `Delete All Transactions`
  String get deleteAllTransactions {
    return Intl.message(
      'Delete All Transactions',
      name: 'deleteAllTransactions',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete all transactions?`
  String get areYouSureYouWantToDeleteAllTransactions {
    return Intl.message(
      'Are you sure you want to delete all transactions?',
      name: 'areYouSureYouWantToDeleteAllTransactions',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message('Cancel', name: 'cancel', desc: '', args: []);
  }

  /// `Delete`
  String get delete {
    return Intl.message('Delete', name: 'delete', desc: '', args: []);
  }

  /// `Are you sure you want to logout?`
  String get areYouSureYouWantToLogout {
    return Intl.message(
      'Are you sure you want to logout?',
      name: 'areYouSureYouWantToLogout',
      desc: '',
      args: [],
    );
  }

  /// `Income`
  String get income {
    return Intl.message('Income', name: 'income', desc: '', args: []);
  }

  /// `Expenses`
  String get expenses {
    return Intl.message('Expenses', name: 'expenses', desc: '', args: []);
  }

  /// `Balance`
  String get balance {
    return Intl.message('Balance', name: 'balance', desc: '', args: []);
  }

  /// `Recent Transactions`
  String get recentTransactions {
    return Intl.message(
      'Recent Transactions',
      name: 'recentTransactions',
      desc: '',
      args: [],
    );
  }

  /// `Transaction Actions`
  String get transactionActions {
    return Intl.message(
      'Transaction Actions',
      name: 'transactionActions',
      desc: '',
      args: [],
    );
  }

  /// `What would you like to do?`
  String get whatWouldYouLikeToDo {
    return Intl.message(
      'What would you like to do?',
      name: 'whatWouldYouLikeToDo',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get edit {
    return Intl.message('Edit', name: 'edit', desc: '', args: []);
  }

  /// `Delete Transaction`
  String get deleteTransaction {
    return Intl.message(
      'Delete Transaction',
      name: 'deleteTransaction',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this transaction?`
  String get areYouSureYouWantToDeleteThisTransaction {
    return Intl.message(
      'Are you sure you want to delete this transaction?',
      name: 'areYouSureYouWantToDeleteThisTransaction',
      desc: '',
      args: [],
    );
  }

  /// `Guest`
  String get guest {
    return Intl.message('Guest', name: 'guest', desc: '', args: []);
  }

  /// `Account`
  String get account {
    return Intl.message('Account', name: 'account', desc: '', args: []);
  }

  /// `Сategory`
  String get ategory {
    return Intl.message('Сategory', name: 'ategory', desc: '', args: []);
  }

  /// `Delete All`
  String get deleteAll {
    return Intl.message('Delete All', name: 'deleteAll', desc: '', args: []);
  }

  /// `No transactions yet.`
  String get noTransactionsYet {
    return Intl.message(
      'No transactions yet.',
      name: 'noTransactionsYet',
      desc: '',
      args: [],
    );
  }

  /// `Welcome Back!`
  String get welcomeBack {
    return Intl.message(
      'Welcome Back!',
      name: 'welcomeBack',
      desc: '',
      args: [],
    );
  }

  /// `Create Account`
  String get createAccount {
    return Intl.message(
      'Create Account',
      name: 'createAccount',
      desc: '',
      args: [],
    );
  }

  /// `Username`
  String get username {
    return Intl.message('Username', name: 'username', desc: '', args: []);
  }

  /// `Please enter a username`
  String get pleaseEnterAUsername {
    return Intl.message(
      'Please enter a username',
      name: 'pleaseEnterAUsername',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get password {
    return Intl.message('Password', name: 'password', desc: '', args: []);
  }

  /// `Please enter a password`
  String get pleaseEnterAPassword {
    return Intl.message(
      'Please enter a password',
      name: 'pleaseEnterAPassword',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get email {
    return Intl.message('Email', name: 'email', desc: '', args: []);
  }

  /// `Please enter an email`
  String get pleaseEnterAnEmail {
    return Intl.message(
      'Please enter an email',
      name: 'pleaseEnterAnEmail',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid email`
  String get pleaseEnterAValidEmail {
    return Intl.message(
      'Please enter a valid email',
      name: 'pleaseEnterAValidEmail',
      desc: '',
      args: [],
    );
  }

  /// `User already exists or registration failed.`
  String get userAlreadyExistsOrRegistrationFailed {
    return Intl.message(
      'User already exists or registration failed.',
      name: 'userAlreadyExistsOrRegistrationFailed',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get login {
    return Intl.message('Login', name: 'login', desc: '', args: []);
  }

  /// `Register`
  String get register {
    return Intl.message('Register', name: 'register', desc: '', args: []);
  }

  /// `Don't have an account? Register`
  String get dontHaveAnAccountRegister {
    return Intl.message(
      'Don\'t have an account? Register',
      name: 'dontHaveAnAccountRegister',
      desc: '',
      args: [],
    );
  }

  /// `Already have an account? Login`
  String get alreadyHaveAnAccountLogin {
    return Intl.message(
      'Already have an account? Login',
      name: 'alreadyHaveAnAccountLogin',
      desc: '',
      args: [],
    );
  }

  /// `Delete Category`
  String get deleteCategory {
    return Intl.message(
      'Delete Category',
      name: 'deleteCategory',
      desc: '',
      args: [],
    );
  }

  /// `Category deleted`
  String get categoryDeleted {
    return Intl.message(
      'Category deleted',
      name: 'categoryDeleted',
      desc: '',
      args: [],
    );
  }

  /// `Add New Category`
  String get addNewCategory {
    return Intl.message(
      'Add New Category',
      name: 'addNewCategory',
      desc: '',
      args: [],
    );
  }

  /// `Category Name`
  String get categoryName {
    return Intl.message(
      'Category Name',
      name: 'categoryName',
      desc: '',
      args: [],
    );
  }

  /// `Expense`
  String get expense {
    return Intl.message('Expense', name: 'expense', desc: '', args: []);
  }

  /// `Category Type`
  String get categoryType {
    return Intl.message(
      'Category Type',
      name: 'categoryType',
      desc: '',
      args: [],
    );
  }

  /// `Category added successfully`
  String get categoryAddedSuccessfully {
    return Intl.message(
      'Category added successfully',
      name: 'categoryAddedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Add`
  String get add {
    return Intl.message('Add', name: 'add', desc: '', args: []);
  }

  /// `Categories`
  String get categories {
    return Intl.message('Categories', name: 'categories', desc: '', args: []);
  }

  /// `Add Category`
  String get addCategory {
    return Intl.message(
      'Add Category',
      name: 'addCategory',
      desc: '',
      args: [],
    );
  }

  /// `Income Categories`
  String get incomeCategories {
    return Intl.message(
      'Income Categories',
      name: 'incomeCategories',
      desc: '',
      args: [],
    );
  }

  /// `Expense Categories`
  String get expenseCategories {
    return Intl.message(
      'Expense Categories',
      name: 'expenseCategories',
      desc: '',
      args: [],
    );
  }

  /// `Reports & Charts`
  String get reportsCharts {
    return Intl.message(
      'Reports & Charts',
      name: 'reportsCharts',
      desc: '',
      args: [],
    );
  }

  /// `No data available`
  String get noDataAvailable {
    return Intl.message(
      'No data available',
      name: 'noDataAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Income Overview`
  String get incomeOverview {
    return Intl.message(
      'Income Overview',
      name: 'incomeOverview',
      desc: '',
      args: [],
    );
  }

  /// `Expense Overview`
  String get expenseOverview {
    return Intl.message(
      'Expense Overview',
      name: 'expenseOverview',
      desc: '',
      args: [],
    );
  }

  /// `Monthly Spending Trends`
  String get monthlySpendingTrends {
    return Intl.message(
      'Monthly Spending Trends',
      name: 'monthlySpendingTrends',
      desc: '',
      args: [],
    );
  }

  /// `Filters`
  String get filters {
    return Intl.message('Filters', name: 'filters', desc: '', args: []);
  }

  /// `Tyypeee`
  String get tyypeee {
    return Intl.message('Tyypeee', name: 'tyypeee', desc: '', args: []);
  }

  /// `Select Start Date`
  String get selectStartDate {
    return Intl.message(
      'Select Start Date',
      name: 'selectStartDate',
      desc: '',
      args: [],
    );
  }

  /// `Select End Date`
  String get selectEndDate {
    return Intl.message(
      'Select End Date',
      name: 'selectEndDate',
      desc: '',
      args: [],
    );
  }

  /// `Filter by Category`
  String get filterByCategory {
    return Intl.message(
      'Filter by Category',
      name: 'filterByCategory',
      desc: '',
      args: [],
    );
  }

  /// `No data available for the selected filters`
  String get noDataAvailableForTheSelectedFilters {
    return Intl.message(
      'No data available for the selected filters',
      name: 'noDataAvailableForTheSelectedFilters',
      desc: '',
      args: [],
    );
  }

  /// `Start: ${selectedStartDate!.toLocal().toString().split(' ')[0]}`
  String get startSelectedstartdatetolocaltostringsplit0 {
    return Intl.message(
      'Start: \${selectedStartDate!.toLocal().toString().split(\' \')[0]}',
      name: 'startSelectedstartdatetolocaltostringsplit0',
      desc: '',
      args: [],
    );
  }

  /// `End: ${selectedEndDate!.toLocal().toString().split(' ')[0]}`
  String get endSelectedenddatetolocaltostringsplit0 {
    return Intl.message(
      'End: \${selectedEndDate!.toLocal().toString().split(\' \')[0]}',
      name: 'endSelectedenddatetolocaltostringsplit0',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ky'),
      Locale.fromSubtags(languageCode: 'ru'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
