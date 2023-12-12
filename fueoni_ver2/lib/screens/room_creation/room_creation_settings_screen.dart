import 'package:flutter/material.dart';
import 'package:fueoni_ver2/components/room/room.dart';
import 'package:fueoni_ver2/screens/room_creation/widgets/room_creation_widgets.dart';
import 'package:fueoni_ver2/services/creation_room_services.dart';

class RoomCreationmSettingScreenState
    extends State<RoomCreationSettingsScreen> {
  Duration gameTimeLimit = Duration.zero;
  int oniCount = 0;
  int? roomId;

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as CreationRoomArguments;
    roomId = args.roomId;

    return Scaffold(
      appBar: AppBar(title: const Text('ルーム設定')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RoomWidgets.displayRoomId(roomId: roomId),
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
    );
  }

  Future<void> updateSettings() async {
    await CreationRoomServices()
        .updateSettings(roomId, gameTimeLimit, oniCount);
  }
}

class RoomCreationSettingsScreen extends StatefulWidget {
  const RoomCreationSettingsScreen({Key? key}) : super(key: key);

  @override
  RoomCreationmSettingScreenState createState() =>
      RoomCreationmSettingScreenState();
}
