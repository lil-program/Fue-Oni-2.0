import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fueoni_ver2/components/room/error_handling.dart';
import 'package:fueoni_ver2/components/room/passcode_dialog.dart';
import 'package:fueoni_ver2/components/room/room.dart';
import 'package:fueoni_ver2/models/arguments.dart';
import 'package:fueoni_ver2/services/room_management/game_service.dart';
import 'package:fueoni_ver2/services/room_management/player_service.dart';
import 'package:fueoni_ver2/services/room_search/passcode_service.dart';

class RoomSearchPage extends StatefulWidget {
  const RoomSearchPage({super.key});

  @override
  RoomSearchPageState createState() => RoomSearchPageState();
}

class RoomSearchPageState extends State<RoomSearchPage> {
  final TextEditingController _controller = TextEditingController();
  int? roomId;
  String inputPasscode = '';
  bool _isSearchDone = false;
  Map<String, dynamic>? gameInfo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: RoomWidgets.roomAppbar(
        context: context,
        roomId: roomId,
        title: "ルーム設定",
        onBackButtonPressed: (int? roomId) {
          if (roomId != null) {
            Navigator.pushReplacementNamed(context, '/home');
          }
          Navigator.pushReplacementNamed(context, '/home');
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'ルームID',
                hintText: '検索するルームIDを入力してください',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (value) {
                setState(() {
                  roomId = int.tryParse(value);
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _searchRoom,
              child: const Text('検索'),
            ),
            const SizedBox(height: 20),
            if (_isSearchDone) _buildSearchResult(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResult() {
    if (gameInfo == null) {
      return const Card(
        child: ListTile(
          title: Text('検索結果'),
          subtitle: Text('ゲーム情報は見つかりませんでした。'),
        ),
      );
    } else {
      return RoomWidgets.passcodeDialogCard(
        context: context,
        passcode: inputPasscode,
        displayWidgetFactory: (_) => foundDisplay(gameInfo!),
        onSelected: (selectedPasscode) async {
          bool isCorrect = await PasscodeService().isPasscodeCorrect(
            roomId!,
            selectedPasscode,
          );

          if (!mounted) return;

          if (isCorrect) {
            setState(() {
              inputPasscode = selectedPasscode;
            });
            await _registerPlayerId();
          } else {
            showErrorDialog(context, 'パスコードが間違っています。');
          }
        },
      );
    }
  }

  Future<void> _registerPlayerId() async {
    if (roomId == null) {
      showErrorDialog(context, 'ルームIDがありません。');
      return;
    }

    bool success = await PlayerService().registerPlayer(roomId!);

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacementNamed(
        context,
        '/home/room_settings/search_room/room_search_waiting',
        arguments: RoomArguments(roomId: roomId),
      );
    } else {
      showErrorDialog(context, 'プレイヤーの登録に失敗しました。');
    }
  }

  void _searchRoom() async {
    if (roomId != null) {
      final gameInfo = await GameService().getGameInfo(roomId!);
      setState(() {
        this.gameInfo = gameInfo;
        _isSearchDone = true;
      });
    }
  }
}
