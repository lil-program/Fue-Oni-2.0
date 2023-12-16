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
}
