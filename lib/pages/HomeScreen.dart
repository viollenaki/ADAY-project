import 'package:flutter/material.dart';
import 'package:personal_finance/generated/l10n.dart';
import 'package:personal_finance/pages/AddTransactionScreen.dart';
import 'package:personal_finance/database/database_helper.dart';
import 'package:personal_finance/widgets/summary_card.dart';
import 'package:personal_finance/pages/Category.dart';
import 'package:personal_finance/database/globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import '../main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late DatabaseHelper dbHelper;
  late Future<List<Map<String, dynamic>>> _transactionsFuture;

  double _totalIncome = 0.0;
  double _totalExpenses = 0.0;
  double _balance = 0.0;
  String userEmail = 'user@example.com';

  @override
  void initState() {
    super.initState();
    dbHelper = DatabaseHelper();
    _loadData();
    _getEmailOnce();
    _fetchCurrencyRates();
  }

  // Load transactions and summary data
  void _loadData() {
    _transactionsFuture = _fetchTransactions();
    _fetchSummaryData();
  }

  double convertCurrency(double amount) {
    return amount * (globals.currency[globals.currentCurrency] ?? 1.0);
  }

  Future<Map<String, double>> getCurrencyRelativeToUSD() async {
    final url = Uri.parse('https://www.cbr.ru/scripts/XML_daily.asp');
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Ошибка при получении данных от ЦБ РФ');
    }

    final document = XmlDocument.parse(response.body);
    final valutes = document.findAllElements('Valute');

    double? usdToRub; // сколько рублей за 1 USD
    final Map<String, double> ratesInRub = {};

    for (final valute in valutes) {
      final charCode = valute.getElement('CharCode')?.text;
      final nominal = int.parse(valute.getElement('Nominal')?.text ?? '1');
      final valueStr = valute.getElement('Value')?.text.replaceAll(',', '.');
      final value = double.parse(valueStr ?? '0');

      final ratePerUnit = value / nominal;

      if (charCode == 'USD') {
        usdToRub = ratePerUnit;
      } else {
        ratesInRub[charCode!] = ratePerUnit;
      }
    }

    if (usdToRub == null) {
      throw Exception('Курс USD не найден');
    }

    // Преобразуем в: "сколько валюты за 1 доллар"
    final Map<String, double> currency = {'USD': 1.0};

    for (final entry in ratesInRub.entries) {
      final code = entry.key;
      final rubPerUnit = entry.value;
      final valuePerUSD = usdToRub / rubPerUnit;
      currency[code] = valuePerUSD;
    }

    return currency;
  }

  void _getEmailOnce() async {
    if (globals.currentUsername != null) {
      final email = await dbHelper.getEmailByUsername(globals.currentUsername!);
      if (email != null) {
        setState(() {
          userEmail = email;
        });
      }
    }
  }

  void _fetchCurrencyRates() async {
    try {
      final currencyRates = await getCurrencyRelativeToUSD();
      setState(() {
        globals.currency = currencyRates; // сохраняем в глобальную переменную
      });
    } catch (e) {
      print('Ошибка при получении курса валют: $e');
    }
  }

  // Fetch summary data (income, expenses, balance)
  Future<void> _fetchSummaryData() async {
    try {
      final db = await dbHelper.database;

      // Get total income
      final incomeResult = await db.rawQuery(
        "SELECT SUM(amount) as total FROM transactions WHERE type = 'income'",
      );
      _totalIncome =
          incomeResult.first['total'] != null
              ? (incomeResult.first['total'] as num).toDouble()
              : 0.0;

      // Get total expenses
      final expenseResult = await db.rawQuery(
        "SELECT SUM(amount) as total FROM transactions WHERE type = 'expense'",
      );
      _totalExpenses =
          expenseResult.first['total'] != null
              ? (expenseResult.first['total'] as num).toDouble()
              : 0.0;

      // Calculate balance
      _balance = _totalIncome - _totalExpenses;

      setState(() {}); // Refresh UI
    } catch (e) {
      print("Error fetching summary data: $e");
    }
  }

  // Fetch all transactions
  Future<List<Map<String, dynamic>>> _fetchTransactions() async {
    try {
      final db = await dbHelper.database;
      return await db.query('transactions', orderBy: 'date DESC');
    } catch (e) {
      print("Error fetching transactions: $e");
      return [];
    }
  }

  Future<void> _deleteAllTransactions() async {
    bool confirmDelete = await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Delete All Transactions"),
            content: const Text(
              "Are you sure you want to delete all transactions?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  "Delete",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmDelete) {
      try {
        final db = await dbHelper.database;
        await db.delete('transactions');
        setState(() {
          _loadData(); // Обновим список
        });
      } catch (e) {
        print("Error deleting all transactions: $e");
      }
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Close dialog
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(
                  context,
                  '/',
                ); // Navigate to login screen
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Personal Finance',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
      ),
      drawer: _buildDrawer(),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Summary Cards with the new layout style
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Income and Expenses in a row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: SummaryCard(
                        title: 'Income',
                        amount:
                            '${globals.currentCurrency} ${convertCurrency(_totalIncome).toStringAsFixed(2)}',
                        color: Colors.green,
                        icon: Icons.arrow_upward,
                        titleFontSize: 14.0, // Reduce font size
                        amountFontSize: 15.0, // Reduce font size
                      ),
                    ),
                    const SizedBox(width: 12), // Space between cards
                    Expanded(
                      child: SummaryCard(
                        title: 'Expenses',
                        amount:
                            '${globals.currentCurrency} ${convertCurrency(_totalExpenses).toStringAsFixed(2)}',
                        color: Colors.red,
                        icon: Icons.arrow_downward,
                        titleFontSize: 14.0, // Reduce font size
                        amountFontSize: 15.0, // Reduce font size
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Balance on its own line
                SummaryCard(
                  title: 'Balance',
                  amount:
                      '${globals.currentCurrency} ${convertCurrency(_balance).toStringAsFixed(2)}',
                  color: Colors.blue,
                  icon: Icons.account_balance_wallet,
                ),
              ],
            ),
          ),

          // Recent Transactions with improved styling
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 16.0, bottom: 8.0),
                    child: Text(
                      "Recent Transactions",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        setState(() {
                          _loadData(); // Refresh data
                        });
                      },
                      child: FutureBuilder<List<Map<String, dynamic>>>(
                        future: _transactionsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Text('Error: ${snapshot.error}'),
                            );
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return const Center(
                              child: Text('No transactions yet.'),
                            );
                          }

                          final transactions = snapshot.data!;
                          return ListView.builder(
                            itemCount: transactions.length,
                            itemBuilder: (context, index) {
                              final transaction = transactions[index];
                              return _buildTransactionTile(transaction);
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTransactionScreen()),
          );

          if (result == true) {
            setState(() {
              _loadData(); // Refresh transactions and summary data
            });
          }
        },
        backgroundColor: const Color.fromARGB(255, 124, 87, 188),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // Widget to display each transaction
  Widget _buildTransactionTile(Map<String, dynamic> transaction) {
    bool isIncome = transaction['type'] == 'income';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: isIncome ? Colors.green[100] : Colors.red[100],
          child: Icon(
            isIncome ? Icons.arrow_downward : Icons.arrow_upward,
            color: isIncome ? Colors.green : Colors.red,
          ),
        ),
        title: Text(
          transaction['category'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${transaction['description']} - ${transaction['date']}',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        trailing: Text(
          '${globals.currentCurrency} ${convertCurrency((transaction['amount'] as num).toDouble()).toStringAsFixed(2)}',
          style: TextStyle(
            color: isIncome ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        onTap: () => _showTransactionActions(context, transaction),
      ),
    );
  }

  // Show options for Edit and Delete
  void _showTransactionActions(
    BuildContext context,
    Map<String, dynamic> transaction,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Transaction Actions"),
          content: const Text("What would you like to do?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _editTransaction(transaction); // Edit Transaction
              },
              child: const Text("Edit"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _deleteTransaction(
                  transaction['id'],
                ); // Delete Transaction
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // Edit transaction
  void _editTransaction(Map<String, dynamic> transaction) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTransactionScreen(transaction: transaction),
      ),
    );

    if (result == true) {
      setState(() {
        _loadData(); // Refresh transactions and summary data
      });
    }
  }

  // Delete transaction
  Future<void> _deleteTransaction(int transactionId) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Delete Transaction"),
            content: const Text(
              "Are you sure you want to delete this transaction?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  "Delete",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmDelete) {
      try {
        final db = await dbHelper.database;
        await db.delete(
          'transactions',
          where: 'id = ?',
          whereArgs: [transactionId],
        );
        setState(() {
          _loadData(); // Refresh transactions and summary data
        });
      } catch (e) {
        print("Error deleting transaction: $e");
      }
    }
  }

  // Drawer Widget
  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.deepPurple),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.account_circle, size: 50, color: Colors.white),
                SizedBox(height: 10),
                Text(
                  globals.currentUsername ?? 'Guest',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                Text(
                  userEmail,
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.account_box),
            title: const Text('Account'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Сategory'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CategoryScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever),
            title: const Text('Delete All'),
            onTap: _deleteAllTransactions,
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(S.of(context).logout),
            onTap: _showLogoutDialog,
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(S.of(context).language),
            onTap: () {},
            trailing: DropdownButton<Locale>(
              underline: const SizedBox(),
              value: Localizations.localeOf(context),
              onChanged: (Locale? locale) {
                if (locale != null) {
                  MyApp.setLocale(context, locale);
                  Navigator.pop(context); // Закрываем меню
                }
              },
              items: const [
                DropdownMenuItem(
                  value: Locale('en'),
                  child: Text('English'),
                ),
                DropdownMenuItem(
                  value: Locale('ru'),
                  child: Text('Русский'),
                ),
                DropdownMenuItem(
                  value: Locale('ky'),
                  child: Text('Кыргызча'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
