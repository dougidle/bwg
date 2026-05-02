import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../repositories/user_repository.dart';
import '../model/logged_in_user.dart';
import '../resources/bwg_colors.dart';

class AuthScreen extends StatefulWidget {
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  User? user;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

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

        print("firstName: $firstName");
        print("lastName: $lastName");
        
        // Persist the user info so other widgets (like the Drawer) are updated
        await UserRepository.instance.saveUser(LoggedInUser(
          authId: userCredential.user?.uid ?? "",
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
  
  void signOut() async {
    await _googleSignIn.signOut();
    await FirebaseAuth.instance.signOut();
    setState(() => user = null);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: bwgLilac,
      child: Center(
        child: user == null
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
                  ElevatedButton(
                    onPressed: signInWithGoogle,
                    child: Text("Sign in with Google"),
                  )
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
                  CircleAvatar(
                    backgroundImage: NetworkImage(user!.photoURL ?? ""),
                    radius: 40,
                  ),
                  SizedBox(height: 10),
                  Text("Welcome, ${user!.displayName}"),
                  Text("Id, ${user!.uid}"),
                  Text(user!.email ?? ''),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: signOut,
                    child: Text("Logout"),
                  ),
                ],
              ),
            )
        )
    );
  }
}