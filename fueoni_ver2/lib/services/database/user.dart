import 'package:firebase_database/firebase_database.dart';

class UserService {
  final DatabaseReference _userRef;

  UserService(String userId)
      : _userRef = FirebaseDatabase.instance.ref().child('users/$userId');

  Future<String> fetchName() async {
    DatabaseEvent event = await _userRef.child('name').once();
    DataSnapshot snapshot = event.snapshot;
    if (snapshot.value == null) {
      return '';
    }
    return snapshot.value as String;
  }

  Future<void> updateName(String newName) {
    return _userRef.update({'name': newName});
  }
}
