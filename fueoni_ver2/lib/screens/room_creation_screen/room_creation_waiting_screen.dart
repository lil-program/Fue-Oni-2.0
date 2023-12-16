import 'package:flutter/material.dart';
import 'package:fueoni_ver2/color_schemes.dart';
import 'package:fueoni_ver2/components/room/error_handling.dart';
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
      backgroundColor: lightColorScheme.background,
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

  Widget buildDisplayTile(String title, String value) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value,
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget buildFooter(double height, double width, BuildContext context) {
    return Container(
      height: height,
      width: width,
      color: Theme.of(context).colorScheme.background,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(
                Icons.logout_outlined,
                color: Color.fromARGB(255, 103, 80, 164),
                size: 55,
              ),
              onPressed: () {
                _navigateToHomeScreen();
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.check_circle_sharp,
                color: Color.fromARGB(255, 103, 80, 164),
                size: 55,
              ),
              onPressed: () {
                _navigateToRoomLoadingScreen();
              },
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
          color: Colors.grey[50],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
            side: BorderSide(
              color: Colors.grey[300] ?? Colors.grey,
              width: 1,
            ),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: buildListTiles(),
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
      color: lightColorScheme.background,
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
                  color: Color.fromARGB(255, 103, 80, 164),
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

  List<Widget> buildListTiles() {
    List<Widget> listTiles = [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: buildRoomIDDisplay(
                "Room ID", "${roomId ?? "Generating Room ID"}"),
          ),
          Expanded(
            child: buildOwnerNameDisplay("Owner", ownerName ?? "不明"),
          ),
        ],
      ),
      const Divider(),
    ];

    for (String user in users) {
      listTiles.add(
        buildUsersTile(Icons.person_outline, user),
      );
      listTiles.add(const Divider());
    }

    return listTiles;
  }

  Widget buildOwnerNameDisplay(String title, String value) {
    return buildDisplayTile(title, value);
  }

  Widget buildRoomIDDisplay(String title, String value) {
    return buildDisplayTile(title, value);
  }

  ListTile buildUsersTile(
    IconData leadingIcon,
    String title,
  ) {
    return ListTile(
      leading: Icon(leadingIcon),
      title: Text(title),
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
          Icons.settings_outlined,
          color: Colors.black,
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

  static Widget userList(List<String> users) {
    return Expanded(
      child: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          return Card(
            color: Colors.grey[50],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            elevation: 3, // Adds shadow
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
