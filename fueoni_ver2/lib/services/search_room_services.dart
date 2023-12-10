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
}
