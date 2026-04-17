import 'dart:convert';
import 'package:http/http.dart' as http;

class Booking {
  DateTime bookingDate;
  String gameSystem;
  String player1;
  String player2;

  Booking({
    required this.bookingDate,
    required this.gameSystem,
    required this.player1,
    required this.player2,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      bookingDate: DateTime.parse(json['BookingDate']),
      gameSystem: json['GameSystem'] as String,
      player1: json['Player1'] as String,
      player2: json['Player2'] as String,
    );
  }

  Future<bool> createBooking() async {
    final url = Uri.parse(
      'https://musterpointapp.com/api/createGameBooking.php',
    );

    final response = await http.post(
      url,
      body: {
        'player1': player1,
        'player2': player2,
        'gameSystem': gameSystem,
        'theDate': bookingDate.toIso8601String(),
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return decoded['error'] == false;
    } else {
      throw Exception('Failed to create booking with errorcode ${response.statusCode}');
    }
  }
}

class BookingParser {
  static List<Booking> parseBookings(List<dynamic> jsonList) {
    return jsonList
        .map((json) => Booking.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}