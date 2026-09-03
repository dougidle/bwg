import 'package:bwg/model/game_booking.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'bwg_widgets.dart';
import '../resources/bwg_colors.dart';
import '../model/gamer.dart';

class DayBookingTile extends StatelessWidget {
  const DayBookingTile(
    this.theDate,
    this.theBookings,
    this.theGamers, {
    required this.isExpanded,
    required this.onToggle,
    required this.currentUserId,
    required this.isAdmin,
    required this.onDeleteBooking,
    super.key,
  });

  final DateTime theDate;
  final List<GameBooking> theBookings;
  final List<Gamer> theGamers;
  final bool isExpanded;
  final VoidCallback onToggle;
  final int currentUserId;
  final bool isAdmin;
  final ValueChanged<GameBooking> onDeleteBooking;

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('d MMMM yyyy');
    String theFormattedDate = formatter.format(theDate);
    String theTableText = '';
    Color theTableColor = bwgDarkpurple;
    const maxTables = 28;

    Icon theIcon;
    if (isExpanded) {
      theIcon = Icon(Icons.expand_less);
    } else {
      theIcon = Icon(Icons.expand_more);
    }

    List<Widget> bookingsList = [];
    int tablesUsed = 0;

    for (var i = 0; i < theBookings.length; i++) {
      final booking = theBookings[i];
      tablesUsed += booking.requiredTables;

      final p1Gamer = theGamers.cast<Gamer?>().firstWhere(
            (g) => g?.userId == booking.player1,
            orElse: () => null,
          );

      String p2Name = 'No Opponent';
      bool p2Sub = false;
      if (booking.player2 == -1) {
        p2Name = booking.player2Name;
      } else if (booking.player2 > 0) {
        final p2Gamer = theGamers.cast<Gamer?>().firstWhere(
              (g) => g?.userId == booking.player2,
              orElse: () => null,
            );
        p2Name = p2Gamer?.nickName ?? 'Unknown';
        p2Sub = p2Gamer?.isSubscriber ?? false;
      }

      // Either player in the booking, or an admin, can cancel it. The delete
      // endpoint is keyed by the booking's player1 id + date, so we always
      // send booking.player1 regardless of who is cancelling.
      final bool canDelete = isAdmin ||
          booking.player1 == currentUserId ||
          booking.player2 == currentUserId;

      bookingsList.add(
        BookingTile(
          p1Gamer?.nickName ?? 'Unknown',
          p2Name,
          booking.gameSystem,
          booking.isOrganised,
          isPlayer1Subscriber: p1Gamer?.isSubscriber ?? false,
          isPlayer2Subscriber: p2Sub,
          onDelete: canDelete ? () => onDeleteBooking(booking) : null,
          key: ValueKey('${booking.player1}-${booking.player2}-$i'),
        )
      );
    }

    switch (tablesUsed) {
      case <=20:
        theTableText = '${maxTables - tablesUsed} tables available';
        theTableColor = bwgGreen;
        break;
      case > 20 && <= maxTables:
        theTableText = '${maxTables - tablesUsed} tables available';
        theTableColor = bwgOrange;
        break;
      default:
        theTableText = 'This club night is oversubscribed';
        theTableColor = bwgRed;
        break;
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
                          '$theFormattedDate - ${bookingsList.length} bookings',
                          style: TextStyle(
                            color: bwgDarkpurple,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                          decoration: BoxDecoration(
                            color: theTableColor,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Text(
                            theTableText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.normal,
                              fontSize: 12.0,
                            ),
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
              if (isExpanded) ...[
                const Divider(),
                ...bookingsList,
              ],
            ],
          ),
        ),
      )
    );
  }
}