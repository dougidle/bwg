import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'table_booking.dart';
import 'game_booking.dart';
import '../utilities/load_states.dart';
import 'dart:convert';
import '../repositories/user_repository.dart';
import 'logged_in_user.dart';
import '../model/gamer.dart';

class BWGHomePageViewModel extends ChangeNotifier {
  String? errorMessage;
  LoadStates theStatus = LoadStates.editing;
  bool bookingMade = false;
  final userRepository = UserRepository.instance;
  LoggedInUser? get theLoggedInUser => userRepository.currentUser;

  BWGHomePageViewModel() {
    userRepository.addListener(_onUserChanged);
    _onUserChanged();
  }

  void _onUserChanged() {
    notifyListeners();
  }

  Future<List<TableBooking>> fetchBookings() async {
    final pastDate = DateTime.now().toUtc().subtract(const Duration(days: 1));
    final url = Uri.parse(
      'https://musterpointapp.com/api/getTableBookingsFromDate.php?date=$pastDate',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> decoded = jsonDecode(response.body);

      return TableBookingParser.parseBookings(decoded);
    } else {
      throw Exception('Failed to load bookings: ${response.statusCode}');
    }
  }

  Future<List<GameBooking>> fetchGameBookings() async {
    final pastDate = DateTime.now().toUtc().subtract(const Duration(days: 1));
    final url = Uri.parse(
      'https://musterpointapp.com/api/getBookingsFromDate.php?date=$pastDate',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> decoded = jsonDecode(response.body);

      return GameBookingParser.parseBookings(decoded);
    } else {
      throw Exception('Failed to load bookings: ${response.statusCode}');
    }
  }

  Future<List<Gamer>> fetchGamers() async {
    final url = Uri.parse(
      'https://musterpointapp.com/api/getGamers.php',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> decodedResponse = jsonDecode(response.body);
      return GamerParser.parseGamers(decodedResponse);
    } else {
      throw Exception('Failed to load gamers: ${response.statusCode}');
    }
  }

  Map<DateTime, List<GameBooking>> groupGameBookingsByDate(List<GameBooking> bookings) {
    final Map<DateTime, List<GameBooking>> grouped = {};

    for (var booking in bookings) {
      // Normalize to just the date (remove time)
      final dateOnly = DateTime(
        booking.bookingDate.year,
        booking.bookingDate.month,
        booking.bookingDate.day,
      );
      grouped.putIfAbsent(dateOnly, () => []).add(booking);
    }
    return grouped;
  }

  void updateStatus(LoadStates theNewStatus) {
    theStatus = theNewStatus;
    notifyListeners();
  }

  Future<void> addUser(LoggedInUser user) async {
    await userRepository.saveUser(user);
    notifyListeners();
  }

  Future<void> deleteAllUsers() async {
    await userRepository.deleteAllUsers();
    notifyListeners();
  }
}