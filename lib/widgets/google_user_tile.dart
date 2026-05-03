import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../resources/bwg_colors.dart';

class GoogleUserTile extends StatelessWidget {
  const GoogleUserTile(this.theUser, {super.key});

  final User? theUser;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: CircleAvatar(
                    backgroundImage: NetworkImage(theUser!.photoURL ?? ""),
                    radius: 40,
              )
            ),
          ]
        ),
        Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
              child: Text(
                "${theUser!.displayName}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: bwgDarkpurple,
                ),
              )
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
              child: Text(
                "Logged in via Google",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: bwgDarkpurple,
                ),
              )
            ),
          ]
        )
      ]
    );
  }
}