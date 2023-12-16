import 'package:flutter/material.dart';
import 'package:fueoni_ver2/components/locate_permission_check.dart';
import 'package:fueoni_ver2/components/room/room.dart';
import 'package:fueoni_ver2/models/arguments.dart';
import 'package:fueoni_ver2/screens/room_creation_screen/widgets/room_creation_widgets.dart';
import 'package:fueoni_ver2/services/room_creation/oni_assignment_service.dart';
import 'package:fueoni_ver2/services/room_management/game_service.dart';

class RoomCreationmSettingScreenState
    extends State<RoomCreationSettingsScreen> {
  Duration gameTimeLimit = Duration.zero;
  int oniCount = 0;
  int? roomId;

  @override
  Widget build(BuildContext context) {
    return LocationPermissionCheck(
      child: Scaffold(
        appBar: AppBar(title: const Text('ルーム設定')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RoomWidgets.displayRoomId(context: context, roomId: roomId),
              RoomCreationWidgets.timerDialogCard(
                  context: context,
                  gameTimeLimit: gameTimeLimit,
                  onSelected: (selectedTimeLimit) {
                    setState(() {
                      gameTimeLimit = selectedTimeLimit;
                    });
                  }),
              RoomCreationWidgets.oniDialogCard(
                  context: context,
                  oniCount: oniCount,
                  onSelected: (selectedOni) {
                    setState(() {
                      oniCount = selectedOni;
                    });
                  }),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await updateSettings();

                  if (mounted) {
                    Navigator.pushReplacementNamed(context,
                        '/home/room_settings/create_room/room_creation_waiting',
                        arguments: CreationRoomArguments(roomId: roomId));
                  }
                },
                child: const Text('設定完了'),
              ),
            ],
          ),
        ),
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

      final gameTimeLimit = await OniAssignmentService().getTimeLimit(roomId);
      final oniCount = await OniAssignmentService().getInitialOniCount(roomId);

      setState(() {
        this.gameTimeLimit = gameTimeLimit;
        this.oniCount = oniCount;
      });
    });
  }

  Future<void> updateSettings() async {
    await GameService().updateSettings(roomId, gameTimeLimit, oniCount);
  }
}

class RoomCreationSettingsScreen extends StatefulWidget {
  const RoomCreationSettingsScreen({Key? key}) : super(key: key);

  @override
  RoomCreationmSettingScreenState createState() =>
      RoomCreationmSettingScreenState();
}
