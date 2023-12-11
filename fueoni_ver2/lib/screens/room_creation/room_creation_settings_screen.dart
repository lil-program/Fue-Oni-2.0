import 'package:flutter/material.dart';
import 'package:fueoni_ver2/components/room/room.dart';
import 'package:fueoni_ver2/screens/room_creation/widgets/oni_dialog.dart';
import 'package:fueoni_ver2/screens/room_creation/widgets/room_creation_widgets.dart';
import 'package:fueoni_ver2/screens/room_creation/widgets/timer_dialog.dart';
import 'package:fueoni_ver2/services/creation_room_services.dart';

class RoomCreationmSettingScreenState
    extends State<RoomCreationSettingsScreen> {
  Duration? selectedDuration;
  int numberOfDemons = 0;
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
            RoomCreationWidgets.settingDialogCard(
              title: 'タイマー設定',
              icon: Icons.timer,
              showDialogCallback: () async {
                final Duration? result =
                    await showTimerDialog(context: context);
                if (result != null) {
                  setState(() {
                    selectedDuration = result;
                  });
                }
              },
              displayWidget:
                  TimerDisplay(duration: selectedDuration ?? Duration.zero),
            ),
            RoomCreationWidgets.settingDialogCard(
              title: '鬼の数',
              icon: Icons.person_outline,
              showDialogCallback: () async {
                final int? result = await showOniDialog(
                    context: context, initialOniCount: numberOfDemons);
                if (result != null) {
                  setState(() {
                    numberOfDemons = result;
                  });
                }
              },
              displayWidget: OniDisplay(oniCount: numberOfDemons),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await updateSettings();
                Navigator.pushReplacementNamed(context,
                    '/home/room_settings/create_room/room_creation_waiting',
                    arguments: CreationRoomArguments(roomId: roomId));
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
        .updateSettings(roomId, selectedDuration, numberOfDemons);
  }
}

class RoomCreationSettingsScreen extends StatefulWidget {
  const RoomCreationSettingsScreen({Key? key}) : super(key: key);

  @override
  RoomCreationmSettingScreenState createState() =>
      RoomCreationmSettingScreenState();
}
