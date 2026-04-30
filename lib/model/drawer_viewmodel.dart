import 'package:bwg/model/logged_in_user.dart';
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
  LoggedInUser? get theLoggedInUser => userRepository.currentUser;

  DrawerViewModel(this.firstName, this.lastName);

  void updateStatus(LoadStates theNewStatus) {
    theStatus = theNewStatus;
    notifyListeners();
  }

  Future<void> addUser(LoggedInUser theNewUser) async {
    try {
      final id = await userRepository.insert(theNewUser);
      userRepository.setUser(theNewUser);
      updateStatus(LoadStates.done);
    } catch (e) {
      errorMessage = e.toString();
      updateStatus(LoadStates.error);
    }
  } 

  Future<void> deleteAllUsers() async {
    try {
      await userRepository.deleteAllUsers();
      updateStatus(LoadStates.done);
    } catch (e) {
      errorMessage = e.toString();
      updateStatus(LoadStates.error);
    }
  } 
}
