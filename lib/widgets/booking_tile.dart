import 'package:flutter/material.dart';
import '../resources/bwg_colors.dart'; // Import bwg_colors for consistent styling

class BookingTile extends StatelessWidget {
  const BookingTile(
    this.player1,
    this.player2,
    this.gameSystem,
    this.isOrganised, {
    this.isPlayer1Subscriber = false,
    this.isPlayer2Subscriber = false,
    super.key,
  });

  final String player1;
  final String player2;
  final String gameSystem;
  final bool isOrganised;
  final bool isPlayer1Subscriber;
  final bool isPlayer2Subscriber;

  @override
  Widget build(BuildContext context) {
    return Card.filled(
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      player1,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (isPlayer1Subscriber) ...[
                      SizedBox(width: 4),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: bwgDarkpurple,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Member',
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ),
                    ],
                  ],
                ),
                Spacer(),
                Text('vs.'),
                Spacer(),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isPlayer2Subscriber) ...[
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: bwgDarkpurple, borderRadius: BorderRadius.circular(10)),
                        child: Text('Member', style: TextStyle(color: Colors.white, fontSize: 10)),
                      ),
                      SizedBox(width: 4),
                    ],
                    Text(player2, style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                )
              ]
            ) ,
          ),
          if (isOrganised)
            Padding(
              padding: EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
              child: Row(
                children: <Widget>[
                  Text(
                    'League Game',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Spacer()
                ]
              )
            ),
          Padding(
            padding: EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
            child: Row(
              children: <Widget>[
                Text(
                  gameSystem,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Spacer()
              ]
            )
          )
        ]
      )
    );
  }
}