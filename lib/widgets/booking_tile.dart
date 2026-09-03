import 'package:flutter/material.dart';
import '../resources/bwg_colors.dart'; // Import bwg_colors for consistent styling
import 'player_row.dart';

class BookingTile extends StatelessWidget {
  const BookingTile(
    this.player1,
    this.player2,
    this.gameSystem,
    this.isOrganised, {
    this.isPlayer1Subscriber = false,
    this.isPlayer2Subscriber = false,
    this.onDelete,
    super.key,
  });

  final String player1;
  final String player2;
  final String gameSystem;
  final bool isOrganised;
  final bool isPlayer1Subscriber;
  final bool isPlayer2Subscriber;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Card.filled(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
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
                )
              ]
            ),
          ),
          PopupMenuButton<void>(
            enabled: onDelete != null,
            tooltip: onDelete != null ? 'Booking options' : 'Only the players in this booking or an admin can cancel it',
            icon: Icon(
              Icons.more_vert,
              color: onDelete != null ? bwgDarkpurple : Colors.grey.shade400,
            ),
            itemBuilder: (context) => <PopupMenuEntry<void>>[
              PopupMenuItem<void>(
                onTap: onDelete,
                height: 32,
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: bwgRed, size: 18),
                    SizedBox(width: 8),
                    Text('Cancel booking'),
                  ],
                ),
              ),
              PopupMenuItem<void>(
                enabled: false,
                height: 32,
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Icon(Icons.swap_horiz, size: 18),
                    SizedBox(width: 8),
                    Text('Change opponent'),
                  ],
                ),
              ),
            ],
          ),
        ]
      )
    );
  }
}