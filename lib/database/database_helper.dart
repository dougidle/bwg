import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../model/logged_in_user.dart';

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
      version: 2, // Increment the database version
      onCreate: _createDB,
      onUpgrade: _onUpgrade, // Add the onUpgrade callback
    );
  }

  // Create tables
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE loggedInUser (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        authId TEXT NOT NULL,
        userFirstName TEXT NOT NULL,
        userLastName TEXT NOT NULL,
        userNickName TEXT NOT NULL,
        loginType TEXT NOT NULL,
        isSubscriber INTEGER NOT NULL DEFAULT 0 -- Add the new column with a default value
      )
    ''');
  }

  // Handle database schema upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Migrate from version 1 to 2: Add isSubscriber column
      // Provide a default value (0 for false) for existing rows
      await db.execute('ALTER TABLE loggedInUser ADD COLUMN isSubscriber INTEGER NOT NULL DEFAULT 0');
    }
    // Add more migration steps here for future versions if needed
  }

  // Optional: close DB
  Future close() async {
    final db = await instance.database;
    db.close();
  }

  Future<int> insertUser(LoggedInUser theUser) async {
    final db = await instance.database;

    return await db.insert(
      'loggedInUser',
      theUser.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<LoggedInUser>> getAllUsers() async {
    final db = await instance.database;

    final result = await db.query('loggedInUser');

    return result.map((json) => LoggedInUser.fromJson(json)).toList();
  }

  Future<int> deleteAllUsers() async {
    final db = await instance.database;
    
    // Deletes all rows and returns the number of rows affected
    return await db.delete('loggedInUser');
  }
}