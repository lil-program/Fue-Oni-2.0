import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fueoni_ver2/components/room/error_handling.dart';
import 'package:fueoni_ver2/components/room/room.dart';
import 'package:fueoni_ver2/screens/room_creation/widgets/room_creation_widgets.dart';
import 'package:fueoni_ver2/services/creation_room_services.dart';

class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({Key? key}) : super(key: key);

  @override
  CreateRoomScreenState createState() => CreateRoomScreenState();
}

class CreateRoomScreenState extends State<CreateRoomScreen> {
  Duration _gameTimeLimit = Duration.zero;
  int _oniCount = 0;
  String _passcode = '';
  int? roomId;
  final _passwordController = TextEditingController();
  final _creationRoomServices = CreationRoomServices();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: RoomWidgets.roomAppbar(
        context: context,
        roomId: roomId,
        backButton: roomCreationBackButton(context: context, roomId: roomId),
        title: "ルーム設定",
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RoomWidgets.displayRoomId(roomId: roomId),
            RoomWidgets.passcodeDialogCard(
                context: context,
                passcode: _passcode,
                onSelected: (selectedPasscode) {
                  setState(() {
                    _passcode = selectedPasscode;
                  });
                }),
            RoomCreationWidgets.timerDialogCard(
                context: context,
                gameTimeLimit: _gameTimeLimit,
                onSelected: (selectedTimeLimit) {
                  setState(() {
                    _gameTimeLimit = selectedTimeLimit;
                  });
                }),
            RoomCreationWidgets.oniDialogCard(
                context: context,
                oniCount: _oniCount,
                onSelected: (selectedOni) {
                  setState(() {
                    _oniCount = selectedOni;
                  });
                }),
            ElevatedButton(
              onPressed: () async {
                try {
                  bool success = await _createRoom();
                  if (success && mounted) {
                    Navigator.pushReplacementNamed(context,
                        '/home/room_settings/create_room/room_creation_waiting',
                        arguments: CreationRoomArguments(roomId: roomId));
                  }
                } catch (e) {
                  if (mounted) {
                    showErrorDialog(context, 'ルームの作成に失敗しました: $e');
                  }
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
    final uniqueRoomId = await _creationRoomServices.generateUniqueRoomId();
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
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.black),
      onPressed: () {
        _creationRoomServices.removeRoomIdFromAllRoomId(roomId);
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
    if (_gameTimeLimit.inSeconds == 0) {
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
        _oniCount,
        _gameTimeLimit.inSeconds,
        digest.toString(),
      );

      await _creationRoomServices.createRoom(
          roomId.toString(), ownerId, settings);

      return true;
    } catch (e) {
      showErrorDialog(context, 'ルームの作成に失敗しました: $e');
      return false;
    }
  }
}
