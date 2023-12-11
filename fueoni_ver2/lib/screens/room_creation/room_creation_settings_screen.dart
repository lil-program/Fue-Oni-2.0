import 'package:flutter/material.dart';
import 'package:fueoni_ver2/components/room_waiting/waiting.dart';
import 'package:fueoni_ver2/screens/room_creation/widgets/oni_dialog.dart';
import 'package:fueoni_ver2/screens/room_creation/widgets/oni_display.dart';
import 'package:fueoni_ver2/screens/room_creation/widgets/timer_dialog.dart';
import 'package:fueoni_ver2/screens/room_creation/widgets/timer_display.dart';
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
            roomIdDisplay(context: context, roomId: args.roomId),
            Card(
              child: ListTile(
                leading: const Icon(Icons.timer),
                title: const Text('タイマー設定'),
                subtitle: selectedDuration != null
                    ? TimerDisplay(duration: selectedDuration!)
                    : const Text('時間を設定してください'),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    showTimerDialog(context: context).then((duration) {
                      if (duration != null) {
                        setState(() {
                          selectedDuration = duration;
                        });
                      }
                    });
                  },
                ),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('鬼の数'),
                subtitle: OniDisplay(oniCount: numberOfDemons),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    int? selectedCount = await showOniDialog(
                      context: context,
                      initialOniCount: numberOfDemons,
                    );
                    if (selectedCount != null) {
                      setState(() {
                        numberOfDemons = selectedCount;
                      });
                    }
                  },
                ),
              ),
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
