import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../model/user.dart';

class DatabaseHelper {
  // Singleton instance
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  // Public getter for the database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('bwg.db');
    return _database!;
  }

  // Initialize DB
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  // Create tables
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE loggedInUser (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        authId TEXT NOT NULL,
        userFirstName TEXT NOT NULL,
        userLastName TEXT NOT NULL,
        userNickName TEXT NOT NULL,
        loginType TEXT NOT NULL
      )
    ''');
  }

  // Optional: close DB
  Future close() async {
    final db = await instance.database;
    db.close();
  }

  Future<int> insertUser(User theUser) async {
    final db = await instance.database;

    return await db.insert(
      'loggedInUser',
      theUser.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<User>> getAllUsers() async {
    final db = await instance.database;

    final result = await db.query('loggedInUser');

    return result.map((json) => User.fromMap(json)).toList();
  }
}