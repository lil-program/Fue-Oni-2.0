import 'package:flutter/material.dart';

class UserList extends StatelessWidget {
  static const List<String> users = ['ユーザー1', 'ユーザー2', 'ユーザー3'];

  const UserList({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              title: Text(users[index]),
              leading: const Icon(Icons.person),
            ),
          );
        },
      ),
    );
  }
}
