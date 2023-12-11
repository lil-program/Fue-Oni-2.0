import 'package:flutter/material.dart';
import 'package:fueoni_ver2/components/room/room.dart';
import 'package:fueoni_ver2/components/room_waiting/waiting.dart';
import 'package:fueoni_ver2/services/creation_room_services.dart';

List<Widget> _buildAppBarActionButton(BuildContext context, roomId) {
  return <Widget>[
    MaterialButton(
        onPressed: () {
          Navigator.pushNamed(
              context, '/home/room_settings/create_room/room_creation_settings',
              arguments: CreationRoomArguments(roomId: roomId));
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
    final args =
        ModalRoute.of(context)!.settings.arguments as CreationRoomArguments;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ルーム作成待機'),
        automaticallyImplyLeading: false,
        actions: _buildAppBarActionButton(context, args.roomId),
        leading: roomCreationBackButton(context: context, roomId: args.roomId),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          RoomWidgets.displayRoomId(roomId: args.roomId),
          const UserList(),
        ],
      ),
    );
  }

  Widget roomCreationBackButton({
    required BuildContext context,
    required int? roomId,
  }) {
    final roomIdGenerator = CreationRoomServices();
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.black),
      onPressed: () {
        roomIdGenerator.removeRoomIdFromAllRoomId(roomId);
        roomIdGenerator.removeRoomIdFromGames(roomId);
        Navigator.pushReplacementNamed(context, '/home/room_settings');
      },
    );
  }
}
