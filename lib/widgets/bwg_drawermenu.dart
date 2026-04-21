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
  final TextEditingController _lastNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String firstName = "";
  String lastName = "";
  String nickname = "";
  Color iconColor = bwgRed;
  final viewModel = DrawerViewModel("","");
  final formatter = DateFormat('d MMMM yyyy');

  void _updateNames() {
    setState(() {
      firstName = _capitalise(_firstNameController.text);
      lastName = _capitalise(_lastNameController.text);
      if (_formKey.currentState!.validate()) {
        iconColor = bwgGreen;
      } else {
        iconColor = bwgRed;
      }
    

      if (firstName.isNotEmpty && lastName.isNotEmpty) {
        nickname = "$firstName ${lastName[0]}";
      } else if (firstName.isNotEmpty) {
        nickname = firstName;
      } else {
        nickname = "";
      }
    });
  }

  String _capitalise(String value) {
    if (value.isEmpty) return "";
    return value[0].toUpperCase() + value.substring(1).toLowerCase();
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
    _firstNameController.addListener(_updateNames);
    _lastNameController.addListener(_updateNames);
  }

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView(
        children: [
          ListTile(
            trailing: Icon(Icons.close),
            onTap: () => Navigator.pop(context),
          ),
          Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Row(
                  children: [
                    Expanded(
                      flex: 3, 
                      child: Text(
                        'First name:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: bwgDarkpurple,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 7, 
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
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
                          controller: _firstNameController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your first name';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 3, 
                      child: Text(
                        'Last name:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: bwgDarkpurple,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 7, 
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
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
                          controller: _lastNameController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your last name';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 3, 
                      child: Text(
                        'We use your first and last names to make your nickname. Your nickname will be used on your bookings and other club activities.',
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          color: bwgDarkpurple,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 3, 
                      child: Text(
                        'Nickname:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: bwgDarkpurple,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 7, 
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
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
                          enabled: false,
                          controller: TextEditingController(text: nickname),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                        flex: 7, 
                        child:TextButton(
                        onPressed: () {
                            // Validate returns true if the form is valid, or false otherwise.
                            if (_formKey.currentState!.validate()) {
                              _updateNames();
                              print("Saving a user $firstName $lastName");
                            }
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: iconColor,
                          disabledBackgroundColor: bwgRed
                        ),
                        child: Text(
                          "Save my details",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold
                          )
                          //Theme.of(context).textTheme.titleMedium
                        )
                      ),
                    )
                  ]
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}