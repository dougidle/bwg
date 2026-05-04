class TableBooking {
  DateTime bookingDate;
  String gameSystem;
  String player1;
  String player2;
  bool isOrganised;
  int requiredTables;

  TableBooking({
    required this.bookingDate,
    required this.gameSystem,
    required this.player1,
    required this.player2,
    required this.isOrganised,
    required this.requiredTables,
  });

  factory TableBooking.fromJson(Map<String, dynamic> json) {
    return TableBooking(
      bookingDate: DateTime.parse(json['BookingDate']),
      gameSystem: json['GameSystem'] as String,
      player1: json['Player1'] as String,
      player2: json['Player2'] as String,
      isOrganised: json['isOrganised'] == 1, 
      requiredTables: json['requiredTables'] as int,
    );
  }

}

class TableBookingParser {
  static List<TableBooking> parseBookings(List<dynamic> jsonList) {
    return jsonList
        .map((json) => TableBooking.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}