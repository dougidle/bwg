import 'package:flutter/material.dart';
import 'booking.dart';
import '../resources/bwg_colors.dart';
import 'package:intl/intl.dart';

class MakeBookingTile extends StatefulWidget {
  const MakeBookingTile({super.key});

  @override
  State<MakeBookingTile> createState() => _MakeBookingState();
}

class _MakeBookingState extends State<MakeBookingTile> {
  //final void Function(String) onSubmitGuess;
  final TextEditingController _player1Controller = TextEditingController();
  final TextEditingController _player2Controller = TextEditingController();
  Booking theBooking = Booking(
    bookingDate: DateTime(1970, 1, 1, 0, 0),
    gameSystem: "No game chosen", 
    player1: "", 
    player2: "");
  bool _isExpanded = true;

  List<String> availableGameSystems = [
    "No game chosen",
    "Warhammer 40,000",
    "Warhammer: The Old World",
    "Kill Team",
    "Blood Bowl"
  ];

  bool _isValidBooking() {
    bool isValid = false;

    if (theBooking.player1 != "" && theBooking.player2 !="" && theBooking.gameSystem != "No game chosen" && theBooking.bookingDate != DateTime(1970, 1, 1, 0, 0)) {
      isValid = true;
    }
    return isValid;
  }

  void _reserveGame() {
    print("Player 1: ${theBooking.player1}");
    print("Player 2: ${theBooking.player2}");
    print("Game: ${theBooking.gameSystem}");
    print("Date: ${theBooking.bookingDate.toString()}");
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

  void _setPlayer1() {
    setState(() {
      theBooking.player1= _player1Controller.text;
    });
  }

  void _setPlayer2() {
    setState(() {
      theBooking.player2 = _player2Controller.text;
    });
  }

  DateTime withTime(DateTime date, int hour, int minute) {
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  String dateToString(DateTime theDate) {
    return "${theDate.year}-"
       "${theDate.month.toString().padLeft(2, '0')}-"
       "${theDate.day.toString().padLeft(2, '0')}  "
       "${theDate.hour.toString().padLeft(2, '0')}:"
       "${theDate.minute.toString().padLeft(2, '0')}";
  }

  List<DateTime> getNextGameDays() {
    List<DateTime> theAvailableGameDays = [];
    DateTime currentDate = DateTime.now();
    currentDate = withTime(currentDate, 19, 00);
    int todayDay = currentDate.weekday;

    if (todayDay != 4) {
        var days = (7 - todayDay + 4) % 7;
        currentDate = currentDate.add(Duration(days: days));
    }

    theAvailableGameDays.add(currentDate);
    theAvailableGameDays.add(currentDate.add(Duration(days: 7)));

    return theAvailableGameDays;
}

@override
void initState() {
  super.initState();

  // Start listening to changes.
  _player1Controller.addListener(_setPlayer1);
  _player2Controller.addListener(_setPlayer2);
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
    final List<DateTime> gameDays = getNextGameDays();
    final formatter = DateFormat('d MMMM yyyy');

    // Widget title
    theWidgetList.add(
      Row(
        children: <Widget>[
          Text(
            'Book a game',
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
      )
    );

    // Player 1
    theContentList.add(
      Row(
        children: [
          Expanded(
        flex: 2, 
        child: Text(
          'Player 1:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: bwgDarkpurple,
          ),
        ),
      ),
          Expanded(
            flex: 8, 
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: "Your name",
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: bwgDarkpurple, width: 1),
                    borderRadius: BorderRadius.circular(12),                  
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: bwgDarkpurple, width: 1),
                    borderRadius: BorderRadius.circular(12),                       
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
            flex: 2, 
            child: Text(
              'Player 2:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: bwgDarkpurple,
              ),
            ),
          ),
          Expanded(
            flex: 8, 
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: "Your opponent",
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: bwgDarkpurple, width: 1),
                    borderRadius: BorderRadius.circular(12),                  
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: bwgDarkpurple, width: 1),
                    borderRadius: BorderRadius.circular(12),                       
                  ),
                ),
                controller: _player2Controller, 
              ),
            ),
          ),
        ],
      )
    );

    // Gamesystem dropdown
    theContentList.add(
      Row(
        children: [
          Expanded(
            flex: 2, 
            child: Text(
              'Game:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: bwgDarkpurple,
              ),
            ),
          ),
          Expanded(
            flex: 8, 
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownMenu<String>(
                initialSelection: theBooking.gameSystem,
                expandedInsets: EdgeInsets.zero,
                inputDecorationTheme: InputDecorationTheme(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: bwgDarkpurple, width: 1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                dropdownMenuEntries: [
                  for (var gameSystem in availableGameSystems)
                    DropdownMenuEntry<String>(
                      value: gameSystem,
                      label: gameSystem,
                    ),
                ],
                onSelected: (value) {
                  setState(() {
                    theBooking.gameSystem = value.toString();
                  });
                },
              ),
            ),
          ),
        ],
      )
    );

    // Date dropdown
    theContentList.add(
      Row(
        children: [
          Expanded(
            flex: 2, 
            child: Text(
              'Date:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: bwgDarkpurple,
              ),
            ),
          ),
          Expanded(
            flex: 8, 
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownMenu<DateTime>(
                initialSelection: DateTime(1970, 1, 1, 0, 0),
                expandedInsets: EdgeInsets.zero,
                inputDecorationTheme: InputDecorationTheme(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: bwgDarkpurple, width: 1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                dropdownMenuEntries: [
                  DropdownMenuEntry(
                    value: DateTime(1970, 1, 1, 0, 0), 
                    label: "No date chosen"
                    ),
                  for (var gameDay in gameDays)
                    DropdownMenuEntry<DateTime>(
                      value: gameDay,
                      label: formatter.format(gameDay),
                    ),
                ],
                onSelected: (value) {
                  setState(() {
                    theBooking.bookingDate = value!;
                  });
                },
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
                onPressed: !_isValidBooking() ? null : () {
                  _reserveGame();
                },
                style: TextButton.styleFrom(
                  backgroundColor: bwgDarkpurple,
                  disabledBackgroundColor: bwgRed
                ),
                child: Text(
                  "Book my game",
                   style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold
                   )
                   //Theme.of(context).textTheme.titleMedium
                )
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
        ),
      )
    );
  }
}