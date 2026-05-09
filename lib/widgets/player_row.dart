import 'package:flutter/material.dart';

class PlayerRow extends StatelessWidget {
  const PlayerRow({
    required this.player1,
    required this.player2,
    this.isPlayer1Subscriber = false,
    this.isPlayer2Subscriber = false,
    super.key,
  });

  final String player1;
  final String player2;
  final bool isPlayer1Subscriber;
  final bool isPlayer2Subscriber;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (isPlayer1Subscriber) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.verified, color: Colors.blue, size: 16),
                ],
                Text(
                  player1,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0),
            child: Text('vs.'),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isPlayer2Subscriber) ...[
                  const Icon(Icons.verified, color: Colors.blue, size: 16),
                  const SizedBox(width: 4),
                ],
                Text(player2, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}