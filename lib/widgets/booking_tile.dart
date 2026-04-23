import 'package:flutter/material.dart';

class BookingTile extends StatelessWidget {
  const BookingTile(this.player1, this.player2, this.gameSystem, {super.key});

  final String player1;
  final String player2;
  final String gameSystem;

  @override
  Widget build(BuildContext context) {
    return Card.filled(
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Text(
                  player1,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Spacer(),
                Text("vs."),
                Spacer(),
                Text(
                  player2,
                  style: TextStyle(fontWeight: FontWeight.bold),
                )
              ]
            ) ,
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