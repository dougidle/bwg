import 'package:bwg/model/user.dart';
import 'package:flutter/material.dart';
import '../utilities/load_states.dart';
import '../repositories/user_repository.dart';

class DrawerViewModel extends ChangeNotifier {
  String firstName = ""; 
  String lastName = "";
  String? errorMessage;
  LoadStates theStatus = LoadStates.editing;
  bool bookingMade = false;
  final userRepository = UserRepository.instance;

  DrawerViewModel(this.firstName, this.lastName);

  void updateStatus(LoadStates theNewStatus) {
    theStatus = theNewStatus;
    notifyListeners();
  }

  Future<void> addUser(User theNewUser) async {
    try {
      final id = await userRepository.insert(theNewUser);
      userRepository.setUser(theNewUser);

      print('Inserted user with nickname: ${theNewUser.userNickName} and id: $id');
      final allUsers = await userRepository.getAll();

      for (final d in allUsers) {
        print('DRAWER: firstname=${d.userFirstName}, lastname=${d.userLastName}, nickname=${d.userNickName}');
      }
      updateStatus(LoadStates.done);
    } catch (e) {
      errorMessage = e.toString();
      updateStatus(LoadStates.error);
    }
  } 
}
