// ignore: file_names
import 'package:flutter/material.dart';
import 'package:personal_finance/database/database_helper.dart';
import 'package:personal_finance/pages/LogingRegister.dart' as globals;
import 'package:personal_finance/pages/HomeScreen.dart' as cur;

class AddTransactionScreen extends StatefulWidget {
  final Map<String, dynamic>? transaction; // Accepts transaction for editing

  // ignore: use_super_parameters
  const AddTransactionScreen({Key? key, this.transaction}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  String _type = 'expense'; // Default to expense
  String _category = 'Other';
  DateTime _selectedDate = DateTime.now();

  // Predefined categories
  final List<String> _categories = [
    'Food',
    'Transport',
    'Shopping',
    'Bills',
    'Other',
  ];

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    _amountController = TextEditingController();
    _descriptionController = TextEditingController();

    // If editing, prefill form fields
    if (widget.transaction != null) {
      _amountController.text = widget.transaction!['amount'].toString();
      _descriptionController.text = widget.transaction!['description'];
      _type = widget.transaction!['type'];
      _category = widget.transaction!['category'];
      _selectedDate = DateTime.parse(widget.transaction!['date']);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveTransaction() async {
    if (_formKey.currentState!.validate()) {
      final enteredAmount = double.parse(_amountController.text);
      final amountInUSD = enteredAmount / (cur.currency[globals.currentCurrency] ?? 1.0);

      final transactionData = {
        'amount': amountInUSD,
        'description': _descriptionController.text,
        'type': _type,
        'category': _category,
        'date': _selectedDate.toIso8601String(),
      };

      final db = await _dbHelper.database;

      if (widget.transaction == null) {
        // Insert new transaction
        await db.insert('transactions', transactionData);
      } else {
        // Update existing transaction
        await db.update(
          'transactions',
          transactionData,
          where: 'id = ?',
          whereArgs: [widget.transaction!['id']],
        );
      }

      // ignore: use_build_context_synchronously
      Navigator.pop(context, true); // Return success
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.transaction == null ? "Add Transaction" : "Edit Transaction",
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
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Amount Field
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: "Amount",
                  prefixIcon:
                      Icon(Icons.attach_money, color: Colors.blueAccent),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter an amount";
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return "Enter a valid amount";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Description Field
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: "Description",
                  prefixIcon: Icon(Icons.description, color: Colors.blueAccent),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? "Enter a description"
                    : null,
              ),
              const SizedBox(height: 20),

              // Type Dropdown
              DropdownButtonFormField<String>(
                value: _type,
                decoration: InputDecoration(
                  labelText: "Type",
                  prefixIcon:
                      Icon(Icons.type_specimen, color: Colors.blueAccent),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                items: ["income", "expense"].map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.capitalize()),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _type = value!),
              ),
              const SizedBox(height: 20),

              // Category Dropdown
              DropdownButtonFormField<String>(
                value: _category,
                decoration: InputDecoration(
                  labelText: "Category",
                  prefixIcon: Icon(Icons.category, color: Colors.blueAccent),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _category = value!),
              ),
              const SizedBox(height: 20),

              // Date Picker
              ListTile(
                title: Text(
                  "Date",
                  style: TextStyle(color: Colors.blueAccent),
                ),
                subtitle: Text(
                  _selectedDate.toLocal().toString().split(' ')[0],
                  style: TextStyle(fontSize: 16),
                ),
                trailing: Icon(Icons.calendar_today, color: Colors.blueAccent),
                onTap: () => _selectDate(context),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  side: BorderSide(color: Colors.blueAccent),
                ),
              ),
              const SizedBox(height: 30),

              // Save/Update Button
              ElevatedButton(
                onPressed: _saveTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text(
                  widget.transaction == null
                      ? "Add Transaction"
                      : "Update Transaction",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper function for capitalization
extension StringExtension on String {
  String capitalize() => '${this[0].toUpperCase()}${substring(1)}';
}
