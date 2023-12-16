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

  void monitorOniPlayers(int? roomId, Function(Map<String, bool>) onOniPlayersChanged) {
    DatabaseReference oniPlayersRef = FirebaseDatabase.instance.ref('games/$roomId/oniPlayers');

    oniPlayersRef.onValue.listen((event) {
      if (event.snapshot.exists) {
        Map<String, bool> oniPlayers = {};
        Map<dynamic, dynamic> values = event.snapshot.value as Map<dynamic, dynamic>;
        values.forEach((key, value) {
          // ここでは、keyがplayerId、valueがそのプレイヤーが鬼かどうかを表します
          oniPlayers[key] = value;
        });
        onOniPlayersChanged(oniPlayers);
      }
    });
  }
}


