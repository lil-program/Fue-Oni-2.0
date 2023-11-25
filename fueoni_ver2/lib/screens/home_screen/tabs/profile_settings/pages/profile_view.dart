import 'package:flutter/material.dart';

class ProfileView extends StatelessWidget {
  final String name;

  final IconData icon;
  const ProfileView({
    Key? key,
    required this.name,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: ElevatedButton.icon(
        icon: Icon(icon, color: Theme.of(context).colorScheme.onSecondary),
        label: Text(
          name,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        onPressed: () {
          // ここに名前の変更ロジックを書く
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.red, // テキストの色を変更
        ),
      ),
    );
  }
}
