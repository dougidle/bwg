import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'bwg_widgets.dart';
import '../model/booking.dart';
import '../resources/bwg_colors.dart';

class DayBookingTile extends StatelessWidget {
  const DayBookingTile(
    this.theDate,
    this.theBookings, {
    required this.isExpanded,
    required this.onToggle,
    super.key,
  });

  final DateTime theDate;
  final List<Booking> theBookings;
  final bool isExpanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final int tablesAvailable = 24;
    final formatter = DateFormat('d MMMM yyyy');
    String theFormattedDate = formatter.format(theDate);
    String theTableText = "";
    Color theTableColor = bwgDarkpurple;

    Icon theIcon;
    if (isExpanded) {
      theIcon = Icon(Icons.expand_less);
    } else {
      theIcon = Icon(Icons.expand_more);
    }

    List<Widget> bookingsList = [];
    int tablesUsed = 0;

    for (var i = 0; i < theBookings.length; i++) {
      tablesUsed += theBookings[i].requiredTables;
      bookingsList.add(
        BookingTile(
          theBookings[i].player1, 
          theBookings[i].player2,
          theBookings[i].gameSystem,
          theBookings[i].isOrganised,
          key: ValueKey('${theBookings[i].player1}-${theBookings[i].player2}-$i'),
        )
      );
    }

    switch (tablesUsed) {
      case <=20:
        theTableText = "${24 - tablesUsed} tables available";
        theTableColor = bwgGreen;
        break;
      case >20 && <=24:
        theTableText = "${24 - tablesUsed} tables available";
        theTableColor = bwgOrange;
        break;
      default:
        theTableText = "This club night is oversubscribed";
        theTableColor = bwgRed;
        break;
    }

    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Card(
        color: bwgLilac,
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$theFormattedDate - ${bookingsList.length} bookings',
                          style: TextStyle(
                            color: bwgDarkpurple,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        ),
                        Text(
                          theTableText,
                          style: TextStyle(
                            color: theTableColor,
                            fontWeight: FontWeight.normal,
                            fontSize: 14.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                      IconButton(
                        onPressed: onToggle, 
                        icon: theIcon
                      ),
                    ]
                  ),
                  if (isExpanded) ...bookingsList,
                ]
              ) ,
            ),
          ]
        )
      )
    );
  }
}