import 'package:flutter/material.dart';
import '../resources/bwg_colors.dart';
import '../model/gamer.dart';
import 'player_admin_tile.dart';

class GamerListTile extends StatelessWidget {
  const GamerListTile({
    required this.isExpanded,
    required this.onToggle,
    required this.gamers,
    super.key,
  });

  final bool isExpanded;
  final VoidCallback onToggle;
  final List<Gamer> gamers;

  @override
  Widget build(BuildContext context) {

    Icon theIcon;
    if (isExpanded) {
      theIcon = Icon(Icons.expand_less);
    } else {
      theIcon = Icon(Icons.expand_more);
    }

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
                          'Subscriber Administration',
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
              if (isExpanded) PlayerAdminList(gamers: gamers),
            ],
          ),
        ),
      )
    );
  }
}