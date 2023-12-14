import 'package:flutter/material.dart';
import 'package:fueoni_ver2/components/room/error_handling.dart';
import 'package:fueoni_ver2/components/room/room.dart';
import 'package:fueoni_ver2/models/arguments.dart';
import 'package:fueoni_ver2/services/room_management/location_service.dart';
import 'package:fueoni_ver2/services/room_management/room_service.dart';
import 'package:fueoni_ver2/services/room_search/game_monitor_service.dart';

class RoomSearchWaitingScreen extends StatefulWidget {
  const RoomSearchWaitingScreen({super.key});

  @override
  RoomSearchWaitingScreenState createState() => RoomSearchWaitingScreenState();
}

class RoomSearchWaitingScreenState extends State<RoomSearchWaitingScreen> {
  List<String> users = [];
  String? ownerName;

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as SearchRoomArguments;

    return Scaffold(
      appBar: RoomWidgets.roomAppbar(
        context: context,
        roomId: args.roomId,
        title: "ルーム待機",
        onBackButtonPressed: (int? roomId) {
          RoomService().removePlayerId(roomId);
          Navigator.pushReplacementNamed(context, '/home');
        },
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          RoomWidgets.displayRoomId(context: context, roomId: args.roomId),
          RoomWidgets.userList(users),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final args =
          ModalRoute.of(context)!.settings.arguments as SearchRoomArguments;
      final roomId = args.roomId;
      ownerName = await RoomService().getRoomOwnerName(roomId);

      RoomService().updatePlayersList(roomId, (updatedUsers) {
        setState(() {
          users = updatedUsers;
          users.insert(0, ownerName ?? "RoomOwner");
        });
      });

      GameMonitorService().monitorGameStart(roomId, (gameStarted) async {
        if (gameStarted) {
          bool hasPermission =
              await LocationService.requestLocationPermission();
          if (hasPermission) {
            await LocationService.updateCurrentLocation(
                LocationService(), roomId);
            _navigateToGameScreen();
          } else {
            if (mounted) {
              showPermissionDeniedDialog(context);
            }
          }
        }
      });
    });
  }

  void _navigateToGameScreen() {
    int? roomId;
    final args =
        ModalRoute.of(context)!.settings.arguments as SearchRoomArguments;
    roomId = args.roomId;

    if (mounted) {
      Navigator.pushReplacementNamed(
          context, '/home/room_settings/loading_room',
          arguments: LoadingRoomArguments(roomId: roomId));
    }
  }
}
