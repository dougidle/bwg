class Booking {
  DateTime bookingDate;
  String gameSystem;
  String player1;
  String player2;
  bool isOrganised;
  int requiredTables;

  Booking({
    required this.bookingDate,
    required this.gameSystem,
    required this.player1,
    required this.player2,
    required this.isOrganised,
    required this.requiredTables,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      bookingDate: DateTime.parse(json['BookingDate']),
      gameSystem: json['GameSystem'] as String,
      player1: json['Player1'] as String,
      player2: json['Player2'] as String,
      isOrganised: json['isOrganised'] == 1, 
      requiredTables: json['requiredTables'] as int,
    );
  }

}

class BookingParser {
  static List<Booking> parseBookings(List<dynamic> jsonList) {
    return jsonList
        .map((json) => Booking.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}