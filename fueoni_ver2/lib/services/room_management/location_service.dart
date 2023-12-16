import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<void> updatePlayerLocation(
      int? roomId, double latitude, double longitude) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    String playerId = currentUser.uid;
    DatabaseReference locationRef = FirebaseDatabase.instance
        .ref('games/$roomId/players/$playerId/location');

    await locationRef.set({
      'latitude': latitude,
      'longitude': longitude,
    });
  }

  static Future<bool> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  static Future<void> updateCurrentLocation(
      LocationService locationService, int? roomId) async {
    try {
      final Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      await locationService.updatePlayerLocation(
          roomId, position.latitude, position.longitude);
    } catch (e) {
      print('位置情報の取得に失敗しました: $e');
    }
  }
}
