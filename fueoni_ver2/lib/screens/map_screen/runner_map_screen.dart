import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fueoni_ver2/components/locate_permission_check.dart';
import 'package:fueoni_ver2/screens/result_screen/result_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:fueoni_ver2/services/room_creation/oni_assignment_service.dart';
import 'package:fueoni_ver2/models/arguments.dart';
// import 'package:firebase_database/firebase_database.dart';

Future<void> initRunnerMapScreen() async {
  // MapScreenの初期化処理をここに書く
  // 例えば、Firebaseの初期化やデータの取得など
  await Future.delayed(const Duration(seconds: 2)); // ここでは2秒待つだけの例を示しています
}

class RunnerMapScreen extends StatefulWidget {
  const RunnerMapScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<RunnerMapScreen> createState() => _RunnerMapScreenState();
}

class _RunnerMapScreenState extends State<RunnerMapScreen> {
  late GoogleMapController mapController;
  late StreamSubscription<Position> positionStreamSubscription;
  Set<Marker> markers = {};
  late StreamSubscription<User?> authUserStream;

  Duration mainTimerDuration = const Duration(minutes: 100); // 残り時間のタイマー
  Timer? mainTimer;

  int? roomId;

  bool isSignedIn = false;

  bool isLoading = false;

  int countOni = 0;
  int countNonOni = 0;

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
    return LocationPermissionCheck(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(40),
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
                heroTag: null,
                onPressed: () async {
                  await _moveToCurrentLocation();
                },
                elevation: 6,
                child: Icon(
                  Icons.my_location,
                  color: Theme.of(context).iconTheme.color,
                ),
              ),
            ),
            Positioned(
              right: 30,
              bottom: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0),
                    bottomLeft: Radius.circular(20.0),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(5, 5),
                      blurRadius: 6,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Text(
                  '鬼残り$countOni人',
                  style: const TextStyle(
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0),
                    bottomRight: Radius.circular(20.0),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(3, 3),
                      blurRadius: 4,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Text(
                  '逃走者残り$countNonOni人',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 30,
              bottom: 50.0,
              child: FloatingActionButton(
                heroTag: null,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return Dialog(
                        // child: Container(
                        // insetPadding : const EdgeInsets.only(left:5, right: 5, top: 20, bottom:20),
                        // padding: const EdgeInsets.all(20),
                        child: QrImageView(
                          padding: const EdgeInsets.only(
                              left: 60, right: 20, top: 20, bottom: 20),
                          data: "https://www.kamo-it.org/blog/36/",
                          version: QrVersions.auto,
                          size: 200.0,
                        ),
                        // ),
                      );
                    },
                  );
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
      ),
    );
  }

  @override
  void dispose() {
    mainTimer?.cancel();
    mapController.dispose();
    positionStreamSubscription.cancel();
    authUserStream.cancel();
    super.dispose();
  }

  // @override
  // void initState() {
  //   super.initState();
  //   markers.add(
  //     const Marker(
  //       markerId: MarkerId('oni'),
  //       position: LatLng(33.570734171832, 130.24635431587),
  //     ),
  //   );
  //   startMainTimer(); // 主タイマーを起動します。
  // }
  @override
  void initState() {
    super.initState();
    final args = ModalRoute.of(context)!.settings.arguments as RoomArguments;
    print(args.roomId);
    markers.add(
      const Marker(
        markerId: MarkerId('oni'),
        position: LatLng(33.570734171832, 130.24635431587),
      ),
    );
    setState(() {
      roomId = args.roomId;
    });
    startMainTimer(); // 主タイマーを起動します。
    // countOniAndNonOniPlayers(roomId);
    // WidgetsBinding.instance.addPostFrameCallback((_) async {
    //   final timeLimit = await OniAssignmentService().getTimeLimit(roomId);
    //   print("Time Limit: $timeLimit");
    // });
    // print(
    //     "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // contextに依存する処理
    final args = ModalRoute.of(context)!.settings.arguments as RoomArguments;
    setState(() {
      roomId = args.roomId;
    });

    // countOniAndNonOniPlayers(roomId);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final timeLimit = await OniAssignmentService().getTimeLimit(roomId);
      print("Time Limit: $timeLimit");
    });
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

  void startMainTimer() {
    mainTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
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
          mainTimerDuration = mainTimerDuration - const Duration(seconds: 1);
        }
      });
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  Future<void> _moveToCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      // // 現在地を取得
      // final Position position = await Geolocator.getCurrentPosition(
      //   desiredAccuracy: LocationAccuracy.high,
      // );
      const double latitude = 33.570734171832;
      const double longitude = 130.24635431587;

      setState(() {
        markers.removeWhere((Marker marker) {
          return marker.markerId.value == 'current_location';
        });
        markers.add(
          const Marker(
            markerId: MarkerId('current_location'),
            position: LatLng(latitude, longitude),
            infoWindow: InfoWindow(
              title: '現在地',
            ),
          ),
        );
      });

      // 現在地にカメラを移動
      await mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          const CameraPosition(
            target: LatLng(latitude, longitude),
            zoom: 16.0,
          ),
        ),
      );
    }
  }

  //   Future countOniAndNonOniPlayers(int? roomId) async {
  //   DatabaseReference playersRef =
  //       FirebaseDatabase.instance.ref('games/$roomId/players');
  //   final snapshot = await playersRef.once();
  //   int oniCount = 0;
  //   int nonOniCount = 0;
  //   if (snapshot.snapshot.exists) {
  //     Map<dynamic, dynamic> playersData =
  //         snapshot.snapshot.value as Map<dynamic, dynamic>;
  //     for (var playerData in playersData.values) {
  //       if (playerData['oni'] == true) {
  //         oniCount++;
  //       } else {
  //         nonOniCount++;
  //       }
  //     }
  //   }
  //   print({'oni': oniCount, 'nonOni': nonOniCount});

  //   setState(() {
  //     countOni = oniCount;
  //     countNonOni = nonOniCount;
  //   });
  // }

  Future<void> _signOut() async {
    setIsLoading(true);
    await Future.delayed(const Duration(seconds: 1), () {});
    await FirebaseAuth.instance.signOut();
    setIsLoading(false);
  }
}


  // Future<void> _requestPermission() async {
  //   // 位置情報の許可を求める
  //   LocationPermission permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     await Geolocator.requestPermission();
  //   }
  // }

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