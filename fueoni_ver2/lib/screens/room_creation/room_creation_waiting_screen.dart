import 'package:flutter/material.dart';
import 'package:fueoni_ver2/components/room/error_handling.dart';
import 'package:fueoni_ver2/components/room/room.dart';
import 'package:fueoni_ver2/services/database/creation_room_services.dart';
import 'package:fueoni_ver2/services/database/loading_room_services.dart';
import 'package:fueoni_ver2/services/database/room_services.dart';

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
          RoomWidgets.displayRoomId(context: context, roomId: args.roomId),
          RoomWidgets.displayOwnerName(ownerName),
          RoomWidgets.userList(users),
          ElevatedButton(
            onPressed: () async {
              await handleStartButtonPressed();
            },
            child: const Text('スタート'),
          ),
        ],
      ),
    );
  }

  Future<void> handleStartButtonPressed() async {
    bool hasPermission = await RoomServices.requestLocationPermission();
    if (hasPermission) {
      await RoomServices.updateCurrentLocation(_roomServices, roomId);
      _creationRoomServices.assignOniRandomly(roomId);
      _creationRoomServices.setGameStart(roomId, true);
      _navigateToGameScreen();
    } else {
      if (mounted) {
        showPermissionDeniedDialog(context);
      }
    }
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

  void _navigateToGameScreen() {
    final args =
        ModalRoute.of(context)!.settings.arguments as CreationRoomArguments;

    if (mounted) {
      Navigator.pushReplacementNamed(
          context, '/home/room_settings/loading_room',
          arguments: LoadingRoomArguments(roomId: args.roomId));
    }
  }
}
