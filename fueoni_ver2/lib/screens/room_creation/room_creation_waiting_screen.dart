import 'package:flutter/material.dart';
import 'package:fueoni_ver2/components/room/room.dart';
import 'package:fueoni_ver2/services/creation_room_services.dart';
import 'package:fueoni_ver2/services/room_services.dart';

class RoomCreationWaitingScreen extends StatefulWidget {
  const RoomCreationWaitingScreen({super.key});

  @override
  RoomCreationWaitingScreenState createState() =>
      RoomCreationWaitingScreenState();
}

class RoomCreationWaitingScreenState extends State<RoomCreationWaitingScreen> {
  final RoomServices _roomServices = RoomServices();
  final CreationRoomServices _creationRoomServices = CreationRoomServices();
  List<String> users = [];
  String? ownerName;
  int? roomId;

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
          RoomWidgets.userList(users),
          ElevatedButton(
            onPressed: () async {
              _roomServices.registerPlayer(roomId);
              _creationRoomServices.assignOniRandomly(roomId);
              _creationRoomServices.setGameStart(roomId, true);
              await RoomServices.updateCurrentLocation(_roomServices, roomId);

              //ここにゲーム画面への遷移を書く
              Navigator.pushReplacementNamed(context, '/home/room_settings');
            },
            child: const Text('スタート'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final args =
          ModalRoute.of(context)!.settings.arguments as CreationRoomArguments;
      roomId = args.roomId;
      ownerName = await _roomServices.getRoomOwnerName(roomId);

      _roomServices.updatePlayersList(roomId, (updatedUsers) {
        setState(() {
          users = updatedUsers;
          users.insert(0, ownerName ?? "RoomOwner");
        });
      });
    });
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

  List<Widget> _buildAppBarActionButton(BuildContext context, roomId) {
    return <Widget>[
      MaterialButton(
          onPressed: () {
            Navigator.pushNamed(context,
                '/home/room_settings/create_room/room_creation_settings',
                arguments: CreationRoomArguments(roomId: roomId));
          },
          child: const Icon(
            Icons.settings,
            color: Colors.black,
            size: 30.0,
          ))
    ];
  }
}
