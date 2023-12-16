import 'package:flutter/material.dart';
import 'package:fueoni_ver2/color_schemes.dart';
import 'package:fueoni_ver2/components/locate_permission_check.dart';
import 'package:fueoni_ver2/components/room/room.dart';
import 'package:fueoni_ver2/models/arguments.dart';
import 'package:fueoni_ver2/screens/room_creation_screen/widgets/oni_dialog.dart';
import 'package:fueoni_ver2/screens/room_creation_screen/widgets/timer_dialog.dart';
import 'package:fueoni_ver2/services/room_creation/oni_assignment_service.dart';
import 'package:fueoni_ver2/services/room_management/game_service.dart';

class RoomCreationmSettingScreenState
    extends State<RoomCreationSettingsScreen> {
  Duration _gameTimeLimit = Duration.zero;
  int _oniCount = 0;
  int? roomId;

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    double headerHeight = screenHeight * 0.20;
    double footerHeight = screenHeight * 0.10;

    return LocationPermissionCheck(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: lightColorScheme.background,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            //ヘッダー
            buildHeader(headerHeight, screenWidth),
            //フォーム
            Expanded(
              child: buildFormSection(screenWidth),
            ),
            //フッター
            buildFooter(footerHeight, screenWidth, context),
          ],
        ),
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
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: const Icon(
                Icons.arrow_circle_right,
                color: Color.fromARGB(255, 103, 80, 164),
                size: 55,
              ),
              onPressed: () {
                _navigateToRoomCreationWaitingScreen();
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

  Widget buildHeader(double height, double width) {
    return Container(
      height: height,
      width: width,
      color: lightColorScheme.background,
      child: const Center(
        child: Text(
          'Change Your Room Settings',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 103, 80, 164),
          ),
        ),
      ),
    );
  }

  List<Widget> buildListTiles() {
    return [
      buildRoomIDDisplay("Room ID", "${roomId ?? "Generating Room ID"}"),
      const Divider(),
      buildSettingTile(
          Icons.timer, "Time Limit", _formatDuration(_gameTimeLimit).join(),
          () async {
        Duration? result = await showTimerDialog(context: context);
        setState(() {
          if (result != null) {
            _gameTimeLimit = result;
          }
        });
      }),
      buildSettingTile(
          CustomIcons.oni, "Oni Setting", _formatOniCount(_oniCount), () async {
        int? result = await showOniDialog(context: context);
        setState(() {
          if (result != null) {
            _oniCount = result;
          }
        });
      }),
    ];
  }

  Widget buildRoomIDDisplay(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value,
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget buildSettingTile(
      IconData icon, String title, String value, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(value),
      trailing: IconButton(
        icon: const Icon(Icons.edit),
        onPressed: onTap,
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final args = ModalRoute.of(context)!.settings.arguments as RoomArguments;
      roomId = args.roomId;

      final gameTimeLimit = await OniAssignmentService().getTimeLimit(roomId);
      final oniCount = await OniAssignmentService().getInitialOniCount(roomId);

      setState(() {
        _gameTimeLimit = gameTimeLimit;
        _oniCount = oniCount;
      });
    });
  }

  Future<void> updateSettings() async {
    await GameService().updateSettings(roomId, _gameTimeLimit, _oniCount);
  }

  List<String> _formatDuration(Duration duration) {
    if (duration == Duration.zero) {
      return ["Set Time"];
    }

    String hours = duration.inHours > 0 ? "${duration.inHours} hours " : "";
    String minutes =
        (duration.inMinutes % 60) > 0 ? "${duration.inMinutes % 60} mins " : "";
    String seconds =
        (duration.inSeconds % 60) > 0 ? "${duration.inSeconds % 60} secs" : "";

    return [hours, minutes, seconds]
        .where((element) => element.isNotEmpty)
        .toList();
  }

  String _formatOniCount(int oniCount) {
    if (oniCount == 0) {
      return "Set Oni Number";
    }

    return "$oniCount";
  }

  void _navigateToRoomCreationWaitingScreen() async {
    await updateSettings();

    if (mounted) {
      Navigator.pushReplacementNamed(
          context, '/home/room_settings/create_room/room_creation_waiting',
          arguments: RoomArguments(roomId: roomId));
    }
  }
}

class RoomCreationSettingsScreen extends StatefulWidget {
  const RoomCreationSettingsScreen({Key? key}) : super(key: key);

  @override
  RoomCreationmSettingScreenState createState() =>
      RoomCreationmSettingScreenState();
}
