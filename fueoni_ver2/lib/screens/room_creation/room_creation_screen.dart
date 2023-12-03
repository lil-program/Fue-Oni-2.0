import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fueoni_ver2/screens/room_creation/widgets/build_setting_card.dart';
import 'package:fueoni_ver2/screens/room_creation/widgets/oni_dialog.dart';
import 'package:fueoni_ver2/screens/room_creation/widgets/oni_display.dart';
import 'package:fueoni_ver2/screens/room_creation/widgets/passcode_dialog.dart';
import 'package:fueoni_ver2/screens/room_creation/widgets/passcode_display.dart';
import 'package:fueoni_ver2/screens/room_creation/widgets/timer_dialog.dart';
import 'package:fueoni_ver2/screens/room_creation/widgets/timer_display.dart';
import 'package:fueoni_ver2/services/database/room.dart';
import 'package:fueoni_ver2/services/database/roomid_generator.dart';
import 'package:fueoni_ver2/utils/error_handling.dart';

class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({Key? key}) : super(key: key);

  @override
  CreateRoomScreenState createState() => CreateRoomScreenState();
}

class CreateRoomScreenState extends State<CreateRoomScreen> {
  Duration? _selectedDuration;
  int _numberOfDemons = 0;
  String _passcode = '';
  int? _roomId;
  final _passwordController = TextEditingController();
  final _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ルーム設定')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'ルームID: ${_roomId ?? '生成中...'}',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            buildSettingCard(
              title: 'パスコード設定',
              icon: Icons.vpn_key,
              showDialogCallback: () async {
                final String? result = await showPasscodeDialog(
                    context: context, passcode: _passcode);
                if (result != null && result.isNotEmpty) {
                  setState(() {
                    _passcode = result;
                  });
                }
              },
              displayWidget: PasscodeDisplay(passcode: _passcode),
            ),
            buildSettingCard(
              title: 'タイマー設定',
              icon: Icons.timer,
              showDialogCallback: () async {
                final Duration? result =
                    await showTimerDialog(context: context);
                if (result != null) {
                  setState(() {
                    _selectedDuration = result;
                  });
                }
              },
              displayWidget:
                  TimerDisplay(duration: _selectedDuration ?? Duration.zero),
            ),
            buildSettingCard(
              title: '鬼の数',
              icon: Icons.person_outline,
              showDialogCallback: () async {
                final int? result = await showOniDialog(
                    context: context, initialOniCount: _numberOfDemons);
                if (result != null) {
                  setState(() {
                    _numberOfDemons = result;
                  });
                }
              },
              displayWidget: OniDisplay(oniCount: _numberOfDemons),
            ),
            ElevatedButton(
              onPressed: _createRoom,
              child: const Text('ルーム作成'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> generateRoomId() async {
    final roomIdGenerator = RoomIdGenerator();
    final uniqueRoomId = await roomIdGenerator.generateUniqueRoomId();
    setState(() {
      _roomId = uniqueRoomId;
    });
  }

  @override
  void initState() {
    super.initState();
    generateRoomId();
  }

  Future<void> _createRoom() async {
    if (_roomId == null) {
      showErrorDialog(context, 'ルームIDが生成されていません。');
      return;
    }
    if (_passcode.isEmpty || _passcode == '') {
      showErrorDialog(context, 'パスコードが設定されていません。');
      return;
    }
    if (_selectedDuration == null || _selectedDuration!.inSeconds == 0) {
      showErrorDialog(context, 'タイマーが設定されていません。');
      return;
    }

    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        showErrorDialog(context, 'ユーザーがログインしていません。');
        return;
      }
      String ownerId = currentUser.uid;

      var bytes = utf8.encode(_passwordController.text);
      var digest = sha256.convert(bytes);

      final settings = RoomSettings(
        1,
        _numberOfDemons,
        _selectedDuration!.inSeconds,
        digest.toString(),
      );

      await _firebaseService.createRoom(_roomId.toString(), ownerId, settings);

      Navigator.pushNamed(
          context, '/home/room_settings/create_room/room_creation_waiting');
    } catch (e) {
      showErrorDialog(context, 'ルームの作成に失敗しました: $e');
    }
  }
}
