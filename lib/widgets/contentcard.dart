import 'package:flutter/material.dart';
import '../resources/bwg_colors.dart';

class ContentCard extends StatelessWidget {
  const ContentCard(this.theMessage, {super.key});

  final String theMessage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Card(
        color: bwgLilac,
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      theMessage,
                      style: TextStyle(
                        color: bwgDarkpurple,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                ]
              ) ,
            ),
          ]
        )
      )
    );
  }
}