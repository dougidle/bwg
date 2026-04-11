import 'package:flutter/material.dart';

class BookingTile extends StatelessWidget {
  const BookingTile(this.player1, this.player2, this.gameSystem, {super.key});

  final String player1;
  final String player2;
  final String gameSystem;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Text(player1),
                Spacer(),
                Text("vs."),
                Spacer(),
                Text(player2)
              ]
            ) ,
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Text(gameSystem),
                Spacer()
              ]
            )
          )
        ]
      )
    );
  }
}