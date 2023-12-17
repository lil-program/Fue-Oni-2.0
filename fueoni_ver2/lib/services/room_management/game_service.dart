import 'package:firebase_database/firebase_database.dart';

class GameService {
  final DatabaseReference _gamesRef = FirebaseDatabase.instance.ref('games');
  Future<Map<String, dynamic>?> getGameInfo(int roomId) async {
    try {
      DatabaseReference roomRef =
          FirebaseDatabase.instance.ref('games/$roomId');
      DataSnapshot snapshot = await roomRef.get();

      if (snapshot.exists) {
        Map<dynamic, dynamic> dynamicMap =
            snapshot.value as Map<dynamic, dynamic>;

        Map<String, dynamic> stringMap = {};
        dynamicMap.forEach((key, value) {
          if (key is String) {
            stringMap[key] = value;
          }
        });

        return stringMap;
      } else {
        return null;
      }
    } catch (e) {
      return null;
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

  Future<void> setOniScanStart(int? roomId, bool oniScanStart) async {
    if (roomId == null) {
      return;
    }

    DatabaseReference oniScanStartRef =
        FirebaseDatabase.instance.ref('games/$roomId/settings/oniScanStart');

    await oniScanStartRef.set(oniScanStart);
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
}
