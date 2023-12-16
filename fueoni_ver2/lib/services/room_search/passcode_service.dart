import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:firebase_database/firebase_database.dart';

class PasscodeService {
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
}
