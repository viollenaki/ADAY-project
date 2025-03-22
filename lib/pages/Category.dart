import 'package:flutter/material.dart';
import 'package:personal_finance/database/database_helper.dart';

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
          title: const Text("Delete Category"),
          content: Text("Are you sure you want to delete \"$name\"?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteCategory(name, type);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Category deleted')),
                );
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
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
          title: const Text("Add New Category"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _categoryNameController,
                decoration: const InputDecoration(
                  labelText: 'Category Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategoryType,
                items: const [
                  DropdownMenuItem(value: 'Income', child: Text('Income')),
                  DropdownMenuItem(value: 'Expense', child: Text('Expense')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCategoryType = value!;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Category Type',
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
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = _categoryNameController.text.trim();
                final type = _selectedCategoryType.toLowerCase();
                if (name.isNotEmpty) {
                  await dbHelper.insertCategory(name, type);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Category added successfully')),
                  );
                  await loadCategories(); // Refresh
                }
                _categoryNameController.clear();
                Navigator.of(context).pop();
              },
              child: const Text("Add"),
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
        title: const Text('Categories'),
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
            label: const Text("Add Category"),
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
          const Text(
            'Income Categories',
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
          const Text(
            'Expense Categories',
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