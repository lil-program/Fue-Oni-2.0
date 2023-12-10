import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:fueoni_ver2/screens/result_screen/result_screen.dart';
import 'package:fueoni_ver2/screens/map_screen/oni_timer_map.dart';
import 'package:fueoni_ver2/screens/map_screen/runner_map_screen.dart';


// import 'components/sign_in_button.dart';
import 'components/sign_out_button.dart';

Future<void> initOniMapScreen() async {
  // MapScreenの初期化処理をここに書く
  // 例えば、Firebaseの初期化やデータの取得など
  await Future.delayed(const Duration(seconds: 2)); // ここでは2秒待つだけの例を示しています
}

class OniMapScreen extends StatefulWidget {
  const OniMapScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<OniMapScreen> createState() => _OniMapScreenState();
}

// とりあえず鬼３人逃走者２人にする
int remainingOni = 3;
int remainingRunner = 2;


class _OniMapScreenState extends State<OniMapScreen> {
  late GoogleMapController mapController;
  late StreamSubscription<Position> positionStreamSubscription;
  Set<Marker> markers = {};
  late StreamSubscription<User?> authUserStream;

  Duration mainTimerDuration = Duration(minutes: 10); // 残り時間のタイマー
  Duration oniTimerDuration = Duration(minutes: 1); // 鬼タイマー
  Timer? mainTimer;
  Timer? oniTimer;

@override
void initState() {
  super.initState();
  markers.add(
    Marker(
      markerId: const MarkerId('oni'),
      position: LatLng(33.570734171832, 130.24635431587),
    ),
  );
  startMainTimer(); // 主タイマーを起動します。
  startOniTimer(); // 鬼タイマーを起動します。
}


  void startMainTimer() {
    mainTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (mainTimerDuration.inSeconds <= 0) {
          timer.cancel();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ResultScreen(),
            ),
          );
        } else {
          mainTimerDuration = mainTimerDuration - Duration(seconds: 1);
        }
      });
    });
  }


  void startOniTimer() {
    oniTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (oniTimerDuration.inSeconds <= 0) {
          timer.cancel();
          navigateToRunnerLocationScreen(); // RunnerLocationScreenに遷移
        } else {
          oniTimerDuration = oniTimerDuration - Duration(seconds: 1);
        }
      });
    });
  }

  void navigateToRunnerLocationScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RunnerLocationScreen(),
      ),
    ).then((_) {
      oniTimerDuration = Duration(minutes: 1);
      startOniTimer();
    });
  }



  bool isSignedIn = false;
  bool isLoading = false;

  final CameraPosition initialCameraPosition = const CameraPosition(
    target: LatLng(33.570734171832, 130.24635431587),
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
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(40),
        child: AppBar(
          automaticallyImplyLeading: false,
          title: Column(
            children: [
              Text(
                '残り時間${_formatDuration(mainTimerDuration)}',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
      ),
      body: GoogleMap(
        initialCameraPosition: initialCameraPosition,
        onMapCreated: (GoogleMapController controller) async {
          mapController = controller;
          // await _requestPermission();
          await _moveToCurrentLocation();
          // await _watchPosition();
        },
        myLocationEnabled: false,
        myLocationButtonEnabled: false,
        markers: markers,
      ),
      floatingActionButton: Stack(
        children: <Widget>[
          Positioned(
            left: 0.0,
            bottom: 50,
            child: FloatingActionButton(
              onPressed: () async {
                await _moveToCurrentLocation();
              },
              child: Icon(
                Icons.my_location,
                color: Theme.of(context).iconTheme.color,
              ),
              elevation: 6,
            ),
          ),
          Positioned(
            right: 30,
            bottom: 10,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor, 
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                  bottomLeft: Radius.circular(20.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(5, 5),
                    blurRadius: 6,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Text(
                '鬼残り${remainingOni}人',
                style: TextStyle(
                  fontWeight: FontWeight.bold, // テキストを太字に
                  fontSize: 16,
                ),
              ),
            ),
          ),
          
          Positioned(
            left: 3,
            bottom: 10,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                  bottomRight: Radius.circular(20.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(3, 3),
                    blurRadius: 4,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Text(
                '逃走者残り${remainingRunner}人',
                style: TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: 16,
                ),
              ),
            ),
          ),
          Positioned(
            right: 115,
            bottom: 650,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                  bottomLeft: Radius.circular(20.0),
                  bottomRight: Radius.circular(20.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(5, 5),
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Text(
                  '鬼タイマー: ${_formatDuration(oniTimerDuration)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
              ),
            ),
          ),
          Positioned(
            right: 30,
            bottom: 50.0,
            child: FloatingActionButton(
              onPressed: () async {
                // TODO: ここにカメラを起動する記述

              },
              child: Icon(
                Icons.qr_code_scanner,
                color: Theme.of(context).iconTheme.color,
              ),
            ),
          ),


],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  @override
  void dispose() {
    mainTimer?.cancel();
    oniTimer?.cancel();
    mapController.dispose();
    positionStreamSubscription.cancel();
    authUserStream.cancel();
    super.dispose();
  }
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
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
      // // 現在地を取得
      // final Position position = await Geolocator.getCurrentPosition(
      //   desiredAccuracy: LocationAccuracy.high,
      // );
      final double latitude = 33.570734171832;
      final double longitude = 130.24635431587;  
  

      setState(() {
        markers.removeWhere((Marker marker) {
          return marker.markerId.value == 'current_location';
        });
        markers.add(
          Marker(
            markerId: const MarkerId('current_location'),
            position: LatLng(latitude, longitude),
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
            target: LatLng(latitude, longitude),
            zoom: 16.0,
          ),
        ),
      );
    }
  }

  // Future<void> _requestPermission() async {
  //   // 位置情報の許可を求める
  //   LocationPermission permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     await Geolocator.requestPermission();
  //   }
  // }

  Future<void> _signOut() async {
    setIsLoading(true);
    await Future.delayed(const Duration(seconds: 1), () {});
    await FirebaseAuth.instance.signOut();
    setIsLoading(false);
  }

  // Future<void> _watchPosition() async {
  //   // 現在地の変化を監視
  //   positionStreamSubscription =
  //       Geolocator.getPositionStream(locationSettings: locationSettings)
  //           .listen((Position position) async {
  //     setState(() {
  //       markers.removeWhere((Marker marker) {
  //         return marker.markerId.value == 'current_location';
  //       });

  //       markers.add(
  //         Marker(
  //           markerId: const MarkerId('current_location'),
  //           position: LatLng(position.latitude, position.longitude),
  //           infoWindow: const InfoWindow(
  //             title: '現在地',
  //           ),
  //         ),
  //       );
  //     });

    //   // 現在地にカメラを移動
    //   await mapController.animateCamera(
    //     CameraUpdate.newCameraPosition(
    //       CameraPosition(
    //         target: LatLng(position.latitude, position.longitude),
    //         zoom: 16.0,
    //       ),
    //     ),
    //   );
    // });
  }

//   void _watchSignInState() {
//     authUserStream =
//         FirebaseAuth.instance.authStateChanges().listen((User? user) {
//       if (user == null) {
//         setIsSignedIn(false);
//       } else {
//         setIsSignedIn(true);
//       }
//     });
//   }
// }
      //     Align(
      //       alignment: Alignment.bottomCenter,
      //       child: !isSignedIn
      //           ? const SignInButton()
      //           : SignOutButton(
      //               isLoading: isLoading,
      //               onPressed: () => _signOut(),
      //             ),
      //     ),