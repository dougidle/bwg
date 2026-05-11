import 'package:flutter/material.dart';
import '../model/game_booking.dart';
import '../resources/bwg_colors.dart';
import '../widgets/my_bookings_tile.dart';
import '../model/gamer.dart';

class MyBookingsTile extends StatefulWidget {
  final List<GameBooking> myBookings;
  final List<Gamer> theGamersList;
  const MyBookingsTile({super.key, required this.myBookings, required this.theGamersList});

  @override
  State<MyBookingsTile> createState() => _MyBookingsTile();
}

class _MyBookingsTile extends State<MyBookingsTile> {
  bool _isExpanded = true;

  void _setExpanded() {
    setState(() {
    _isExpanded = true;
    });
  }

  void _setCollapsed() {
    setState(() {
    _isExpanded = false;
    });
  }

  void _doExpand() {
    if (_isExpanded) {
      _setCollapsed();
    } else {
      _setExpanded();
    }
  }

  @override
  Widget build(BuildContext context) {
    Icon theIcon;
    if (_isExpanded) {
      theIcon = Icon(Icons.expand_less);
    } else {
      theIcon = Icon(Icons.expand_more);
    }

    List<Widget> bookingsList = [];
    for (var i = 0; i < widget.myBookings.length; i++) {
      final booking = widget.myBookings[i];

      final p1Gamer = widget.theGamersList.cast<Gamer?>().firstWhere(
            (g) => g?.userId == booking.player1,
            orElse: () => null,
          );

      String p2Name = 'No Opponent';
      bool p2Sub = false;
      if (booking.player2 == -1) {
        p2Name = booking.player2Name;
      } else if (booking.player2 > 0) {
        final p2Gamer = widget.theGamersList.cast<Gamer?>().firstWhere(
              (g) => g?.userId == booking.player2,
              orElse: () => null,
            );
        p2Name = p2Gamer?.nickName ?? 'Unknown';
        p2Sub = p2Gamer?.isSubscriber ?? false;
      }

      bookingsList.add(
        MyBookingTile(
          player1: p1Gamer?.nickName ?? 'Unknown',
          player2: p2Name,
          gameSystem: booking.gameSystem,
          bookingDate: booking.bookingDate,
          isOrganised: booking.isOrganised,
          isPlayer1Subscriber: p1Gamer?.isSubscriber ?? false,
          isPlayer2Subscriber: p2Sub,
          key: ValueKey('${booking.player1}-${booking.player2}-$i'),
        )
      );
    }

    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Card(
        color: bwgLilac,
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(
                    'My bookings',
                    style: TextStyle(
                      color: bwgDarkpurple,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0
                    )
                  ),
                  Spacer(),
                  IconButton(onPressed: _doExpand, icon: theIcon),
                ]
              ),
              if (_isExpanded) ...bookingsList,
            ]
          ),
        )
      )
    );
  }
}