import 'package:flutter/material.dart';
import 'bwg_widgets.dart';

class Booking {
  late String player1;
  late String player2;
  late String gameSystem;

  Booking(String player1, String player2, String gameSystem) {
    this.player1 = player1;
    this.player2 = player2;
    this.gameSystem = gameSystem;
  }
}

class DayBookingTile extends StatefulWidget {
  const DayBookingTile(this.theDate, this.theBookings, {super.key});
  final String theDate;
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
                Text('${widget.theDate} - ${bookingsList.length} bookings'),
                Spacer(),
                IconButton(
                  onPressed: _doExpand, 
                  icon: theIcon),
              ]
      )
    );
    if (_isExpanded) {
      theWidgetList += bookingsList;
    }

    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Card(
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