import 'package:bwg/utilities/load_states.dart';
import 'package:flutter/material.dart';
import '../model/booking.dart';
import '../resources/bwg_colors.dart';
import 'package:intl/intl.dart';
import '../model/make_booking_viewmodel.dart';

class MakeBookingTile extends StatefulWidget {
  const MakeBookingTile({super.key});

  @override
  State<MakeBookingTile> createState() => _MakeBookingState();
}

class _MakeBookingState extends State<MakeBookingTile> {
  final TextEditingController _player1Controller = TextEditingController();
  final TextEditingController _player2Controller = TextEditingController();
  Booking theBooking = Booking(
    bookingDate: DateTime(1970, 1, 1, 0, 0),
    gameSystem: "No game chosen", 
    player1: "", 
    player2: "");
  final viewModel = MakeBookingViewModel(Booking(bookingDate: DateTime(1970, 1, 1, 0, 0),gameSystem: "No game chosen",player1: "",player2: ""));
  bool _isExpanded = true;
  final formatter = DateFormat('d MMMM yyyy');

  List<String> availableGameSystems = [
    "No game chosen",
    "Warhammer 40,000",
    "Warhammer: The Old World",
    "Warhammer: Horus Heresy",
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

  /*@override
  void didChangeDependencies() {
    super.didChangeDependencies();
    viewModel.fetchLoggedInUser();
  }*/

  @override
  void initState() {
    super.initState();
    // Handle initial value (already loaded from DB)
    final user = viewModel.theLoggedInUser;

    if (user != null && _player1Controller.text.isEmpty) {
      _player1Controller.text = user.userNickName;
      theBooking.player1 = user.userNickName;
    }

    // Handle future updates
    viewModel.addListener(() {
      final user = viewModel.theLoggedInUser;

      if (user != null && _player1Controller.text.isEmpty) {
        _player1Controller.text = viewModel.theLoggedInUser!.userNickName;
        theBooking.player1 = viewModel.theLoggedInUser!.userNickName;

      //_player1AutoFilled = true;
    }
    
    if (viewModel.theStatus == LoadStates.done) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Barming Wargamers"),
          content: Text("Your booking between ${theBooking.player1} and ${theBooking.player2} to play ${theBooking.gameSystem} on ${formatter.format(theBooking.bookingDate)} has been received."),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                viewModel.updateStatus(LoadStates.editing);
                _player1Controller.clear();
                _player2Controller.clear();
                setState(() {
                  theBooking = Booking(
                    bookingDate: DateTime(1970, 1, 1, 0, 0),
                    gameSystem: "No game chosen",
                    player1: "",
                    player2: "");
                });
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  });

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
    final List<DateTime> gameDays = viewModel.getNextGameDays();

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
              child: TextFormField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: "None set",
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: bwgDarkpurple, width: 1),
                    borderRadius: BorderRadius.circular(12),                  
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: bwgDarkpurple, width: 1),
                    borderRadius: BorderRadius.circular(12),                  
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: bwgDarkpurple, width: 1),
                    borderRadius: BorderRadius.circular(12),                       
                  ),
                ),
                enabled: false,
                controller: TextEditingController(text: theBooking.player1),
              ),
            ),
          ),
        ],
      ),
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
                  viewModel.createBooking(theBooking);
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
        child: ListenableBuilder(
          listenable: viewModel, 
          builder: (context, child) {
            return switch ((
            viewModel.theStatus)) {
              (LoadStates.loading) => 
                CircularProgressIndicator(),
              _ => Column(
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
            };
          } 
        )
      )
    );
  }
}