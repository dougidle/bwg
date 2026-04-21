import 'package:bwg/utilities/load_states.dart';
import 'package:flutter/material.dart';
import '../model/booking.dart';
import '../resources/bwg_colors.dart';
import 'package:intl/intl.dart';
import '../model/drawer_viewmodel.dart';

class BWGDrawerMenu extends StatefulWidget {
  const BWGDrawerMenu({super.key});

  @override
  State<BWGDrawerMenu> createState() => _BWGDrawerMenuState();
}

class _BWGDrawerMenuState extends State<BWGDrawerMenu> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _secondNameController = TextEditingController();
  String firstName = "";
  String lastName = "";
  final viewModel = DrawerViewModel("","");
  bool _isExpanded = true;
  final formatter = DateFormat('d MMMM yyyy');

  List<String> availableGameSystems = [
    "No game chosen",
    "Warhammer 40,000",
    "Warhammer: The Old World",
    "Kill Team",
    "Blood Bowl"
  ];

  void _setFirstName() {
    setState(() {
      firstName= _firstNameController.text;
    });
  }

  void _setSecondName() {
    setState(() {
      firstName= _firstNameController.text;
    });
  }

  @override
  void initState() {
    super.initState();

    viewModel.addListener(() {
    /*if (viewModel.theStatus == LoadStates.done) {
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
    }*/
  });

    // Start listening to changes.
    _firstNameController.addListener(_setFirstName);
    _secondNameController.addListener(_setSecondName);
  }

  @override
  Widget build(BuildContext context) {
    
    return SafeArea(
      child: ListView(
        children: [
          ListTile(
            trailing: Icon(Icons.close),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(title: Text("First Name")),
          ListTile(title: Text("Last Name")),
        ],
      ),
    );
  }
}