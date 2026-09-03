import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'game_booking.dart';
import '../utilities/load_states.dart';
import 'dart:convert';
import '../repositories/user_repository.dart';
import 'logged_in_user.dart';
import '../model/gamer.dart';
import '../utilities/app_review_user.dart';

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

  Future<List<GameBooking>> fetchGameBookings() async {
    final pastDate = DateTime.now().toUtc().subtract(const Duration(days: 1));
    final url = Uri.parse(
      'https://musterpointapp.com/api/getBookingsFromDate.php?date=$pastDate',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> decoded = jsonDecode(response.body);
      final bookings = GameBookingParser.parseBookings(decoded);
      final viewerId = theLoggedInUser?.userId;

      // Bookings involving the app review account are only visible to whoever
      // is actually logged in as it - hidden from everyone else, table count included.
      if (viewerId == appReviewUserId) return bookings;
      return bookings
          .where((b) => b.player1 != appReviewUserId && b.player2 != appReviewUserId)
          .toList();
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
      final gamers = GamerParser.parseGamers(decodedResponse);
      final viewerId = theLoggedInUser?.userId;

      // The app review account is always a subscriber and only ever visible
      // to whoever is actually logged in as it.
      return gamers
          .where((g) => g.userId != appReviewUserId || viewerId == appReviewUserId)
          .map((g) {
            if (g.userId == appReviewUserId) g.isSubscriber = true;
            return g;
          })
          .toList();
    } else {
      throw Exception('Failed to load gamers: ${response.statusCode}');
    }
  }

  Future<void> fetchGamer() async {
    final user = theLoggedInUser;
    if (user == null || user.userId <= 0) return;

    final url = Uri.parse(
      'https://musterpointapp.com/api/getGamer.php?UserId=${user.userId}',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      final Map<String, dynamic> gamerData = responseBody['data'] as Map<String, dynamic>;

      final currentUser = theLoggedInUser;
      if (currentUser != null) {
        currentUser.userNickName = gamerData['NickName'] ?? currentUser.userNickName;
        // The app review account's subscriber status must never be reset by the server.
        currentUser.isSubscriber = currentUser.userId == appReviewUserId ||
            gamerData['isSubscriber'] == 1 ||
            gamerData['isSubscriber'] == true;

        await deleteAllUsers();
        await addUser(currentUser);
      }
    } else {
      throw Exception('Failed to load gamer: ${response.statusCode}');
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