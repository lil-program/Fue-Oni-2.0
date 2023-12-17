import 'dart:math';

import 'package:firebase_database/firebase_database.dart';

class OniAssignmentService {
  Future<void> assignOniRandomly(int? roomId) async {
    List<String> playerIds = await getPlayersList(roomId);
    int oniCount = await getOniCount(roomId);
    final Random random = Random();

    for (int i = 0; i < min(oniCount, playerIds.length); i++) {
      int randomIndex = random.nextInt(playerIds.length);
      String selectedPlayerId = playerIds[randomIndex];
      playerIds.removeAt(randomIndex);

      DatabaseReference playerRef = FirebaseDatabase.instance
          .ref('games/$roomId/players/$selectedPlayerId');
      playerRef.child('oni').set(true);
    }
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

  Future<void> setOni(int? roomId, String? userId) async {
    if (userId != null && roomId != null) {
      DatabaseReference playerRef =
          FirebaseDatabase.instance.ref('games/$roomId/players/$userId');
      await playerRef.child('oni').set(true);
    }
  }
}
