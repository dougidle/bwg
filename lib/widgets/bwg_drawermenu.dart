import 'package:flutter/material.dart';
import '../resources/bwg_colors.dart';
import 'package:intl/intl.dart';
import '../model/drawer_viewmodel.dart';
import '../model/logged_in_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:convert';
import '../repositories/user_repository.dart';

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
  User? user;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Widget googleSignInButton() {
    return OutlinedButton(
      onPressed: signInWithGoogle,
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        side: const BorderSide(color: Colors.grey, width: 0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2), // Google uses a very slight radius
        ),
        padding: EdgeInsets.zero, // We'll handle padding inside the Row
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // The Google Logo "G"
          Padding(
            padding: const EdgeInsets.all(1.0), // Creates the border effect
            child: Container(
              height: 38, // Button height minus padding
              width: 38,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(2),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0), // Space around the G
                child: Image.network(
                  'https://pngimg.com/uploads/google/google_PNG19635.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Text(
              'Sign in with Google',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: 'Roboto', // Ensure you have Roboto in pubspec.yaml
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Map<String, dynamic>? parseJwt(String? token) {
    // validate token
    if (token == null) return null;
    final List<String> parts = token.split('.');
    if (parts.length != 3) {
      return null;
    }
    // retrieve token payload
    final String payload = parts[1];
    String normalized = payload;
    if (normalized.length % 4 != 0) {
      normalized = normalized.padRight(normalized.length + (4 - normalized.length % 4) % 4, '=');
    }
    final String resp = utf8.decode(base64Url.decode(normalized));
    // convert to Map
    final payloadMap = json.decode(resp);
    if (payloadMap is! Map<String, dynamic>) {
      return null;
    }
    return payloadMap;
  }

  Future<void> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) return; // User canceled
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      final idToken = googleAuth.idToken;
      final idMap = parseJwt(idToken);

      if (idMap != null) {
        final String firstName = idMap["given_name"] ?? "";
        final String lastName = idMap["family_name"] ?? "";

        _firstNameController.text = firstName;
        _lastNameController.text = lastName;
        makeNickname();
        
        // Persist the user info so other widgets (like the Drawer) are updated
        await UserRepository.instance.saveUser(LoggedInUser(
          userId: -1,
          authId: user!.uid,
          userFirstName: firstName,
          userLastName: lastName,
          userNickName: firstName.isNotEmpty ? "$firstName ${lastName.isNotEmpty ? lastName[0] : ''}" : "",
          loginType: "Google",
        ));
      }

      setState(() => user = userCredential.user);
    } catch (e) {
      debugPrint("Sign-in error: $e");
    }
  }

  void signOutWithGoogle() async {
    await _googleSignIn.signOut();
    await FirebaseAuth.instance.signOut();
    setState(() => user = null);
  }

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
    user = FirebaseAuth.instance.currentUser;
    
    final loggedInUser = viewModel.theLoggedInUser;

    _firstNameController = TextEditingController(
      text: loggedInUser != null ? loggedInUser.userFirstName : "",
    );

    _lastNameController = TextEditingController(
      text: loggedInUser != null ? loggedInUser.userLastName : "",
    );
    firstName = _capitalise(_firstNameController.text);
    lastName = _capitalise(_lastNameController.text);
    makeNickname();

    // Start listening to changes.
    _firstNameController.addListener(_updateNames);
    _lastNameController.addListener(_updateNames);
    viewModel.addListener(_onViewModelChanged);
  }

  void _onViewModelChanged() {
    if (mounted) setState(() {});
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
          Card(
            color: bwgLilac,
            child: viewModel.theLoggedInUser == null
          ? Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: <Widget>[
                      Text(
                        'User Details',
                        style: TextStyle(
                          color: bwgDarkpurple,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0
                        )
                      ),
                      Spacer(),
                    ]
                  ),
                  googleSignInButton(),
                ]
              )
            )
          : Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: <Widget>[
                      Text(
                        'User Details',
                        style: TextStyle(
                          color: bwgDarkpurple,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0
                        )
                      ),
                      Spacer(),
                    ]
                  ),
                  //GoogleUserTile(user),
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
                            onPressed: () async {
                                    // Validate returns true if the form is valid, or false otherwise.
                                if (_formKey.currentState!.validate() && user != null) {
                                      _updateNames();
                                  await viewModel.addUser(
                                        LoggedInUser(
                                          userId: -1,
                                          authId: user!.uid,
                                          userFirstName: firstName,
                                          userLastName: lastName,
                                          userNickName: nickname,
                                      loginType: "Google"
                                        )
                                      );
                                  if (mounted) Navigator.pop(context);
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
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          signOutWithGoogle();
                          viewModel.deleteAllUsers();
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: bwgOrange
                        ),
                        child: Text(
                          "Logout and delete my account",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold
                          )
                          //Theme.of(context).textTheme.titleMedium
                        )
                      )
                    )
                  ],
                ),
              ]
            ),
          )
        )
      ]
    )
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    viewModel.removeListener(_onViewModelChanged);
    super.dispose();
  }
}