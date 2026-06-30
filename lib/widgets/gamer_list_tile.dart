import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../resources/bwg_colors.dart';
import '../model/gamer.dart';
import 'player_admin_tile.dart';

class GamerListTile extends StatefulWidget {
  const GamerListTile({
    required this.isExpanded,
    required this.onToggle,
    required this.gamers,
    required this.onRefresh,
    super.key,
  });

  final bool isExpanded;
  final VoidCallback onToggle;
  final List<Gamer> gamers;
  final VoidCallback onRefresh;

  @override
  State<GamerListTile> createState() => _GamerListTileState();
}

class _GamerListTileState extends State<GamerListTile> {
  bool _isResetting = false;

  Future<void> _resetAllSubscribers() async {
    setState(() => _isResetting = true);

    try {
      final subscribers = widget.gamers.where((g) => g.isSubscriber).toList();
      for (final gamer in subscribers) {
        await http.post(
          Uri.parse('https://musterpointapp.com/api/updateSubscriberStatus.php'),
          body: {
            'UserId': gamer.userId.toString(),
            'isSubscriber': '0',
          },
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isResetting = false);
        widget.onRefresh();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Icon theIcon = widget.isExpanded
        ? const Icon(Icons.expand_less)
        : const Icon(Icons.expand_more);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        color: bwgLilac,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'Subscriber Administration',
                      style: TextStyle(
                        color: bwgDarkpurple,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: widget.onToggle,
                    icon: theIcon,
                  ),
                ],
              ),
              if (widget.isExpanded) ...[
                Card.filled(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                    child: Row(
                      children: [
                        const Text(
                          'Reset all Subscribers',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        if (_isResetting)
                          const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        else
                          TextButton(
                            onPressed: _resetAllSubscribers,
                            style: TextButton.styleFrom(
                              backgroundColor: bwgDarkpurple,
                            ),
                            child: const Text(
                              'Reset',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Divider(),
                PlayerAdminList(gamers: widget.gamers),
              ],
            ],
          ),
        ),
      ),
    );
  }
}