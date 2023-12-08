import 'package:firebase_database/firebase_database.dart';

class UserService {
  final DatabaseReference _userRef;

  UserService(String userId)
      : _userRef = FirebaseDatabase.instance.ref().child('users/$userId');

  Future<void> updateName(String newName) {
    print('updateName: $newName');
    return _userRef.update({'name': newName});
  }
}
