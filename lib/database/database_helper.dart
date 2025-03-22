import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<void> deleteDatabaseFile() async {
    final path = join(await getDatabasesPath(), 'finance.db');
    await deleteDatabase(path);
    print('База удалена: $path');
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<int> insertCategory(String name, String type) async {
    final db = await database;
    return await db.insert(
      'categories',
      {'name': name, 'type': type},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<int> insertUser(String name, String email, String password) async {
    final db = await database;
    return await db.insert(
      'user',
      {
        'name': name,
        'email': email,
        'password': password,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore, // не перезаписывать, если имя/email уже есть
    );
  }

  Future<String?> getEmailByUsername(String username) async {
    final db = await database;
    final result = await db.query(
      'user',
      columns: ['email'],
      where: 'name = ?',
      whereArgs: [username],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first['email'] as String;
    }
    return null;
  }

  Future<List<String>> getCategoriesByType(String type) async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
    await db.query('categories', where: 'type = ?', whereArgs: [type]);

    return maps.map((map) => map['name'] as String).toList();
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'finance.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL,
        type TEXT,
        category TEXT,
        date TEXT,
        description TEXT,
        isRecurring INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        type TEXT
      )
    ''');
    // Вставка категорий по умолчанию
    final defaultCategories = [
      {'name': 'Food', 'type': 'expense'},
      {'name': 'Transport', 'type': 'expense'},
      {'name': 'Shopping', 'type': 'expense'},
      {'name': 'Bills', 'type': 'expense'},
      //{'name': 'Other', 'type': 'expense'},
      {'name': 'Salary', 'type': 'income'},
      {'name': 'Gift', 'type': 'income'},
      {'name': 'Investment', 'type': 'income'},
    ];

    for (var category in defaultCategories) {
      await db.insert('categories', category);
    }


    await db.execute('''
      CREATE TABLE budgets(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT,
        budget_limit REAL, -- Renamed from "limit" to "budget_limit"
        month TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE user(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        email TEXT UNIQUE,
        password TEXT
      )
      ''');
  }

  Future<int> insertTransaction(Map<String, dynamic> transaction) async {
    final db = await database;
    return await db.insert('transactions', transaction);
  }

  Future<int> updateTransaction(
      Map<String, dynamic> transaction, int id) async {
    final db = await database;
    return await db
        .update('transactions', transaction, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }
}
