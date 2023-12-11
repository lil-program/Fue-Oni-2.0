import 'package:flutter/material.dart';
import 'package:fueoni_ver2/components/room_waiting/waiting.dart';
import 'package:fueoni_ver2/services/search_room_services.dart';

class RoomSearchWaitingScreen extends StatelessWidget {
  const RoomSearchWaitingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as SearchRoomArguments;

    return Scaffold(
      appBar: AppBar(title: const Text('ルーム検索待機')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          roomIdDisplay(context: context, roomId: args.roomId),
          const UserList(),
        ],
      ),
    );
  }
}
