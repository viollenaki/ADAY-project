import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<void> deleteDatabaseFile() async {
    final path = join(await getDatabasesPath(), 'finance.db');
    await deleteDatabase(path);
    print('База удалена: $path');
  }

  Future<Database> get database async {
    if (_database != null) return _database!; // Используем поле _database
    _database = await _initDatabase();       // Сохраняем в _database
    return _database!;
  }

  Future<void> checkDatabase() async {
  try {
    final db = await database;
    await db.rawQuery('SELECT 1');
    print('Database connection successful');
  } catch (e) {
    print('Database connection error: $e');
  }
}

  Future<int> insertCategory(String name, String type) async {
    final db = await database;
    return await db.insert(
      'categories',
      {'name': name, 'type': type},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  // Регистрация пользователя (с проверкой существования)
Future<int> insertUser(String name, String email, String password) async {
  try {
    final db = await database;
    
    // Проверка существующего пользователя по имени и email
    final existingUser = await db.query(
      'users',
      where: 'name = ? OR email = ?',  // Проверка по имени или email
      whereArgs: [name, email],
      limit: 1,
    );
    
    if (existingUser.isNotEmpty) {
      // Если пользователь с таким именем или email уже существует
      if (existingUser.first['name'] == name) {
        return -1; // Username exists
      }
      if (existingUser.first['email'] == email) {
        return -2; // Email exists
      }
    }

    // Сохраняем пароль в чистом виде (без хеширования)
    final id = await db.insert('users', {
      'name': name,
      'email': email,
      'password': password,
    });

    return id > 0 ? id : -3; // Проверка успешности вставки
  } catch (e) {
    print('Error inserting user: $e');
    return -3;
  }
}


  // Получение email по имени пользователя
  Future<String?> getEmailByUsername(String username) async {
    final db = await database;
    final result = await db.query(
      'users',
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

  Future<Map<String, dynamic>> getUserById(int userId) async {
  final db = await database;
  final result = await db.query(
    'users',
    where: 'id = ?',
    whereArgs: [userId],
    limit: 1,
  );
  return result.first; // Будьте осторожны с empty result!
}


  Future<List<String>> getCategoriesByType(String type) async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('categories', where: 'type = ?', whereArgs: [type]);

    return maps.map((map) => map['name'] as String).toList();
  }

  Future<void> initDatabase() async {
    if (_database == null) {
      _database = await _initDatabase();
    }
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
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        type TEXT,
        category TEXT,
        date TEXT,
        description TEXT,
        isRecurring INTEGER,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        type TEXT
      )
    ''');

    final defaultCategories = [
      {'name': 'Food', 'type': 'expense'},
      {'name': 'Transport', 'type': 'expense'},
      {'name': 'Shopping', 'type': 'expense'},
      {'name': 'Bills', 'type': 'expense'},
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
        budget_limit REAL, 
        month TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE,
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

// Проверка существования пользователя по имени
  Future<bool> usernameExists(String username) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'name = ?',
      whereArgs: [username],
      limit: 1,
    );
    return result.isNotEmpty;
  }

// Проверка существования email
  Future<bool> emailExists(String email) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    return result.isNotEmpty;
  }

// Получение пользователя по имени
  Future<Map<String, dynamic>?> getUserByUsername(String username) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'name = ?',
      whereArgs: [username],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

}
