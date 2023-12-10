import 'package:flutter/material.dart';
import 'package:fueoni_ver2/screens/room_creation/widgets/oni_dialog.dart';
import 'package:fueoni_ver2/screens/room_creation/widgets/oni_display.dart';
import 'package:fueoni_ver2/screens/room_creation/widgets/timer_dialog.dart';
import 'package:fueoni_ver2/screens/room_creation/widgets/timer_display.dart';
import 'package:fueoni_ver2/services/creation_room_services.dart';

class RoomCreationmSettingScreenState
    extends State<RoomCreationSettingsScreen> {
  Duration? _selectedDuration;
  int _numberOfDemons = 0;
  int? roomId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ルーム設定')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'ルームID: ', // ルームIDを表示
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.timer),
                title: const Text('タイマー設定'),
                subtitle: _selectedDuration != null
                    ? TimerDisplay(duration: _selectedDuration!)
                    : const Text('時間を設定してください'),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    showTimerDialog(context: context).then((duration) {
                      if (duration != null) {
                        setState(() {
                          _selectedDuration = duration;
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
                subtitle: OniDisplay(oniCount: _numberOfDemons),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    int? selectedCount = await showOniDialog(
                      context: context,
                      initialOniCount: _numberOfDemons,
                    );
                    if (selectedCount != null) {
                      setState(() {
                        _numberOfDemons = selectedCount;
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
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
}

class RoomCreationSettingsScreen extends StatefulWidget {
  const RoomCreationSettingsScreen({Key? key}) : super(key: key);

  @override
  RoomCreationmSettingScreenState createState() =>
      RoomCreationmSettingScreenState();
}
