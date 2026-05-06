class GameBooking {
  int player1;
  int player2;
  DateTime bookingDate;
  String gameSystem;
  bool isOrganised;
  int requiredTables;
  String player2Name;

  GameBooking({
    required this.player1,
    required this.player2,
    required this.bookingDate,
    required this.gameSystem,
    required this.isOrganised,
    required this.requiredTables,
    required this.player2Name
  });

  factory GameBooking.fromJson(Map<String, dynamic> json) {
    return GameBooking(
      player1: json['Player1'] as int,
      player2: json['Player2'] as int,
      bookingDate: DateTime.parse(json['BookingDate']),
      gameSystem: json['GameSystem'] as String,
      isOrganised: json['isOrganised'] == 1, 
      requiredTables: json['requiredTables'] as int,
      player2Name: json['Player2Name'] as String,
    );
  }
}

class GameBookingParser {
  static List<GameBooking> parseBookings(List<dynamic> jsonList) {
    return jsonList
        .map((json) => GameBooking.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}