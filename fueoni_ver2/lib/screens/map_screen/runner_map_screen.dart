import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fueoni_ver2/models/arguments.dart';
import 'package:fueoni_ver2/services/room_creation/oni_assignment_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';

Future<void> initRunnerMapScreen() async {
  await Future.delayed(const Duration(seconds: 2));
}

class RunnerMapScreen extends StatefulWidget {
  const RunnerMapScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<RunnerMapScreen> createState() => _RunnerMapScreenState();
}

class _RunnerMapScreenState extends State<RunnerMapScreen> {
  //初期値
  late GoogleMapController mapController;
  late StreamSubscription<Position> positionStreamSubscription;
  Set<Marker> markers = {};
  late StreamSubscription<User?> authUserStream;

  LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high, // 高精度の位置情報
    distanceFilter: 10, // 最小の距離変化（メートル）
  );

  Timer? oniTimer;

  int? roomId;

  bool isSignedIn = false;

  bool isLoading = false;

  bool _mapIsLoading = true;

  int countOni = 0;
  int countNonOni = 0;

  Duration mainTimerDuration = const Duration(minutes: 100); // 残り時間のタイマー
  Duration oniTimerDuration = const Duration(minutes: 2);
  Timer? mainTimer;

  final CameraPosition initialCameraPosition = const CameraPosition(
    target: LatLng(33.570734171832, 130.24635431587),
    zoom: 16.0,
  );

  //画面のビルド
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildMap(),
      floatingActionButton: _buildFloatingActionButtons(),
    );
  }

  void startMainTimer() {
    mainTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (mainTimerDuration.inSeconds <= 0) {
          timer.cancel();

          Navigator.pushReplacementNamed(context, '/result');
        } else {
          mainTimerDuration = mainTimerDuration - const Duration(seconds: 1);
        }
      });
    });
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
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
    );
  }

  Widget _buildFloatingActionButtons() {
    // 画面サイズを取得
    Size screenSize = MediaQuery.of(context).size;

    // 画面高さの10%
    double bottomPosition = screenSize.height * 0.1;

    return Stack(
      children: <Widget>[
        // 現在地へ移動するボタン
        Positioned(
          left: 30,
          bottom: bottomPosition,
          child: FloatingActionButton(
            heroTag: "btn1",
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
        // QRコードスキャナーボタン
        Positioned(
          right: 30,
          bottom: bottomPosition,
          child: FloatingActionButton(
            heroTag: "btn2",
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return Dialog(
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
        // 鬼の残り人数を表示
        Positioned(
          right: 30,
          bottom: 10,
          child: _buildPlayerCountContainer('鬼残り$countOni人'),
        ),
        // 逃走者の残り人数を表示
        Positioned(
          left: 30,
          bottom: 10,
          child: _buildPlayerCountContainer('逃走者残り$countNonOni人'),
        ),
      ],
    );
  }

  Widget _buildMap() {
    return FutureBuilder<LatLng>(
      future: _getCurrentLocation(),
      builder: (BuildContext context, AsyncSnapshot<LatLng> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // ローディングインジケータを表示
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          // エラーメッセージを表示
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          // 現在地のマーカーを更新
          final currentLocationMarker = Marker(
            markerId: const MarkerId('current_location'),
            position: snapshot.data!,
            infoWindow: const InfoWindow(title: '現在地'),
          );

          return GoogleMap(
            initialCameraPosition: CameraPosition(
              target: snapshot.data!,
              zoom: 16.0,
            ),
            onMapCreated: (GoogleMapController controller) async {
              mapController = controller;
              await _moveToCurrentLocation();
              await _watchPosition();
              setState(() {
                _mapIsLoading = false;
              });
            },
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            markers: {currentLocationMarker},
          );
        }
      },
    );
  }

  Widget _buildPlayerCountContainer(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(20.0)),
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
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.white,
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');

    // 全体の分数を取得
    String minutes = twoDigits(duration.inMinutes);
    // 分を超える秒数を取得
    String seconds = twoDigits(duration.inSeconds.remainder(60));

    return "$minutes:$seconds";
  }

  Future<LatLng> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      // 現在地を取得
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      return LatLng(position.latitude, position.longitude);
    }
    throw Exception('Location permission not granted');
  }

  Future<void> _moveToCurrentLocation() async {
    try {
      // 現在地を取得
      LatLng currentLocation = await _getCurrentLocation();

      setState(() {
        // 現在地のマーカーを更新
        markers.removeWhere(
            (Marker marker) => marker.markerId.value == 'current_location');
        markers.add(
          Marker(
            markerId: const MarkerId('current_location'),
            position: currentLocation,
            infoWindow: const InfoWindow(title: '現在地'),
          ),
        );
      });

      // 現在地にカメラを移動
      await mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: currentLocation,
            zoom: 16.0,
          ),
        ),
      );
    } catch (e) {
      // エラーハンドリング
      print('Error getting current location: $e');
    }

    @override
    void initState() {
      super.initState();
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        _watchPosition();
        final args =
            ModalRoute.of(context)!.settings.arguments as RoomArguments;
        roomId = args.roomId;

        final gameTimeLimit = await OniAssignmentService().getTimeLimit(roomId);
        // final oniCount = await OniAssignmentService().getInitialOniCount(roomId);
        // print(oniCount);

        setState(() {
          mainTimerDuration = gameTimeLimit;
          oniTimerDuration = const Duration(minutes: 1);
        });
      });
      startMainTimer(); // 主タイマーを起動します。
      // countOniAndNonOniPlayers(roomId);
    }
  }

  Future<void> _watchPosition() async {
    // 現在地の変化を監視
    positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) async {
      setState(() {
        // 古い現在地のマーカーを削除
        markers.removeWhere(
            (Marker marker) => marker.markerId.value == 'current_location');

        // 新しい現在地のマーカーを追加
        markers.add(
          Marker(
            markerId: const MarkerId('current_location'),
            position: LatLng(position.latitude, position.longitude),
            infoWindow: const InfoWindow(title: '現在地'),
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

  /*
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
  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
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
            await _moveToCurrentLocation();
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
                    fontWeight: FontWeight.bold,
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

  @override
  void dispose() {
    mainTimer?.cancel();
    mapController.dispose();
    positionStreamSubscription.cancel();
    authUserStream.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
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
      startMainTimer();
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

  Future<void> _signOut() async {
    setIsLoading(true);
    await Future.delayed(const Duration(seconds: 1), () {});
    await FirebaseAuth.instance.signOut();
    setIsLoading(false);
  }
  */
}
