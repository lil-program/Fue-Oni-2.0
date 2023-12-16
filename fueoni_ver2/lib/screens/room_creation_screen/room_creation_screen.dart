import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fueoni_ver2/color_schemes.dart';
import 'package:fueoni_ver2/components/locate_permission_check.dart';
import 'package:fueoni_ver2/components/room/error_handling.dart';
import 'package:fueoni_ver2/components/room/passcode_dialog.dart';
import 'package:fueoni_ver2/components/room/room.dart';
import 'package:fueoni_ver2/models/arguments.dart';
import 'package:fueoni_ver2/screens/room_creation_screen/widgets/oni_dialog.dart';
import 'package:fueoni_ver2/screens/room_creation_screen/widgets/timer_dialog.dart';
import 'package:fueoni_ver2/services/room_creation/creation_service.dart';
import 'package:fueoni_ver2/services/room_management/player_service.dart';

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

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    double headerHeight = screenHeight * 0.20;
    double footerHeight = screenHeight * 0.10;

    return LocationPermissionCheck(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: lightColorScheme.primary,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            //ヘッダー
            buildHeader(headerHeight, screenWidth),
            //フォーム
            Expanded(
              child: buildFormSection(screenWidth),
            ),
            //フッター
            buildFooter(footerHeight, screenWidth, context),
          ],
        ),
      ),
    );
  }

  Widget buildFooter(double height, double width, BuildContext context) {
    return Container(
      height: height,
      width: width,
      color: Theme.of(context).colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back button
            IconButton(
              icon: const Icon(
                Icons.arrow_circle_left_outlined,
                color: Colors.white,
                size: 50,
              ),
              onPressed: () {
                _navigateToHomeScreen();
              },
            ),
            // Check button
            IconButton(
              icon: const Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 50,
              ),
              onPressed: () {
                _navigateToRoomCreationWaitingScreen();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildFormSection(double width) {
    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: buildListTiles(),
              //buildListDialogCard(),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildHeader(double height, double width) {
    return Container(
      height: height,
      width: width,
      color: lightColorScheme.primary,
      child: const Center(
        child: Text(
          'Choose your camera equipment',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  ListTile buildListTile(
      IconData leadingIcon, String title, IconData trailingIcon) {
    return ListTile(
      leading: Icon(leadingIcon),
      title: Text(title),
      trailing: Icon(trailingIcon),
    );
  }

  List<Widget> buildListTiles() {
    return [
      buildRoomIDDisplay("Room ID", "${roomId ?? "Generating Room ID"}"),
      const Divider(),
      buildSettingTile(Icons.vpn_key, "Passcode", _formatPasscode(_passcode),
          () async {
        String? result = await showPasscodeDialog(context: context);
        setState(() {
          if (result != null) {
            _passcode = result;
          }
        });
      }),
      buildSettingTile(
          Icons.timer, "Time Limit", _formatDuration(_gameTimeLimit).join(),
          () async {
        Duration? result = await showTimerDialog(context: context);
        setState(() {
          if (result != null) {
            _gameTimeLimit = result;
          }
        });
      }),
      buildSettingTile(
          CustomIcons.oni, "Oni Setting", _formatOniCount(_oniCount), () async {
        int? result = await showOniDialog(context: context);
        setState(() {
          if (result != null) {
            _oniCount = result;
          }
        });
      }),
    ];
  }

  Widget buildRoomIDDisplay(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value,
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget buildSettingTile(
      IconData icon, String title, String value, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(value),
      trailing: IconButton(
        icon: const Icon(Icons.edit),
        onPressed: onTap,
      ),
    );
  }

  Future<void> generateRoomId() async {
    final uniqueRoomId = await CreationService().generateUniqueRoomId();
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
      String? ownerName = await PlayerService().getPlayerName();

      var bytes = utf8.encode(_passcode);
      var digest = sha256.convert(bytes);

      final settings = RoomSettings(
        1,
        _oniCount,
        _gameTimeLimit.inSeconds,
        digest.toString(),
      );

      await CreationService().createRoom(
          roomId.toString(), ownerId, ownerName ?? "RoomOwner", settings);

      return true;
    } catch (e) {
      if (mounted) {
        showErrorDialog(context, 'ルームの作成に失敗しました: $e');
      }
      return false;
    }
  }

  List<String> _formatDuration(Duration duration) {
    if (duration == Duration.zero) {
      return ["Set Time"];
    }

    String hours = duration.inHours > 0 ? "${duration.inHours} hours " : "";
    String minutes =
        (duration.inMinutes % 60) > 0 ? "${duration.inMinutes % 60} mins " : "";
    String seconds =
        (duration.inSeconds % 60) > 0 ? "${duration.inSeconds % 60} secs" : "";

    return [hours, minutes, seconds]
        .where((element) => element.isNotEmpty)
        .toList();
  }

  String _formatOniCount(int oniCount) {
    if (oniCount == 0) {
      return "Set Oni Number";
    }

    return "$oniCount";
  }

  String _formatPasscode(String passcode) {
    if (passcode.isEmpty) {
      return "Set Passcode";
    }

    return "*" * passcode.length;
  }

  void _navigateToHomeScreen() {
    CreationService().removeRoomIdFromAllRoomId(roomId);
    Navigator.pushReplacementNamed(context, '/home');
  }

  void _navigateToRoomCreationWaitingScreen() async {
    try {
      bool success = await _createRoom();
      PlayerService().registerPlayer(roomId);
      if (success && mounted) {
        Navigator.pushReplacementNamed(
            context, '/home/room_settings/create_room/room_creation_waiting',
            arguments: CreationRoomArguments(roomId: roomId));
      }
    } catch (e) {
      if (mounted) {
        showErrorDialog(context, 'ルームの作成に失敗しました: $e');
      }
    }
  }
}