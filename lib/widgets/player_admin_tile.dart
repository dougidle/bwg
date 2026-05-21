import 'package:flutter/material.dart';
import '../model/gamer.dart';
import '../resources/bwg_colors.dart';

class PlayerAdminList extends StatelessWidget {
  final List<Gamer> gamers;

  const PlayerAdminList({super.key, required this.gamers});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: gamers
          .map((gamer) => PlayerAdminTile(key: ValueKey(gamer.userId), gamer: gamer))
          .toList(),
    );
  }
}

class PlayerAdminTile extends StatefulWidget {
  final Gamer gamer;

  const PlayerAdminTile({super.key, required this.gamer});

  @override
  State<PlayerAdminTile> createState() => _PlayerAdminTileState();
}

class _PlayerAdminTileState extends State<PlayerAdminTile> {
  late bool _isSubscriber;

  @override
  void initState() {
    super.initState();
    // Initialize the local state from the passed gamer object
    _isSubscriber = widget.gamer.isSubscriber;
  }

  @override
  void didUpdateWidget(PlayerAdminTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.gamer.isSubscriber != widget.gamer.isSubscriber) {
      _isSubscriber = widget.gamer.isSubscriber;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card.filled(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
        child: Row(
          children: <Widget>[
            Text(
              widget.gamer.nickName,
              style: const TextStyle(
                fontWeight: FontWeight.bold
              ),
            ),
            const Spacer(),
            Switch(
              value: _isSubscriber,
              onChanged: (bool value) {
                setState(() {
                  _isSubscriber = value;
                  widget.gamer.isSubscriber = value;
                });
                // TODO: Add logic here to persist the change (e.g., API call or DB update)
              },
            ),
          ],
        ),
      ),
    );
  }
}