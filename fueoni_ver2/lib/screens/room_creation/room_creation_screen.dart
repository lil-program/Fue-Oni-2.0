import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fueoni_ver2/color_schemes.dart';
import 'package:fueoni_ver2/components/room/error_handling.dart';
import 'package:fueoni_ver2/components/room/passcode_dialog.dart';
import 'package:fueoni_ver2/components/room/room.dart';
import 'package:fueoni_ver2/screens/room_creation/widgets/room_creation_widgets.dart';
import 'package:fueoni_ver2/services/creation_room_services.dart';
import 'package:fueoni_ver2/services/room_services.dart';

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
  final _creationRoomServices = CreationRoomServices();
  final _roomServices = RoomServices();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: RoomWidgets.roomAppbar(
        context: context,
        roomId: roomId,
        title: "ルーム設定",
        onBackButtonPressed: (int? roomId) {
          _creationRoomServices.removeRoomIdFromAllRoomId(roomId);
          Navigator.pushReplacementNamed(context, '/home');
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            bool success = await _createRoom();
            _roomServices.registerPlayer(roomId);
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
        backgroundColor: lightColorScheme.primary,
        child: Icon(Icons.check, color: lightColorScheme.onPrimary),
      ),
      body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    RoomWidgets.displayRoomId(context: context, roomId: roomId),
                    Column(
                      children: <Widget>[
                        RoomWidgets.passcodeDialogCard(
                          context: context,
                          passcode: _passcode,
                          displayWidgetFactory: (passcode) =>
                              passcodeSettingDisplay(
                            context: context,
                            passcode: passcode,
                            hintText: 'パスコードなし',
                          ),
                          onSelected: (selectedPasscode) {
                            setState(() {
                              _passcode = selectedPasscode;
                            });
                          },
                        ),
                        RoomCreationWidgets.timerDialogCard(
                          context: context,
                          gameTimeLimit: _gameTimeLimit,
                          onSelected: (selectedTimeLimit) {
                            setState(() {
                              _gameTimeLimit = selectedTimeLimit;
                            });
                          },
                        ),
                        RoomCreationWidgets.oniDialogCard(
                          context: context,
                          oniCount: _oniCount,
                          onSelected: (selectedOni) {
                            setState(() {
                              _oniCount = selectedOni;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ]),
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
      String? ownerName = await _roomServices.getPlayerName();

      var bytes = utf8.encode(_passcode);
      var digest = sha256.convert(bytes);

      final settings = RoomSettings(
        1,
        _oniCount,
        _gameTimeLimit.inSeconds,
        digest.toString(),
      );

      await _creationRoomServices.createRoom(
          roomId.toString(), ownerId, ownerName ?? "RoomOwner", settings);

      return true;
    } catch (e) {
      showErrorDialog(context, 'ルームの作成に失敗しました: $e');
      return false;
    }
  }
}
