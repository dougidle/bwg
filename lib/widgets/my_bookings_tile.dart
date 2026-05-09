import 'package:flutter/material.dart';
import '../resources/bwg_colors.dart'; 
import 'package:intl/intl.dart';
import 'player_row.dart';

class MyBookingTile extends StatelessWidget {
  const MyBookingTile({
    required this.player1,
    required this.player2,
    required this.gameSystem,
    required this.bookingDate,
    required this.isOrganised,
    required this.isPlayer1Subscriber,
    required this.isPlayer2Subscriber,
    super.key,
  });

  final String player1;
  final String player2;
  final String gameSystem;
  final DateTime bookingDate;
  final bool isOrganised;
  final bool isPlayer1Subscriber;
  final bool isPlayer2Subscriber;

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('d MMMM yyyy');
    String theFormattedDate = formatter.format(bookingDate);

    return Card.filled(
      child: Column(
        children: <Widget>[
          PlayerRow(
            player1: player1,
            player2: player2,
            isPlayer1Subscriber: isPlayer1Subscriber,
            isPlayer2Subscriber: isPlayer2Subscriber,
          ),
          Padding(
              padding: EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
              child: Row(
                children: <Widget>[
                  Text(
                    theFormattedDate,
                     style: TextStyle(fontWeight: FontWeight.bold)
                  ),
                  Spacer()
                ]
              )
            ),
          Padding(
            padding: EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
            child: Row(
              children: <Widget>[
                if (isOrganised) ...[
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: bwgDarkpurple, borderRadius: BorderRadius.circular(10)),
                    child: Text('League Game', style: TextStyle(color: Colors.white, fontSize: 10)),
                  ),
                  SizedBox(width: 4),
                ],
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: bwgDarkpurple, borderRadius: BorderRadius.circular(10)),
                  child: Text(gameSystem, style: TextStyle(color: Colors.white, fontSize: 10)),
                ),
              ]
            )
          ),
        ]
      )
    );
  }
}