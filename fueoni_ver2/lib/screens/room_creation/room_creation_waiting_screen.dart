import 'package:flutter/material.dart';
import 'package:fueoni_ver2/components/room_waiting/waiting.dart';

List<Widget> _buildAppBarActionButton(context) {
  return <Widget>[
    MaterialButton(
        onPressed: () {
          Navigator.pushNamed(context,
              '/home/room_settings/create_room/room_creation_settings');
        },
        child: const Icon(
          Icons.settings,
          color: Colors.black,
          size: 30.0,
        ))
  ];
}

class RoomCreationWaitingScreen extends StatelessWidget {
  const RoomCreationWaitingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('ルーム作成待機'),
          actions: _buildAppBarActionButton(context)),
      body: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          RoomIdDisplay(),
          UserList(),
        ],
      ),
    );
  }
}
