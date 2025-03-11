import 'package:flutter/material.dart';
import 'package:personal_finance/pages/AddTransactionScreen.dart';
import 'package:personal_finance/database/database_helper.dart';
import 'package:personal_finance/widgets/summary_card.dart';


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

  @override
  void initState() {
    super.initState();
    dbHelper = DatabaseHelper();
    _loadData();
  }

  // Load transactions and summary data
  void _loadData() {
    _transactionsFuture = _fetchTransactions();
    _fetchSummaryData();
  }

  // Fetch summary data (income, expenses, balance)
  Future<void> _fetchSummaryData() async {
    try {
      final db = await dbHelper.database;

      // Get total income
      final incomeResult = await db.rawQuery(
          "SELECT SUM(amount) as total FROM transactions WHERE type = 'income'");
      _totalIncome = incomeResult.first['total'] != null
          ? (incomeResult.first['total'] as num).toDouble()
          : 0.0;

      // Get total expenses
      final expenseResult = await db.rawQuery(
          "SELECT SUM(amount) as total FROM transactions WHERE type = 'expense'");
      _totalExpenses = expenseResult.first['total'] != null
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
                    context, '/'); // Navigate to login screen
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
          // Summary Cards
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SummaryCard(
                  title: 'Income',
                  amount: '\$${_totalIncome.toStringAsFixed(2)}',
                  color: Colors.green,
                  icon: Icons.arrow_upward,
                ),
                const SizedBox(height: 12),
                SummaryCard(
                  title: 'Expenses',
                  amount: '\$${_totalExpenses.toStringAsFixed(2)}',
                  color: Colors.red,
                  icon: Icons.arrow_downward,
                ),
                const SizedBox(height: 12),
                SummaryCard(
                  title: 'Balance',
                  amount: '\$${_balance.toStringAsFixed(2)}',
                  color: Colors.blue,
                  icon: Icons.account_balance_wallet,
                ),
              ],
            ),
          ),

          // Recent Transactions
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
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No transactions yet.'));
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
          '\$${transaction['amount']}',
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
      BuildContext context, Map<String, dynamic> transaction) {
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
                    transaction['id']); // Delete Transaction
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
      builder: (context) => AlertDialog(
        title: const Text("Delete Transaction"),
        content:
            const Text("Are you sure you want to delete this transaction?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmDelete) {
      try {
        final db = await dbHelper.database;
        await db.delete('transactions',
            where: 'id = ?', whereArgs: [transactionId]);
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
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.deepPurple),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.account_circle, size: 50, color: Colors.white),
                SizedBox(height: 10),
                Text(
                  'User Name',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                Text(
                  'user@example.com',
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
            title: const Text('category'),
            onTap: () {
              // Navigate to settings (implement later)
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: _showLogoutDialog,
          ),
        ],
      ),
    );
  }
}

