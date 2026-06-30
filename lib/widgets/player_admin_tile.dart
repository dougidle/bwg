import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../model/gamer.dart';

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
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _isSubscriber = widget.gamer.isSubscriber;
  }

  @override
  void didUpdateWidget(PlayerAdminTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.gamer.isSubscriber != widget.gamer.isSubscriber) {
      _isSubscriber = widget.gamer.isSubscriber;
    }
  }

  Future<void> _updateSubscriberStatus(bool value) async {
    setState(() {
      _isSubscriber = value;
      _isSaving = true;
    });

    try {
      final response = await http.post(
        Uri.parse('https://musterpointapp.com/api/updateSubscriberStatus.php'),
        body: {
          'UserId': widget.gamer.userId.toString(),
          'isSubscriber': value ? '1' : '0',
        },
      );

      if (response.statusCode == 200) {
        widget.gamer.isSubscriber = value;
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      // Revert on failure
      setState(() => _isSubscriber = !value);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update ${widget.gamer.nickName}: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
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
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            if (_isSaving)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Switch(
                value: _isSubscriber,
                onChanged: _updateSubscriberStatus,
              ),
          ],
        ),
      ),
    );
  }
}