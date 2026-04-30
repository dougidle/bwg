import 'package:flutter/material.dart';
import '../model/logged_in_user.dart';
import '../database/database_helper.dart';

class UserRepository extends ChangeNotifier {
  static final UserRepository instance = UserRepository._init();
  UserRepository._init();

  final dbHelper = DatabaseHelper.instance;

  LoggedInUser? _currentUser;

  LoggedInUser? get currentUser => _currentUser;

  // 🔹 Set user (e.g. after login)
  void setUser(LoggedInUser user) {
    _currentUser = user;
    notifyListeners();
  }

  // 🔹 Load user from DB (e.g. on app start)
  Future<void> loadUser() async {
    final users = await dbHelper.getAllUsers();

    if (users.isNotEmpty) {
      _currentUser = users.first;
      notifyListeners();
    }
  }

  // 🔹 Save user + set as current
  Future<void> saveUser(LoggedInUser user) async {
    await dbHelper.insertUser(user);
    _currentUser = user;
    notifyListeners();
  }

  // 🔹 Existing methods (optional to keep)
  Future<int> insert(LoggedInUser user) async {
    return await dbHelper.insertUser(user);
  }

  Future<List<LoggedInUser>> getAll() async {
    return await dbHelper.getAllUsers();
  }

  Future<void> deleteAllUsers() async {
    await dbHelper.deleteAllUsers();
    _currentUser = null;
    notifyListeners();
  }
}