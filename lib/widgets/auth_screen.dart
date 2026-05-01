import 'package:flutter/material.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthScreen extends StatefulWidget {
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}
class _AuthScreenState extends State<AuthScreen> {
  User? user;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

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
    return Center(
        child: user == null
            ? ElevatedButton(
                onPressed: signInWithGoogle,
                child: Text("Sign in with Google"),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(user!.photoURL ?? ""),
                    radius: 40,
                  ),
                  SizedBox(height: 10),
                  Text("Welcome, ${user!.displayName}"),
                  Text(user!.email ?? ''),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: signOut,
                    child: Text("Logout"),
                  ),
                ],
              ),
      );
  }
}