import 'package:flutter/material.dart';
import 'booking.dart';

class MakeBookingTile extends StatefulWidget {
  const MakeBookingTile({super.key});

  @override
  State<MakeBookingTile> createState() => _MakeBookingState();
}

class _MakeBookingState extends State<MakeBookingTile> {
  //final void Function(String) onSubmitGuess;
  final TextEditingController _player1Controller = TextEditingController();
  final TextEditingController _player2Controller = TextEditingController();
  Booking theBooking = Booking("", "", "");
  bool _isExpanded = true;

  void _reserveGame() {
    theBooking.player1 = _player1Controller.text;
    theBooking.player2 = _player2Controller.text;
    print("Player 1: ${theBooking.player1}");
    print("Player 2: ${theBooking.player2}");
    _player1Controller.clear();
    _player2Controller.clear();
  }

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

    List<Widget> theContentList = [];
    List<Widget> theWidgetList = [];

    // Widget title
    theWidgetList.add(
      Row(
        children: <Widget>[
          Text('Book a game'),
          Spacer(),
          IconButton(
            onPressed: _doExpand, 
            icon: theIcon),
        ]
      )
    );

    // Player 1
    theContentList.add(
      Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Player 1"),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(35)),
                  ),
                ),
                controller: _player1Controller, 
              ),
            ),
          ),
        ],
      )
    );

    // Player 2
    theContentList.add(
      Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Player 2"),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(35)),
                  ),
                ),
                controller: _player2Controller, 
              ),
            ),
          ),
        ],
      )
    );

    // Submit button
    theContentList.add(
      Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextButton(
                onPressed: (){
                  _reserveGame();
                },
                child: Text("Book my game")
              ),
            ),
          ),
        ],
      )
    );

    if (_isExpanded) {
      theWidgetList += theContentList;
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