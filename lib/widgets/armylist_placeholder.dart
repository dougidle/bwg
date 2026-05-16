
import 'package:flutter/material.dart';
import '../resources/bwg_colors.dart';

class ArmyListPlaceholderTile extends StatelessWidget {
  const ArmyListPlaceholderTile({
    required this.isExpanded,
    required this.onToggle,
    super.key,
  });

  
  final bool isExpanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {

    Icon theIcon;
    if (isExpanded) {
      theIcon = Icon(Icons.expand_less);
    } else {
      theIcon = Icon(Icons.expand_more);
    }

    List<Widget> bookingsList = [];

    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Card(
        color: bwgLilac,
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Coming soon....?',
                          style: TextStyle(
                            color: bwgDarkpurple,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onToggle, 
                    icon: theIcon
                  ),
                ],
              ),
              if (isExpanded) ...bookingsList,
            ],
          ),
        ),
      )
    );
  }
}