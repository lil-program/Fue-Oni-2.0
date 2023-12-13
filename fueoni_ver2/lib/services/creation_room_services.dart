import 'dart:math';

import 'package:firebase_database/firebase_database.dart';

class CreationRoomArguments {
  int? roomId;

  CreationRoomArguments({required this.roomId});
}

class CreationRoomServices {
  final DatabaseReference _allRoomIdRef =
      FirebaseDatabase.instance.ref('allroomId');

  final DatabaseReference _gamesRef = FirebaseDatabase.instance.ref('games');

  final Random _random = Random();
  Future<void> assignOniRandomly(int? roomId) async {
    List<String> playerIds = await getPlayersList(roomId);
    int oniCount = await getOniCount(roomId);

    Random random = Random();
    for (int i = 0; i < min(oniCount, playerIds.length); i++) {
      int randomIndex = random.nextInt(playerIds.length);
      String selectedPlayerId = playerIds[randomIndex];
      playerIds.removeAt(randomIndex);

      DatabaseReference playerRef = FirebaseDatabase.instance
          .ref('games/$roomId/players/$selectedPlayerId');
      playerRef.child('oni').set(true);
    }
  }

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

  Future<int> getInitialOniCount(int? roomId) async {
    DatabaseReference oniCountRef =
        FirebaseDatabase.instance.ref('games/$roomId/settings/initialOniCount');

    final snapshot = await oniCountRef.once();
    if (snapshot.snapshot.exists) {
      return int.tryParse(snapshot.snapshot.value.toString()) ?? 0;
    }
    return 0;
  }

  Future<int> getOniCount(int? roomId) async {
    DatabaseReference settingsRef =
        FirebaseDatabase.instance.ref('games/$roomId/settings');

    final snapshot = await settingsRef.child('initialOniCount').once();

    if (snapshot.snapshot.exists && snapshot.snapshot.value != null) {
      return int.tryParse(snapshot.snapshot.value.toString()) ?? 0;
    }
    return 0;
  }

  Future<List<String>> getPlayersList(int? roomId) async {
    DatabaseReference playersRef =
        FirebaseDatabase.instance.ref('games/$roomId/players');
    final snapshot = await playersRef.once();

    if (!snapshot.snapshot.exists || snapshot.snapshot.value == null) {
      return [];
    }

    Map<dynamic, dynamic> playersData =
        snapshot.snapshot.value as Map<dynamic, dynamic>;
    return playersData.keys.cast<String>().toList();
  }

  Future<Duration> getTimeLimit(int? roomId) async {
    DatabaseReference timeLimitRef =
        FirebaseDatabase.instance.ref('games/$roomId/settings/timeLimit');

    final snapshot = await timeLimitRef.once();
    if (snapshot.snapshot.exists) {
      int seconds = int.tryParse(snapshot.snapshot.value.toString()) ?? 0;
      return Duration(seconds: seconds);
    }
    return Duration.zero;
  }

  Future<bool> removeRoomIdFromAllRoomId(int? roomid) async {
    try {
      await _allRoomIdRef.child(roomid.toString()).remove();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeRoomIdFromGames(int? roomid) async {
    try {
      await _gamesRef.child(roomid.toString()).remove();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> setGameStart(int? roomId, bool gameStart) async {
    DatabaseReference gameStartRef =
        FirebaseDatabase.instance.ref('games/$roomId/settings/gameStart');

    await gameStartRef.set(gameStart);
  }

  Future<bool> updateSettings(
      int? roomId, Duration? selectedDuration, int numberOfDemons) async {
    if (roomId == null || selectedDuration == null) {
      return false;
    }

    try {
      await _gamesRef.child(roomId.toString()).child('settings').update({
        'timeLimit': selectedDuration.inSeconds,
        'initialOniCount': numberOfDemons,
      });
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
