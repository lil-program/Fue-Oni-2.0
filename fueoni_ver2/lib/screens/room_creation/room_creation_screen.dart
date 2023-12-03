import 'package:flutter/material.dart';

import './widgets/oni_dialog.dart';
import './widgets/oni_display.dart';
import './widgets/passcode_dialog.dart';
import './widgets/timer_dialog.dart';
import './widgets/timer_display.dart';

class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({Key? key}) : super(key: key);

  @override
  CreateRoomScreenState createState() => CreateRoomScreenState();
}

class CreateRoomScreenState extends State<CreateRoomScreen> {
  Duration? _selectedDuration;
  int _numberOfDemons = 0;
  String _passcode = '';

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
                'ルームID: 12345', // ルームIDを表示
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.vpn_key),
                title: const Text('パスコード設定'),
                subtitle: Text(_passcode.isNotEmpty
                    ? '設定済み: $_passcode'
                    : 'パスコードを設定してください'),
                trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      showPasscodeDialog(context: context, passcode: _passcode)
                          .then((String? passcode) {
                        if (passcode != null && passcode != '') {
                          setState(() {
                            _passcode = passcode;
                          });
                        }
                      });
                    }),
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
                Navigator.pushNamed(context,
                    '/home/room_settings/create_room/room_creation_waiting');
              },
              child: const Text('設定完了'),
            ),
          ],
        ),
      ),
    );
  }
}
