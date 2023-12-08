import 'dart:math';

import 'package:firebase_database/firebase_database.dart';

class RoomIdGenerator {
  final DatabaseReference _allRoomIdRef =
      FirebaseDatabase.instance.ref('allroomId');
  final Random _random = Random();

  // ユニークなroomIdを生成するメソッド
  Future<int> generateUniqueRoomId() async {
    int roomId;
    bool exists;
    Future<List<int>> allroomIds = getAllRoomIds();

    do {
      roomId = _generateSixDigitNumber();

      exists = await _roomIdExistsInAll(roomId, allroomIds);
    } while (exists);

    return roomId;
  }

  Future<List<int>> getAllRoomIds() async {
    List<int> roomIds = [];
    final snapshot = await _allRoomIdRef.once();
    if (snapshot.snapshot.exists) {
      Map<dynamic, dynamic> values =
          snapshot.snapshot.value as Map<dynamic, dynamic>;
      values.forEach((key, value) {
        int roomId = int.tryParse(key) ?? 0;
        if (roomId != 0) {
          roomIds.add(roomId);
        }
      });
    }

    return roomIds;
  }

// 6桁の数字を生成するメソッド
  int _generateSixDigitNumber() {
    return _random.nextInt(900000) + 100000;
  }

  // 生成されたroomIdがallroomIdに存在するかどうかを確認するメソッド
  Future<bool> _roomIdExistsInAll(
      int roomId, Future<List<int>> allroomIdsFuture) async {
    List<int> allroomIds = await allroomIdsFuture;
    return allroomIds.any((element) => element == roomId);
  }
}
