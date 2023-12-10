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
import 'package:fueoni_ver2/services/creation_room_services.dart';
import 'package:fueoni_ver2/services/database/room.dart';
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
  int? roomId;
  final _passwordController = TextEditingController();
  final _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ルーム設定'),
        automaticallyImplyLeading: false,
        leading: roomCreationBackButton(context: context, roomId: roomId),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'ルームID: ${roomId ?? '生成中...'}',
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
              onPressed: () async {
                // 非同期操作を含むため async を追加
                try {
                  bool success = await _createRoom();
                  if (success) {
                    // ルーム作成が成功した場合、別の画面に遷移
                    Navigator.pushReplacementNamed(context,
                        '/home/room_settings/create_room/room_creation_waiting',
                        arguments: CreationRoomArguments(roomId: roomId));
                  }
                } catch (e) {
                  // エラー発生時はダイアログを表示
                  showErrorDialog(context, 'ルームの作成に失敗しました: $e');
                }
              },
              child: const Text('ルーム作成'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> generateRoomId() async {
    final roomIdGenerator = CreationRoomServices();
    final uniqueRoomId = await roomIdGenerator.generateUniqueRoomId();
    setState(() {
      roomId = uniqueRoomId;
    });
  }

  @override
  void initState() {
    super.initState();
    generateRoomId();
  }

  Widget roomCreationBackButton({
    required BuildContext context,
    required int? roomId,
  }) {
    final roomIdGenerator = CreationRoomServices();
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.black),
      onPressed: () {
        roomIdGenerator.removeRoomIdFromAllRoomId(roomId);
        Navigator.pushReplacementNamed(context, '/home/room_settings');
      },
    );
  }

  Future<bool> _createRoom() async {
    if (roomId == null) {
      showErrorDialog(context, 'ルームIDが生成されていません。');
      return false;
    }
    if (_passcode.isEmpty || _passcode == '') {
      showErrorDialog(context, 'パスコードが設定されていません。');
      return false;
    }
    if (_selectedDuration == null || _selectedDuration!.inSeconds == 0) {
      showErrorDialog(context, 'タイマーが設定されていません。');
      return false;
    }

    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        showErrorDialog(context, 'ユーザーがログインしていません。');
        return false;
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

      await _firebaseService.createRoom(roomId.toString(), ownerId, settings);

      return true;
    } catch (e) {
      showErrorDialog(context, 'ルームの作成に失敗しました: $e');
      return false;
    }
  }
}
