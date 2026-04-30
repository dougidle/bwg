import 'package:flutter/material.dart';
import '../resources/bwg_colors.dart';
import 'package:intl/intl.dart';
import '../model/drawer_viewmodel.dart';
import '../model/logged_in_user.dart';


class BWGDrawerMenu extends StatefulWidget {
  const BWGDrawerMenu({super.key});

  @override
  State<BWGDrawerMenu> createState() => _BWGDrawerMenuState();
}

class _BWGDrawerMenuState extends State<BWGDrawerMenu> {
  late TextEditingController _firstNameController = TextEditingController();
  late TextEditingController _lastNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String firstName = "";
  String lastName = "";
  String nickname = "";
  Color iconColor = bwgRed;
  final viewModel = DrawerViewModel("","");
  final formatter = DateFormat('d MMMM yyyy');

  void makeNickname() {
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
        nickname = "$firstName ${lastName[0]}";
      } else if (firstName.isNotEmpty) {
        nickname = firstName;
      } else {
        nickname = "";
      }
  }

  void _updateNames() {
    setState(() {
      firstName = _capitalise(_firstNameController.text);
      lastName = _capitalise(_lastNameController.text);
      if (_formKey.currentState!.validate()) {
        iconColor = bwgGreen;
      } else {
        iconColor = bwgRed;
      }
      makeNickname();
    });
  }

  String _capitalise(String value) {
    if (value.isEmpty) return "";
    return value[0].toUpperCase() + value.substring(1).toLowerCase();
  }

  @override
  void initState() {
    super.initState();
    final user = viewModel.theLoggedInUser;

    _firstNameController = TextEditingController(
      text: user != null ? user.userFirstName : "",
    );

    _lastNameController = TextEditingController(
      text: user != null ? user.userLastName : "",
    );
    firstName = _capitalise(_firstNameController.text);
    lastName = _capitalise(_lastNameController.text);
    makeNickname();

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
                            hintText: "Your first name",
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
                            hintText: "Your last name",
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
                              viewModel.deleteAllUsers();
                              viewModel.addUser(
                                LoggedInUser(
                                  authId: "",
                                  userFirstName: firstName,
                                  userLastName: lastName,
                                  userNickName: nickname,
                                  loginType: ""
                                )
                              );
                              Navigator.pop(context);
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