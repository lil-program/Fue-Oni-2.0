import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationService {
  Future<List<LatLng>> getNonOniPlayerLocations(int? roomId) async {
    if (roomId == null) {
      return [];
    }

    DatabaseReference playersRef =
        FirebaseDatabase.instance.ref('games/$roomId/players');
    final snapshot = await playersRef.get();

    if (snapshot.exists && snapshot.value != null) {
      List<LatLng> locations = [];
      Map<dynamic, dynamic> playersData =
          snapshot.value as Map<dynamic, dynamic>;

      for (var entry in playersData.entries) {
        String playerId = entry.key;
        var playerData = entry.value as Map<dynamic, dynamic>;

        // Check if the player is not an oni
        if (!(playerData['oni'] ?? false)) {
          if (playerData.containsKey('location')) {
            var locationData = PlayerLocation.fromJson(playerData['location']);
            locations
                .add(LatLng(locationData.latitude, locationData.longitude));
          }
        }
      }
      return locations;
    }

    return [];
  }

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

class PlayerLocation {
  final double latitude;
  final double longitude;

  PlayerLocation({required this.latitude, required this.longitude});

  factory PlayerLocation.fromJson(Map<dynamic, dynamic> json) {
    return PlayerLocation(
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
    );
  }
}
