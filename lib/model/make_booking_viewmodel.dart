import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'game_booking.dart';
import 'dart:io';
import '../utilities/load_states.dart';
import '../repositories/user_repository.dart';
import 'logged_in_user.dart';

class MakeBookingViewModel extends ChangeNotifier {
  GameBooking theBooking;
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

  Future<void> createBooking(GameBooking theBookingToMake) async {
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
          'player1': theBooking.player1.toString(),
          'player2': theBooking.player2.toString(),
          'gameSystem': theBooking.gameSystem,
          'theDate': theBooking.bookingDate.toIso8601String(),
          // Convert bool to string and int to string for the POST body
          'isOrganised': theBooking.isOrganised.toString(),
          'requiredTables': theBooking.requiredTables.toString(),
          'player2Name': theBooking.player2Name,
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

  List<DateTime> getNextGameDays(bool isSubscriber) {
    List<DateTime> theAvailableGameDays = [];
    DateTime now = DateTime.now();
    int currentMonth = now.month;

    // Start looking from today at 19:00
    DateTime dateIterator = withTime(now, 19, 00);

    // Find the next Thursday (4), or today if it is a Thursday
    int daysUntilThursday = (DateTime.thursday - dateIterator.weekday + 7) % 7;
    dateIterator = dateIterator.add(Duration(days: daysUntilThursday));

    if (isSubscriber) {
      // Add all Thursdays until the end of the current month
      while (dateIterator.month == currentMonth) {
        theAvailableGameDays.add(dateIterator);
        dateIterator = dateIterator.add(const Duration(days: 7));
      }
    } else {
      // Return only the next Thursday but only if it is at least the Monday before (Mon-Thu)
      if (now.weekday <= DateTime.thursday) {
        theAvailableGameDays.add(dateIterator);
      }
    }
    return theAvailableGameDays;
  }
}
