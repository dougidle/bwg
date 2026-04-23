import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../model/user.dart';
import '../database/database_helper.dart';

class UserRepository {
  final dbHelper = DatabaseHelper.instance;

  Future<int> insert(User theUser) async {
    return await dbHelper.insertUser(theUser);
  }
}