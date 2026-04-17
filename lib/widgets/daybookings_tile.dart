import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'bwg_widgets.dart';
import 'booking.dart';
import '../resources/bwg_colors.dart';
import '../utilities/datetime.dart';

class DayBookingTile extends StatefulWidget {
  const DayBookingTile(this.theDate, this.theBookings, {super.key});
  final DateTime theDate;
  final List<Booking> theBookings;

  @override
  State<DayBookingTile> createState() => _DayBookingState();
}

class _DayBookingState extends State<DayBookingTile> {
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
    String theDate = formatter.format(widget.theDate);

    Icon theIcon;
    if (_isExpanded) {
      theIcon = Icon(Icons.expand_less);
    } else {
      theIcon = Icon(Icons.expand_more);
    }

    List<Widget> theWidgetList = [];
    List<Widget> bookingsList = [];

    for (var i = 0; i < widget.theBookings.length; i++) {
      bookingsList.add(BookingTile(widget.theBookings[i].player1, widget.theBookings[i].player2,widget.theBookings[i].gameSystem));
    }

    theWidgetList.add(
      Row(
        children: <Widget>[
          Text(
            '$theDate - ${bookingsList.length} bookings',
            style: TextStyle(
              color: bwgDarkpurple,
              fontWeight: FontWeight.bold,
              fontSize: 16.0
            )
          ),
          Spacer(),
          IconButton(
            onPressed: _doExpand, 
            icon: theIcon
          ),
        ]
      )
    );
    if (_isExpanded) {
      theWidgetList += bookingsList;
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
                children: 
                  theWidgetList
              ) ,
            ),
          ]
        )
      )
    );
  }
}