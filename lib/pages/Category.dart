import 'package:flutter/material.dart';
import 'package:personal_finance/database/database_helper.dart';
import 'package:personal_finance/generated/l10n.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  List<String> incomeCategories = [];
  List<String> expenseCategories = [];

  final TextEditingController _categoryNameController = TextEditingController();
  String _selectedCategoryType = 'Income';

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  Future<void> loadCategories() async {
    final income = await dbHelper.getCategoriesByType('income');
    final expense = await dbHelper.getCategoriesByType('expense');

    setState(() {
      incomeCategories = income;
      expenseCategories = expense;
    });
  }

  Future<void> _deleteCategory(String name, String type) async {
    final db = await dbHelper.database;
    await db.delete(
      'categories',
      where: 'name = ? AND type = ?',
      whereArgs: [name, type],
    );
    await loadCategories();
  }

  void _confirmDelete(BuildContext context, String name, String type) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(S.of(context).deleteCategory),
          content: Text("Are you sure you want to delete \"$name\"?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(S.of(context).cancel),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteCategory(name, type);
                ScaffoldMessenger.of(context).showSnackBar(
                   SnackBar(content: Text(S.of(context).categoryDeleted)),
                );
              },
              child: Text(S.of(context).delete, style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(S.of(context).addNewCategory),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _categoryNameController,
                decoration: InputDecoration(
                  labelText: S.of(context).categoryName,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategoryType,
                items: [
                  DropdownMenuItem(value: 'Income', child: Text(S.of(context).income)),
                  DropdownMenuItem(value: 'Expense', child: Text(S.of(context).expense)),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCategoryType = value!;
                  });
                },
                decoration: InputDecoration(
                  labelText: S.of(context).categoryType,
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _categoryNameController.clear();
                Navigator.of(context).pop();
              },
              child: Text(S.of(context).cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = _categoryNameController.text.trim();
                final type = _selectedCategoryType.toLowerCase();
                if (name.isNotEmpty) {
                  await dbHelper.insertCategory(name, type);
                  ScaffoldMessenger.of(context).showSnackBar(
                     SnackBar(content: Text(S.of(context).categoryAddedSuccessfully)),
                  );
                  await loadCategories(); // Refresh
                }
                _categoryNameController.clear();
                Navigator.of(context).pop();
              },
              child: Text(S.of(context).add),
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
        title: Text(S.of(context).categories),
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
      backgroundColor: Colors.white,
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ElevatedButton.icon(
            onPressed: () => _showAddCategoryDialog(context),
            icon: const Icon(Icons.add),
            label: Text(S.of(context).addCategory),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            S.of(context).incomeCategories,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...incomeCategories.map((cat) => ListTile(
            leading: const Icon(Icons.arrow_downward, color: Colors.green),
            title: Text(cat),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDelete(context, cat, 'income'),
            ),
          )),
          const SizedBox(height: 20),
          Text(
            S.of(context).expenseCategories,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...expenseCategories.map((cat) => ListTile(
            leading: const Icon(Icons.arrow_upward, color: Colors.red),
            title: Text(cat),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDelete(context, cat, 'expense'),
            ),
          )),
        ],
      ),
    );
  }
}