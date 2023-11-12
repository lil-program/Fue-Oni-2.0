import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'components/sign_in_button.dart';
import 'components/sign_out_button.dart';

Future<MapScreen> initMapScreen() async {
  // MapScreenの初期化処理をここに書く
  // 例えば、Firebaseの初期化やデータの取得など
  await Future.delayed(const Duration(seconds: 2)); // ここでは2秒待つだけの例を示しています
  return const MapScreen();
}

class MapScreen extends StatefulWidget {
  const MapScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  late StreamSubscription<Position> positionStreamSubscription;
  Set<Marker> markers = {};
  late StreamSubscription<User?> authUserStream;

  bool isSignedIn = false;
  bool isLoading = false;

  final CameraPosition initialCameraPosition = const CameraPosition(
    target: LatLng(35.681236, 139.767125),
    zoom: 16.0,
  );

  // 現在地通知の設定
  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high, //正確性:highはAndroid(0-100m),iOS(10m)
    distanceFilter: 10,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          'Map',
          style: TextStyle(color: Theme.of(context).primaryColor),
        ),
      ),
      body: GoogleMap(
        initialCameraPosition: initialCameraPosition,
        onMapCreated: (GoogleMapController controller) async {
          mapController = controller;
          await _requestPermission();
          await _moveToCurrentLocation();
          await _watchPosition();
        },
        myLocationEnabled: false,
        myLocationButtonEnabled: false,
        markers: markers,
      ),
      floatingActionButton: Stack(
        children: <Widget>[
          Positioned(
            left: 0.0,
            bottom: 0.0,
            child: FloatingActionButton(
              onPressed: () async {
                await _moveToCurrentLocation();
              },
              child: Icon(
                Icons.my_location,
                color: Theme.of(context).iconTheme.color,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: !isSignedIn
                ? const SignInButton()
                : SignOutButton(
                    isLoading: isLoading,
                    onPressed: () => _signOut(),
                  ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  @override
  void dispose() {
    mapController.dispose();
    positionStreamSubscription.cancel();
    authUserStream.cancel();
    super.dispose();
  }

  @override
  void initState() {
    // ログイン状態の変化を監視
    _watchSignInState();
    super.initState();
  }

  void setIsLoading(bool value) {
    setState(() {
      isLoading = value;
    });
  }

  void setIsSignedIn(bool value) {
    setState(() {
      isSignedIn = value;
    });
  }

  Future<void> _moveToCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      // 現在地を取得
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        markers.removeWhere((Marker marker) {
          return marker.markerId.value == 'current_location';
        });
        markers.add(
          Marker(
            markerId: const MarkerId('current_location'),
            position: LatLng(position.latitude, position.longitude),
            infoWindow: const InfoWindow(
              title: '現在地',
            ),
          ),
        );
      });

      // 現在地にカメラを移動
      await mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 16.0,
          ),
        ),
      );
    }
  }

  Future<void> _requestPermission() async {
    // 位置情報の許可を求める
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }
  }

  Future<void> _signOut() async {
    setIsLoading(true);
    await Future.delayed(const Duration(seconds: 1), () {});
    await FirebaseAuth.instance.signOut();
    setIsLoading(false);
  }

  Future<void> _watchPosition() async {
    // 現在地の変化を監視
    positionStreamSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position position) async {
      setState(() {
        markers.removeWhere((Marker marker) {
          return marker.markerId.value == 'current_location';
        });

        markers.add(
          Marker(
            markerId: const MarkerId('current_location'),
            position: LatLng(position.latitude, position.longitude),
            infoWindow: const InfoWindow(
              title: '現在地',
            ),
          ),
        );
      });

      // 現在地にカメラを移動
      await mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 16.0,
          ),
        ),
      );
    });
  }

  void _watchSignInState() {
    authUserStream =
        FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        setIsSignedIn(false);
      } else {
        setIsSignedIn(true);
      }
    });
  }
}
