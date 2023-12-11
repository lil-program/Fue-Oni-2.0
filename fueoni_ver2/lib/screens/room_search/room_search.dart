import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fueoni_ver2/services/search_room_services.dart';
import 'package:fueoni_ver2/utils/error_handling.dart';

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
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ルーム検索')),
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
      return Card(
        child: ListTile(
            title: const Text('検索結果'),
            subtitle: Text(_formatGameInfo(gameInfo!)),
            onTap: () async {
              _onTapSearchResult();
            }),
      );
    }
  }

  String _formatGameInfo(Map<String, dynamic> info) {
    String ownerName = info['owner']['name'] ?? '未知';
    int timeLimit = info['settings']['timeLimit'] ?? 0;
    int participantCount = info['settings']['participantCount'] ?? 0;
    int initialOniCount = info['settings']['initialOniCount'] ?? 0;

    return 'オーナー: $ownerName\n'
        '時間制限: $timeLimit分\n'
        '参加者数: $participantCount\n'
        '初期鬼の数: $initialOniCount';
  }

  void _onTapSearchResult() async {
    print("AAAAAAAAAAAAAAAAAAAAA");
    print(gameInfo);
    print(gameInfo!.containsKey('passwordHash'));
    print(gameInfo!['passwordHash'].isNotEmpty);
    if (gameInfo != null &&
        gameInfo!.containsKey('passwordHash') &&
        gameInfo!['passwordHash'].isNotEmpty) {
      await _showPasswordDialog();

      if (_validatePasscode(inputPasscode)) {
        Navigator.pushNamed(
          context,
          '/home/room_settings/search_room/room_search_waiting',
          arguments: SearchRoomArguments(roomId: roomId),
        );
      } else {
        showErrorDialog(context, 'パスワードが間違っています。');
      }
    } else {
      Navigator.pushNamed(
        context,
        '/home/room_settings/search_room/room_search_waiting',
        arguments: SearchRoomArguments(roomId: roomId),
      );
    }
  }

  void _searchRoom() async {
    if (roomId != null) {
      final gameInfo = await SearchRoomServices().getGameInfo(roomId!);
      setState(() {
        this.gameInfo = gameInfo;
        _isSearchDone = true;
      });
    }
  }

  Future<void> _showPasswordDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('パスワード入力'),
          content: TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              hintText: 'パスワード',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('キャンセル'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                setState(() {
                  inputPasscode = _passwordController.text;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  bool _validatePasscode(String? enteredPasscode) {
    if (enteredPasscode == null || enteredPasscode.isEmpty) return false;

    // パスワードをハッシュ化
    var bytes = utf8.encode(enteredPasscode);
    var digest = sha256.convert(bytes);

    // ハッシュ値をFirebaseから取得した値と比較
    return digest.toString() == gameInfo!['passwordHash'];
  }
}
