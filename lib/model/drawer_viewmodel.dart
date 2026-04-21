import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'booking.dart';
import 'dart:io';
import '../utilities/load_states.dart';

class DrawerViewModel extends ChangeNotifier {
  String firstName = ""; 
  String lastName = "";
  String? errorMessage;
  LoadStates theStatus = LoadStates.editing;
  bool bookingMade = false;

  DrawerViewModel(this.firstName, this.lastName);

  void updateStatus(LoadStates theNewStatus) {
    theStatus = theNewStatus;
    notifyListeners();
  }
}
