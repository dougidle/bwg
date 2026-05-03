import 'package:bwg/model/logged_in_user.dart';
import 'package:flutter/material.dart';
import '../utilities/load_states.dart';
import '../repositories/user_repository.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
    updateStatus(LoadStates.loading); // Good practice to show a spinner
  
    try {
      // 1. Call the API to Get or Create the User in the MySQL DB
      final response = await http.post(
        Uri.parse("https://musterpointapp.com/api/createNewUser.php"),
        body: {
          'AuthId': theNewUser.authId,
          'NickName': theNewUser.userNickName
        }, 
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['error'] == false) {
          // 2. Extract the UserId and update the object
          // If your LoggedInUser is immutable (final fields), use a copyWith method
          int returnedId = data['userId'];
          theNewUser.userId = returnedId; 

          // 3. Now write the updated user to your local repository
          await userRepository.insert(theNewUser);
          userRepository.setUser(theNewUser);
          
          updateStatus(LoadStates.done);
        } else {
          throw Exception(data['message']);
        }
      } else {
        throw Exception("Server error: ${response.statusCode}");
      }
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
