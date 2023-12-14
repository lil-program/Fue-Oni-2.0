import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class SearchRoomArguments {
  int? roomId;

  SearchRoomArguments({required this.roomId});
}

class SearchRoomServices {
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

  Future<bool> isPasscodeCorrect(int roomId, String inputPasscode) async {
    try {
      DatabaseReference roomRef =
          FirebaseDatabase.instance.ref('games/$roomId');
      final snapshot = await roomRef.once();

      if (snapshot.snapshot.exists) {
        Map<dynamic, dynamic> dynamicMap =
            snapshot.snapshot.value as Map<dynamic, dynamic>;
        String storedPasscodeHash = dynamicMap['passwordHash'];
        var bytes = utf8.encode(inputPasscode);
        var inputPasscodeHash = sha256.convert(bytes).toString();

        return storedPasscodeHash == inputPasscodeHash;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  void monitorGameStart(int? roomId, Function(bool) onGameStartChanged) {
    DatabaseReference gameStartRef =
        FirebaseDatabase.instance.ref('games/$roomId/settings/gameStart');

    gameStartRef.onValue.listen((event) {
      if (event.snapshot.exists && event.snapshot.value == true) {
        onGameStartChanged(true);
      }
    });
  }

  Future<bool> removePlayerId(int? roomId) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null || roomId == null) {
      return false;
    }

    try {
      String playerId = currentUser.uid;
      DatabaseReference playerRef =
          FirebaseDatabase.instance.ref('games/$roomId/players');

      await playerRef.child(playerId.toString()).remove();

      return true;
    } catch (e) {
      return false;
    }
  }
}
