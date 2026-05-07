import 'package:bwg/utilities/load_states.dart';
import 'package:flutter/material.dart';
import '../model/game_booking.dart';
import '../resources/bwg_colors.dart';
import 'package:intl/intl.dart';
import '../model/make_booking_viewmodel.dart';
import '../model/gamer.dart';

class MakeBookingTile extends StatefulWidget {
  final VoidCallback? onBookingMade;
  final List<Gamer> theGamersList;
  const MakeBookingTile({super.key, required this.theGamersList, this.onBookingMade});

  @override
  State<MakeBookingTile> createState() => _MakeBookingState();
}

class _MakeBookingState extends State<MakeBookingTile> {
  final TextEditingController _player1Controller = TextEditingController();
  final TextEditingController _player2Controller = TextEditingController();
  final TextEditingController _player2SearchController = TextEditingController();
  final viewModel = MakeBookingViewModel(
    GameBooking(
      player1: -1,
      player2: 0, // Default to 'No Opponent selected'
      bookingDate: DateTime(1970, 1, 1, 0, 0),
      gameSystem: 'No game chosen', 
      isOrganised: false,
      requiredTables: 0,
      player2Name: ''
    )
  );
  GameBooking theBooking = GameBooking(
    player1: -1, // Default to no player 1 selected
    player2: 0, // Default to 'No Opponent selected'
    bookingDate: DateTime(1970, 1, 1, 0, 0),
    gameSystem: 'No game chosen', 
    isOrganised: false,
    requiredTables: 0,
    player2Name: ''
  );
  bool _isExpanded = true;
  final formatter = DateFormat('d MMMM yyyy');

  Map<String, int> availableGameSystems = {
  'No game chosen': 0,
  'Warhammer 40,000': 2,
  'Warhammer: Age of Sigmar': 2,
  'Warhammer: The Old World': 2,
  'Warhammer: Horus Heresy': 2,
  'Kill Team': 1,
  'Blood Bowl': 1,
};

  bool _isValidBooking() {
    bool isValid = false;

    if (theBooking.player1 > 0 &&
        theBooking.gameSystem != 'No game chosen' &&
        theBooking.bookingDate != DateTime(1970, 1, 1, 0, 0)) {
      // Check player2 based on its value
      if (theBooking.player2 > 0) { // A specific gamer is selected (ID > 0)
        isValid = true;
      } else if (theBooking.player2 == -1) { // "Other" is selected
        if (theBooking.player2Name.isNotEmpty) { // Manual entry must not be empty
          isValid = true;
        }
      }
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

  void _updatePlayer2NameFromController() {
    setState(() {
      theBooking.player2Name = _player2Controller.text;
    });
  }

  @override
  void initState() {
    super.initState();
    // Handle initial value (already loaded from DB)
    final user = viewModel.theLoggedInUser;

    if (user != null && _player1Controller.text.isEmpty) {
      _player1Controller.text = user.userNickName;
      theBooking.player1 = user.userId;
    }

    // 1. ViewModel Listener: Handles user login/status changes
    viewModel.addListener(() {
      final user = viewModel.theLoggedInUser;
      if (mounted && user != null) {
        setState(() {
          _player1Controller.text = user.userNickName;
          theBooking.player1 = user.userId;
        });
      }

      if (viewModel.theStatus == LoadStates.done && mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Barming Wargamers'),
            content: const Text('Your booking has been received.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  viewModel.updateStatus(LoadStates.editing);
                  _player2SearchController.clear();
                  _player2Controller.clear();
                  setState(() {
                    theBooking.player2 = 0;
                    theBooking.player2Name = '';
                    theBooking.gameSystem = 'No game chosen';
                    theBooking.bookingDate = DateTime(1970, 1, 1, 0, 0);
                    widget.onBookingMade?.call(); // Call the callback
                  });
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    });

    // 2. Search Listener: Handles logic for the predictive text box
    _player2SearchController.addListener(() {
      if (mounted) {
        setState(() {
          // Reset selection if the user clears the search box
          if (_player2SearchController.text.isEmpty && theBooking.player2 != 0) {
            theBooking.player2 = 0;
          }
        });
      }
    });

    // 3. Manual Entry Listener
    _player2Controller.addListener(_updatePlayer2NameFromController);
  }

  @override
  Widget build(BuildContext context) {
    final user = viewModel.theLoggedInUser;

    // Sync player1 if it's currently invalid but we have a valid logged-in user.
    // This handles cases where the user ID is loaded after initState or during a refresh.
    if (user != null && theBooking.player1 <= 0 && user.userId > 0) {
      theBooking.player1 = user.userId;
      if (_player1Controller.text.isEmpty) {
        _player1Controller.text = user.userNickName;
      }
    }

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
                  hintText: 'None set',
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
                controller: _player1Controller,
              ),
            ),
          ),
        ],
      ),
    );

    // Player2 dropdown
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
              child: DropdownMenu<int>( // Changed to int
                expandedInsets: EdgeInsets.zero,
                controller: _player2SearchController,
                hintText: 'No Opponent selected',
                menuStyle: _player2SearchController.text.isEmpty
                    ? const MenuStyle(
                        elevation: MaterialStatePropertyAll(0),
                        padding: MaterialStatePropertyAll(EdgeInsets.zero),
                        backgroundColor: MaterialStatePropertyAll(Colors.transparent),
                        shadowColor: MaterialStatePropertyAll(Colors.transparent),
                        surfaceTintColor: MaterialStatePropertyAll(Colors.transparent),
                        // You might need to experiment with other properties like shape, side, etc., if the box persists
                      )
                    : null, // Use default style when not empty
                enableFilter: false, // Disable internal filtering
                requestFocusOnTap: true,
                leadingIcon: Icon(Icons.search, color: bwgDarkpurple),
                trailingIcon: _player2SearchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _player2SearchController.clear();
                          setState(() => theBooking.player2 = 0);
                        },
                      )
                    : null,
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
                dropdownMenuEntries: _buildPlayer2DropdownEntries(),
                onSelected: (value) {
                  setState(() {
                    theBooking.player2 = value!; // value is int now
                    if (value != -1) { // If not "Other"
                      _player2Controller.clear();
                    }
                    // Update the search controller text to reflect the selection
                    // This is important because we disabled internal filtering
                    if (value != 0 && value != -1) { // If a specific gamer is selected
                      final selectedGamer = widget.theGamersList.firstWhere(
                        (g) => g.userId == value,
                        orElse: () => Gamer(userId: -99, nickName: 'Unknown', isSubscriber: false) // Provide a default or handle error
                      );
                      _player2SearchController.text = selectedGamer.nickName;
                    } else if (value == -1) { // "Other" is selected
                      _player2SearchController.text = 'Other';
                    } else { // "No Opponent selected"
                      _player2SearchController.clear();
                    }
                  });
                },
              ),
            ),
          ),
        ],
      )
    );

    // Player 2
    if (theBooking.player2 == -1) { // Only show if "Other" is selected
      theContentList.add(
        Row(
          children: [
            Expanded(
              flex: 2, 
              child: Text(
                '', // Changed label
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
                    fillColor: Colors.white, // Changed hintText
                    hintText: 'Your opponent',
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
    }

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
                  for (var gameSystem in availableGameSystems.keys)
                    DropdownMenuEntry<String>(
                      value: gameSystem,
                      label: gameSystem,
                    ),
                ],
                onSelected: (value) {
                  setState(() {
                    theBooking.gameSystem = value.toString();
                    theBooking.requiredTables = availableGameSystems[value.toString()] ?? 1;
                  });
                },
              ),
            ),
          ),
        ],
      )
    );

    // isOrganised slider
    theContentList.add(
    Row(
      children: [
        Expanded(
          flex: 3, 
          child: Text(
            'The club has a limited number of tables and in extremely busy periods we will prioritise tables for organised events and subscribers.',
            style: TextStyle(
              fontWeight: FontWeight.normal,
              color: bwgDarkpurple,
            ),
          ),
        ),
      ],
    ),
    );

    // isOrganised slider
    theContentList.add(
      Row(
        children: [
          Expanded(
            flex: 2, 
            child: Text(
              'League\nGame?',
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
              child: Align(
                alignment: Alignment.centerRight,
                child: Switch(
                  value: theBooking.isOrganised,
                  onChanged: (bool value) {
                    setState(() {
                      theBooking.isOrganised = value;
                    });
                  },
                ),
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
                    label: 'No date chosen'
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
                // Re-sync player1 just before submission to be absolutely sure
                onPressed: !_isValidBooking() ? null : () {
                  final currentUser = viewModel.theLoggedInUser;
                  if (currentUser != null && currentUser.userId > 0) {
                    theBooking.player1 = currentUser.userId;
                  }
                  viewModel.createBooking(theBooking);
                },
                style: TextButton.styleFrom( // Removed unnecessary comment
                  backgroundColor: bwgDarkpurple,
                  disabledBackgroundColor: bwgRed
                ),
                child: Text(
                  'Book my game',
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

  List<DropdownMenuEntry<int>> _buildPlayer2DropdownEntries() {
    final String searchText = _player2SearchController.text.toLowerCase();
    if (searchText.isEmpty) {
      return [];
    }

    List<DropdownMenuEntry<int>> entries = [];

    final filteredGamers = widget.theGamersList
        .where((g) => g.userId != theBooking.player1 && g.nickName.toLowerCase().contains(searchText))
        .toList()
      ..sort((a, b) => a.nickName.toLowerCase().compareTo(b.nickName.toLowerCase()));

    for (var theOpponent in filteredGamers) {
      entries.add(
        DropdownMenuEntry<int>(
          value: theOpponent.userId,
          label: theOpponent.nickName,
        ),
      );
    }

    entries.add(
        const DropdownMenuEntry<int>(
          value: -1,
          label: 'Other',
        ),
      );

    return entries;
  }

  @override
  void dispose() {
    _player1Controller.dispose();
    _player2Controller.dispose();
    _player2SearchController.dispose();
    super.dispose();
  }
}