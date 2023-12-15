import 'package:flutter/material.dart';
import 'package:fueoni_ver2/color_schemes.dart';
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
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    double headerHeight = screenHeight * 0.20;
    double footerHeight = screenHeight * 0.10;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: lightColorScheme.primary,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          //ヘッダー
          buildHeader(headerHeight, screenWidth, context, roomId),
          //フォーム
          Expanded(
            child: buildFormSection(screenWidth),
          ),
          //フッター
          buildFooter(footerHeight, screenWidth, context),
        ],
      ),
    );
  }

  Widget buildFooter(double height, double width, BuildContext context) {
    return Container(
      height: height,
      width: width,
      color: Theme.of(context).colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(
                Icons.arrow_circle_left_outlined,
                color: Colors.white,
                size: 50,
              ),
              onPressed: () {
                _navigateToHomeScreen();
              },
            ),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(4, 4),
                    spreadRadius: -9,
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.check_circle_sharp,
                  color: Colors.white,
                  size: 50,
                ),
                onPressed: () {
                  _navigateToRoomLoadingScreen();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildFormSection(double width) {
    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RoomWidgets.displayRoomId(context: context, roomId: roomId),
                const SizedBox(height: 10),
                RoomWidgets.displayOwnerName(ownerName),
                const SizedBox(height: 10),
                RoomWidgets.userList(users),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildHeader(
      double height, double width, BuildContext context, int? roomId) {
    return Container(
      height: height,
      width: width,
      color: lightColorScheme.primary,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(
            child: Center(
              child: Text(
                'Register Your Room Settings',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: _buildAppBarActionButton(context, roomId),
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
      ownerName = await RoomService().getRoomOwnerName(roomId);

      RoomService().updatePlayersList(roomId, (updatedUsers) {
        setState(() {
          users = updatedUsers;
        });
      });
    });
  }

  Widget _buildAppBarActionButton(BuildContext context, roomId) {
    return MaterialButton(
        onPressed: () {
          _navigateToRoomCreationSettingsScreen();
        },
        child: const Icon(
          Icons.settings,
          color: Colors.white,
          size: 30,
        ));
  }

  void _navigateToHomeScreen() {
    CreationService().removeRoomIdFromAllRoomId(roomId);
    GameService().removeRoomIdFromGames(roomId);
    Navigator.pushReplacementNamed(context, '/home');
  }

  void _navigateToRoomCreationSettingsScreen() {
    Navigator.pushNamed(
        context, '/home/room_settings/create_room/room_creation_settings',
        arguments: CreationRoomArguments(roomId: roomId));
  }

  _navigateToRoomLoadingScreen() async {
    bool hasPermission = await LocationService.requestLocationPermission();
    if (hasPermission) {
      await LocationService.updateCurrentLocation(LocationService(), roomId);
      OniAssignmentService().assignOniRandomly(roomId);
      GameService().setGameStart(roomId, true);
      if (mounted) {
        final args =
            ModalRoute.of(context)!.settings.arguments as CreationRoomArguments;

        Navigator.pushReplacementNamed(
            context, '/home/room_settings/loading_room',
            arguments: LoadingRoomArguments(roomId: args.roomId));
      }
    } else {
      if (mounted) {
        showPermissionDeniedDialog(context);
      }
    }
  }

  /*
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
  */
}
