import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  final DatabaseReference _gamesRef =
      FirebaseDatabase.instance.ref().child('games');

  Future<void> createRoom(
      String roomId, String ownerId, RoomSettings settings) {
    return _gamesRef.child(roomId).set({
      'owner': {
        'id': ownerId,
        'name': "owner",
      },
      'settings': {
        'participantCount': settings.participantCount,
        'initialOniCount': settings.initialOniCount,
        'timeLimit': settings.timeLimit,
      },
      'passwordHash': settings.passwordHash, // パスワードハッシュを保存
    });
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
