import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class PlayerService {
  Future<Map<String, bool>> getOniPlayers(int? roomId) async {
    if (roomId == null) {
      return {};
    }

    DatabaseReference oniPlayersRef =
        FirebaseDatabase.instance.ref('games/$roomId/oniPlayers');

    final snapshot = await oniPlayersRef.once();
    if (snapshot.snapshot.exists && snapshot.snapshot.value != null) {
      Map<String, bool> oniPlayers =
          Map<String, bool>.from(snapshot.snapshot.value as Map);
      return oniPlayers;
    } else {
      return {};
    }
  }

  Future<String?> getPlayer() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      return currentUser.uid;
    }
    return null;
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

  Future<bool> isPlayerOni(int roomId) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return false;
    }

    try {
      String playerId = currentUser.uid;
      DatabaseReference oniStatusRef =
          FirebaseDatabase.instance.ref('games/$roomId/players/$playerId/oni');

      final snapshot = await oniStatusRef.once();
      if (snapshot.snapshot.exists) {
        return snapshot.snapshot.value == true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
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

  Future<String> _generateAlternateName() async {
    return 'User${DateTime.now().millisecondsSinceEpoch}';
  }
}
