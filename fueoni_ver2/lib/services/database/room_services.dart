import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';

class RoomServices {
  Future<bool> areAllPlayersLocationsSet(int? roomId) async {
    DatabaseReference playersRef =
        FirebaseDatabase.instance.ref('games/$roomId/players');

    final snapshot = await playersRef.once();
    print("AAAAAAAAAAAAAAAAAa");
    print("$roomId");

    print(snapshot.snapshot.exists);
    if (snapshot.snapshot.exists) {
      Map<dynamic, dynamic> playersData =
          snapshot.snapshot.value as Map<dynamic, dynamic>;
      for (var playerData in playersData.values) {
        print(playerData['location']);
        print(playerData['location']['latitude']);
        print(playerData['location']['longitude']);

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

  Future<String?> getPlayerName() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return null;
    }

    try {
      String playerId = currentUser.uid;
      DatabaseReference playerInfoRef =
          FirebaseDatabase.instance.ref('users/$playerId');

      final snapshot = await playerInfoRef.once();
      if (snapshot.snapshot.exists) {
        Map<dynamic, dynamic> userData =
            snapshot.snapshot.value as Map<dynamic, dynamic>;
        return userData['name'];
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
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

  Future<bool> registerPlayer(int? roomId) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return false;
    }

    try {
      String playerId = currentUser.uid;

      String? playerName = await getPlayerName();

      if (playerName == null || playerName.isEmpty) {
        playerName = await _generateAlternateName();
      }

      DatabaseReference playerRef =
          FirebaseDatabase.instance.ref('games/$roomId/players/$playerId');

      await playerRef.set({
        'name': playerName,
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> updatePlayerLocation(
      int? roomId, double latitude, double longitude) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    String playerId = currentUser.uid;
    DatabaseReference locationRef = FirebaseDatabase.instance
        .ref('games/$roomId/players/$playerId/location');

    await locationRef.set({
      'latitude': latitude,
      'longitude': longitude,
    });
  }

  void updatePlayersList(int? roomId, Function(List<String>) onUpdated) {
    monitorPlayersNames(roomId, (names) {
      onUpdated(names);
    });
  }

  Future<String> _generateAlternateName() async {
    return 'User${DateTime.now().millisecondsSinceEpoch}';
  }

  static Future<bool> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  static Future<void> updateCurrentLocation(
      RoomServices roomServices, int? roomId) async {
    try {
      final Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      await roomServices.updatePlayerLocation(
          roomId, position.latitude, position.longitude);
    } catch (e) {
      print('位置情報の取得に失敗しました: $e');
    }
  }
}
