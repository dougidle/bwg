import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/table_booking.dart';
import '../resources/bwg_colors.dart';
import '../widgets/booking_tile.dart';

class MyBookingsTile extends StatefulWidget {
  final List<TableBooking> myBookings;
  const MyBookingsTile({super.key, required this.myBookings});

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
    final formatter = DateFormat('d MMMM yyyy');
    String theTableText = '';
    Color theTableColor = bwgDarkpurple;

    Icon theIcon;
    if (_isExpanded) {
      theIcon = Icon(Icons.expand_less);
    } else {
      theIcon = Icon(Icons.expand_more);
    }

    List<Widget> bookingsList = [];
    for (var i = 0; i < widget.myBookings.length; i++) {
      bookingsList.add(
        BookingTile(
          widget.myBookings[i].player1, 
          widget.myBookings[i].player2,
          widget.myBookings[i].gameSystem,
          widget.myBookings[i].isOrganised,
          key: ValueKey('${widget.myBookings[i].player1}-${widget.myBookings[i].player2}-$i'),
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
                        'My bookings',
                        style: TextStyle(
                          color: bwgDarkpurple,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0
                        )
                      ),
                      Spacer(),
                      IconButton(
                        onPressed: _doExpand, 
                        icon: theIcon),
                    ]
                  ),
                  if (_isExpanded) ...bookingsList,
                ]
              ),
            ),
          ]
        )
      )
    );
  }
}