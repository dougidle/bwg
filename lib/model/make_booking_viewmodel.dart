import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'booking.dart';
import 'dart:io';
import '../utilities/load_states.dart';
import '../repositories/user_repository.dart';
import 'logged_in_user.dart';

class MakeBookingViewModel extends ChangeNotifier {
  //final MakeBookingViewModel theViewModel;
  Booking theBooking;
  String? errorMessage;
  LoadStates theStatus = LoadStates.editing;
  bool bookingMade = false;
  LoggedInUser? get theLoggedInUser => userRepository.currentUser;
  final userRepository = UserRepository.instance;

  MakeBookingViewModel(this.theBooking) {
    userRepository.addListener(_onUserChanged);
  }

  void _onUserChanged() {
    notifyListeners();
  }

  Future<void> createBooking(Booking theBookingToMake) async {
    theBooking = theBookingToMake;
    final url = Uri.parse(
      'https://musterpointapp.com/api/createGameBooking.php',
    );

    theStatus = LoadStates.loading;
    notifyListeners();
    
    try {
      await http.post(
        url,
        body: {
          'player1': theBooking.player1,
          'player2': theBooking.player2,
          'gameSystem': theBooking.gameSystem,
          'theDate': theBooking.bookingDate.toIso8601String(),
          // Convert bool to string and int to string for the POST body
          'isOrganised': theBooking.isOrganised.toString(),
          'requiredTables': theBooking.requiredTables.toString(),
        },
      );
      errorMessage = null;
    } on HttpException catch (error) {
      errorMessage = error.message;
    }
    theStatus = LoadStates.done;
    notifyListeners();
  }

  void updateStatus(LoadStates theNewStatus) {
    theStatus = theNewStatus;
    notifyListeners();
  }

  DateTime withTime(DateTime date, int hour, int minute) {
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  List<DateTime> getNextGameDays() {
    List<DateTime> theAvailableGameDays = [];
    DateTime currentDate = DateTime.now();
    currentDate = withTime(currentDate, 19, 00);
    int todayDay = currentDate.weekday;

    if (todayDay != 4) {
        var days = (7 - todayDay + 4) % 7;
        currentDate = currentDate.add(Duration(days: days));
    }

    theAvailableGameDays.add(currentDate);
    theAvailableGameDays.add(currentDate.add(Duration(days: 7)));

    return theAvailableGameDays;
  }
}
