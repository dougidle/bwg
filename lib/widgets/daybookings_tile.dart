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
          key: ValueKey('${theBookings[i].player1}-${theBookings[i].player2}-$i'),
        )
      );
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
                    children: <Widget>[
                      Text(
                        '$theFormattedDate - ${bookingsList.length} bookings',
                        style: TextStyle(
                          color: bwgDarkpurple,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0
                        )
                      ),
                      Spacer(),
                      IconButton(
                        onPressed: onToggle, 
                        icon: theIcon
                      ),
                    ]
                  ),
                  Row(
                    children: <Widget>[
                      Text(
                        '${tablesAvailable - tablesUsed} tables available',
                        style: TextStyle(
                          color: bwgDarkpurple,
                          fontWeight: FontWeight.normal,
                          fontSize: 14.0
                        )
                      ),
                      Spacer(),
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