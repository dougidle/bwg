import 'package:flutter/material.dart';
import '../resources/bwg_colors.dart';
import 'package:intl/intl.dart';
import '../model/drawer_viewmodel.dart';
import '../model/logged_in_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
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
  String firstName = '';
  String lastName = '';
  String nickname = '';
  Color iconColor = bwgRed;
  final viewModel = DrawerViewModel('','');
  final formatter = DateFormat('d MMMM yyyy');
  User? user;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Widget googleSignInButton() {
    return SizedBox(
      width: double.infinity,
      height: 44, // Match the height of SignInWithAppleButton
      child: OutlinedButton(
        onPressed: signInWithGoogle,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          side: const BorderSide(color: Colors.grey, width: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // Match SignInWithAppleButton's default radius
          ),
          padding: EdgeInsets.zero, // We'll handle padding inside the Row
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // The Google Logo "G"
            Padding(
              padding: const EdgeInsets.all(1.0), // Creates the border effect
              child: Container(
                height: 30, // Button height minus padding
                width: 30,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(0.0), // Space around the G
                  child: Image.network(
                    'https://pngimg.com/uploads/google/google_PNG19635.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Text(
                'Sign in with Google',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Roboto', // Ensure you have Roboto in pubspec.yaml
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget appleSignInButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: SignInWithAppleButton(
        onPressed: signInWithApple,
        height: 44,
      ),
    );
  }

  String _generateNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  String _sha256ofString(String input) {
    return sha256.convert(utf8.encode(input)).toString();
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
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw Exception('Firebase sign-in failed: User is null');
      }

      final idToken = googleAuth.idToken;
      final idMap = parseJwt(idToken);

      if (idMap != null) {
        final String fName = idMap['given_name'] ?? '';
        final String lName = idMap['family_name'] ?? '';

        _firstNameController.text = fName;
        _lastNameController.text = lName;
        
        String nick = fName.isNotEmpty ? "$fName ${lName.isNotEmpty ? lName[0] : ''}" : '';
        
        // Persist the user info so other widgets (like the Drawer) are updated
        final newUser = LoggedInUser(
          userId: -1,
          authId: firebaseUser.uid,
          userFirstName: fName,
          userLastName: lName,
          userNickName: nick,
          loginType: 'Google',
          isSubscriber: false
        );
        await UserRepository.instance.saveUser(newUser);

      }
      setState(() => user = firebaseUser);
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign-in failed. Please check your internet and Google Play configuration. Error: $e')),
        );
      }
    }
  }

  Future<void> signInWithApple() async {
    try {
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
        accessToken: appleCredential.authorizationCode,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(oauthCredential);
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw Exception('Firebase sign-in failed: User is null');
      }

      // Apple only returns givenName/familyName the first time a user authorizes
      // the app, so fall back to whatever we already have stored for them.
      final existingUser = viewModel.theLoggedInUser;
      final String fName = appleCredential.givenName ?? existingUser?.userFirstName ?? '';
      final String lName = appleCredential.familyName ?? existingUser?.userLastName ?? '';

      _firstNameController.text = fName;
      _lastNameController.text = lName;

      final nick = fName.isNotEmpty ? "$fName ${lName.isNotEmpty ? lName[0] : ''}" : '';

      final newUser = LoggedInUser(
        userId: -1,
        authId: firebaseUser.uid,
        userFirstName: fName,
        userLastName: lName,
        userNickName: nick,
        loginType: 'Apple',
        isSubscriber: false
      );
      await UserRepository.instance.saveUser(newUser);

      setState(() => user = firebaseUser);
    } catch (e) {
      debugPrint('Apple Sign-In Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign-in failed. Error: $e')),
        );
      }
    }
  }

  void signOut() async {
    await _googleSignIn.signOut();
    await FirebaseAuth.instance.signOut();
    setState(() => user = null);
  }

  void makeNickname() {
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
        nickname = '$firstName ${lastName[0]}';
      } else if (firstName.isNotEmpty) {
        nickname = firstName;
      } else {
        nickname = '';
      }
  }

  void _updateNames() {
    setState(() {
      firstName = _capitalise(_firstNameController.text);
      lastName = _capitalise(_lastNameController.text);
      if (_formKey.currentState != null && _formKey.currentState!.validate()) {
        iconColor = bwgGreen;
      } else {
        iconColor = bwgRed;
      }
      makeNickname();
    });
  }

  String _capitalise(String value) {
    if (value.isEmpty) return '';
    return value[0].toUpperCase() + value.substring(1).toLowerCase();
  }

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    
    final loggedInUser = viewModel.theLoggedInUser;

    _firstNameController = TextEditingController(
      text: loggedInUser != null ? loggedInUser.userFirstName : '',
    );

    _lastNameController = TextEditingController(
      text: loggedInUser != null ? loggedInUser.userLastName : '',
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
                        'Login',
                        style: TextStyle(
                          color: bwgDarkpurple,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0
                        )
                      ),
                      Spacer(),
                    ]
                  ),
                  Divider(),
                  if (Platform.isIOS) appleSignInButton(),
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
                  Divider(),
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
                                    hintText: 'Your first name',
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
                                    hintText: 'Your last name',
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
                                      final updatedUser = LoggedInUser(
                                        userId: viewModel.theLoggedInUser?.userId ?? -1,
                                        authId: user!.uid,
                                        userFirstName: firstName,
                                        userLastName: lastName,
                                        userNickName: nickname,
                                        loginType: viewModel.theLoggedInUser?.loginType ?? 'Google',
                                        isSubscriber: false,
                                      );
                                      await viewModel.addUser(updatedUser);
                                      if (mounted) Navigator.pop(context);
                                    }
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: iconColor,
                                  disabledBackgroundColor: bwgRed
                                ),
                                child: Text(
                                  'Save my details',
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
                          signOut();
                          viewModel.deleteAllUsers();
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: bwgOrange
                        ),
                        child: Text(
                          'Logout and delete my account',
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