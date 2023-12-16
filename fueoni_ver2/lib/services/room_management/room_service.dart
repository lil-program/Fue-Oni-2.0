import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class RoomService {
  Future<bool> areAllPlayersLocationsSet(int? roomId) async {
    DatabaseReference playersRef =
        FirebaseDatabase.instance.ref('games/$roomId/players');

    final snapshot = await playersRef.once();

    if (snapshot.snapshot.exists) {
      Map<dynamic, dynamic> playersData =
          snapshot.snapshot.value as Map<dynamic, dynamic>;
      for (var playerData in playersData.values) {
        if (playerData['location'] == null ||
            playerData['location']['latitude'] == null ||
            playerData['location']['longitude'] == null) {
          // 少なくとも1人のプレイヤーの位置情報が設定されていない
          return false;
        }
      }
      // すべてのプレイヤーの位置情報が設定されている
      return true;
    }

    // プレイヤーデータが存在しない
    return false;
  }

  Future<String?> getRoomOwnerName(int? roomId) async {
    DatabaseReference ownerRef =
        FirebaseDatabase.instance.ref('games/$roomId/owner');
    final snapshot = await ownerRef.once();
    if (snapshot.snapshot.exists && snapshot.snapshot.value != null) {
      Map<dynamic, dynamic> ownerData =
          snapshot.snapshot.value as Map<dynamic, dynamic>;
      return ownerData['name'];
    }
    return null;
  }

  void monitorPlayersNames(int? roomId, Function(List<String>) onNamesUpdated) {
    DatabaseReference playersRef =
        FirebaseDatabase.instance.ref('games/$roomId/players');

    playersRef.onValue.listen((event) {
      List<String> names = [];
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.exists && snapshot.value != null) {
        Map<dynamic, dynamic> playersData =
            snapshot.value as Map<dynamic, dynamic>;
        for (var playerData in playersData.values) {
          if (playerData['name'] != null) {
            names.add(playerData['name'].toString());
          }
        }
      }

      onNamesUpdated(names);
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

  void updatePlayersList(int? roomId, Function(List<String>) onUpdated) {
    monitorPlayersNames(roomId, (names) {
      onUpdated(names);
    });
  }
}
