import 'dart:math';

import 'package:firebase_database/firebase_database.dart';

class RoomIdGenerator {
  final DatabaseReference _roomsRef = FirebaseDatabase.instance.ref('games');
  final Random _random = Random();

  // ユニークなroomIdを生成するメソッド
  Future<int> generateUniqueRoomId() async {
    int roomId;
    bool exists;
    int cnt = 0;

    do {
      cnt++;
      print('$cnt');
      roomId = _generateSixDigitNumber();
      exists = await _roomIdExists(roomId);
    } while (exists);

    return roomId;
  }

  // 6桁の数字を生成するメソッド
  int _generateSixDigitNumber() {
    return _random.nextInt(900000) + 100000; // 100000から999999までの数字を生成
  }

  // 生成されたroomIdがFirebaseに存在するかどうかを確認するメソッド
  Future<bool> _roomIdExists(int roomId) async {
    final snapshot = await _roomsRef.child(roomId.toString()).once();
    return snapshot.snapshot.exists;
  }
}
