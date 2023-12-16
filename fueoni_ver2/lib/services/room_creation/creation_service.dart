import 'dart:math';

import 'package:firebase_database/firebase_database.dart';

class CreationService {
  final DatabaseReference _allRoomIdRef =
      FirebaseDatabase.instance.ref('allroomId');
  final DatabaseReference _gamesRef = FirebaseDatabase.instance.ref('games');
  final Random _random = Random();

  Future<void> createRoom(
      String roomId, String ownerId, String ownerName, RoomSettings settings) {
    return _gamesRef.child(roomId).set({
      'owner': {
        'id': ownerId,
        'name': ownerName,
      },
      'settings': {
        'participantCount': settings.participantCount,
        'initialOniCount': settings.initialOniCount,
        'timeLimit': settings.timeLimit,
      },
      'passwordHash': settings.passwordHash,
    });
  }

  Future<int> generateUniqueRoomId() async {
    int roomId;
    bool exists;
    Future<List<int>> allroomIds = getAllRoomIds();

    do {
      roomId = _generateSixDigitNumber();

      exists = await _roomIdExistsInAll(roomId, allroomIds);
    } while (exists);

    await _allRoomIdRef.child(roomId.toString()).set(true);

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

  Future<bool> removeRoomIdFromAllRoomId(int? roomid) async {
    try {
      await _allRoomIdRef.child(roomid.toString()).remove();
      return true;
    } catch (e) {
      return false;
    }
  }

  int _generateSixDigitNumber() {
    return _random.nextInt(900000) + 100000;
  }

  Future<bool> _roomIdExistsInAll(
      int roomId, Future<List<int>> allroomIdsFuture) async {
    List<int> allroomIds = await allroomIdsFuture;
    return allroomIds.any((element) => element == roomId);
  }
}

class RoomSettings {
  final int participantCount;
  final int initialOniCount;
  final int timeLimit;
  final String? passwordHash;

  RoomSettings(this.participantCount, this.initialOniCount, this.timeLimit,
      this.passwordHash);
}
