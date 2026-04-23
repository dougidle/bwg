import 'package:bwg/model/user.dart';
import 'package:flutter/material.dart';
import '../utilities/load_states.dart';
import '../database/database_helper.dart';
import '../repositories/user_repository.dart';

class DrawerViewModel extends ChangeNotifier {
  String firstName = ""; 
  String lastName = "";
  String? errorMessage;
  LoadStates theStatus = LoadStates.editing;
  bool bookingMade = false;
  final db = DatabaseHelper.instance;
  final userRepository = UserRepository();

  DrawerViewModel(this.firstName, this.lastName);

  void updateStatus(LoadStates theNewStatus) {
    theStatus = theNewStatus;
    notifyListeners();
  }

  Future<void> addUser(User theNewUser) async {

  final id = await userRepository.insert(theNewUser);

  print('Inserted user with nickname: ${theNewUser.userNickName} and id: $id');
}


}
