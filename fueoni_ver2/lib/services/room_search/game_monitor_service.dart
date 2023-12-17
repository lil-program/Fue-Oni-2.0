import 'package:firebase_database/firebase_database.dart';

class GameMonitorService {
  void monitorGameStart(int? roomId, Function(bool) onGameStartChanged) {
    DatabaseReference gameStartRef =
        FirebaseDatabase.instance.ref('games/$roomId/settings/gameStart');

    gameStartRef.onValue.listen((event) {
      if (event.snapshot.exists && event.snapshot.value == true) {
        onGameStartChanged(true);
      }
    });
  }

  void monitorOniPlayers(
      int? roomId, Function(Map<String, bool>) onOniPlayersChanged) {
    DatabaseReference oniPlayersRef =
        FirebaseDatabase.instance.ref('games/$roomId/oniPlayers');

    oniPlayersRef.onValue.listen((event) {
      if (event.snapshot.exists) {
        Map<String, bool> oniPlayers = {};
        Map<dynamic, dynamic> values =
            event.snapshot.value as Map<dynamic, dynamic>;
        values.forEach((key, value) {
          oniPlayers[key] = value;
        });
        onOniPlayersChanged(oniPlayers);
      }
    });
  }

  void monitorOniScanStart(int? roomId, Function(bool) onOniScanStartChanged) {
    DatabaseReference oniScanStartRef =
        FirebaseDatabase.instance.ref('games/$roomId/settings/oniScanStart');

    oniScanStartRef.onValue.listen((event) {
      if (event.snapshot.exists) {
        bool isOniScanStarted = event.snapshot.value as bool;
        onOniScanStartChanged(isOniScanStarted);
      }
    });
  }

  void monitorPlayerOniState(
      int? roomId, String? playerId, Function(bool) onOniStateChanged) {
    DatabaseReference playerRef =
        FirebaseDatabase.instance.ref('games/$roomId/players/$playerId');

    playerRef.child('oni').onValue.listen((event) {
      if (event.snapshot.exists) {
        bool isOni = event.snapshot.value as bool;
        onOniStateChanged(isOni);
      }
    });
  }
}
