import 'package:flutter/material.dart';

// ルームIDを表示するウィジェット
class RoomIdDisplay extends StatelessWidget {
  const RoomIdDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Text(
        'ルームID: 12345',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// ユーザーリストを表示するウィジェット
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