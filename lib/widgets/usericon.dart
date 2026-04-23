import 'package:bwg/resources/bwg_colors.dart';
import 'package:flutter/material.dart';
import '../repositories/user_repository.dart';

class UserIconButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const UserIconButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final repo = UserRepository.instance;

    return ListenableBuilder(
      listenable: repo,
      builder: (_, _) {
        final user = repo.currentUser;

        return IconButton(
          onPressed: onPressed,
          icon: Icon(
            user != null ? Icons.person : Icons.person_off,
            color: user != null ? bwgGreen : bwgRed,
          ),
        );
      },
    );
  }
}