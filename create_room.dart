import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fueoni_ver2/services/database/room.dart';

class CreateRoomPage extends StatelessWidget {
  final _roomIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firebaseService = FirebaseService();

  CreateRoomPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ルーム作成'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _roomIdController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: '6桁のルームIDを入力',
              ),
              maxLength: 6,
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                hintText: 'パスワードを入力',
              ),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: () async {
                String roomId = _roomIdController.text;
                User? currentUser = FirebaseAuth.instance.currentUser;
                if (currentUser == null) {
                  // ユーザーがログインしていない場合の処理をここに書く
                  return;
                }
                String ownerId = currentUser.uid;
                var bytes =
                    utf8.encode(_passwordController.text); // パスワードをハッシュ化
                var digest = sha256.convert(bytes);
                RoomSettings settings =
                    RoomSettings(5, 1, 10, digest.toString()); // パスワードハッシュを設定
                await _firebaseService.createRoom(roomId, ownerId, settings);
              },
              child: const Text('ルームを作成'),
            ),
          ],
        ),
      ),
    );
  }
}
