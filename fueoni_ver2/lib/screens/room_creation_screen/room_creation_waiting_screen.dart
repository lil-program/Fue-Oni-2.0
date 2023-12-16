import 'package:flutter/material.dart';
import 'package:fueoni_ver2/components/locate_permission_check.dart';
import 'package:fueoni_ver2/components/room/error_handling.dart';
import 'package:fueoni_ver2/components/room/room.dart';
import 'package:fueoni_ver2/models/arguments.dart';
import 'package:fueoni_ver2/services/room_creation/creation_service.dart';
import 'package:fueoni_ver2/services/room_creation/oni_assignment_service.dart';
import 'package:fueoni_ver2/services/room_management/game_service.dart';
import 'package:fueoni_ver2/services/room_management/location_service.dart';
import 'package:fueoni_ver2/services/room_management/room_service.dart';

class RoomCreationWaitingScreen extends StatefulWidget {
  const RoomCreationWaitingScreen({super.key});

  @override
  RoomCreationWaitingScreenState createState() =>
      RoomCreationWaitingScreenState();
}

class RoomCreationWaitingScreenState extends State<RoomCreationWaitingScreen> {
  List<String> users = [];
  String? ownerName;
  int? roomId;

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as CreationRoomArguments;

    return LocationPermissionCheck(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ルーム作成待機'),
          automaticallyImplyLeading: false,
          actions: _buildAppBarActionButton(context, args.roomId),
          leading:
              roomCreationBackButton(context: context, roomId: args.roomId),
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
      ),
    );
  }

  Future<void> handleStartButtonPressed() async {
    bool hasPermission = await LocationService.requestLocationPermission();
    if (hasPermission) {
      await LocationService.updateCurrentLocation(LocationService(), roomId);
      OniAssignmentService().assignOniRandomly(roomId);
      GameService().setGameStart(roomId, true);
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
      ownerName = await RoomService().getRoomOwnerName(roomId);

      RoomService().updatePlayersList(roomId, (updatedUsers) {
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
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.black),
      onPressed: () {
        CreationService().removeRoomIdFromAllRoomId(roomId);
        GameService().removeRoomIdFromGames(roomId);
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
