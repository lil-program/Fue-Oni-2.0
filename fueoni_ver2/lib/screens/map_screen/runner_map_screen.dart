import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fueoni_ver2/components/locate_permission_check.dart';
import 'package:fueoni_ver2/models/arguments.dart';
import 'package:fueoni_ver2/services/room_creation/oni_assignment_service.dart';
import 'package:fueoni_ver2/services/room_management/player_service.dart';
import 'package:fueoni_ver2/services/room_search/game_monitor_service.dart';
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
  LatLng? lastPosition;

  LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 10,
  );

  Timer? oniTimer;

  int? roomId;

  bool isSignedIn = false;

  bool isLoading = false;

  bool _mapIsLoading = true;

  int countOni = 0;
  int countNonOni = 0;

  Duration mainTimerDuration = const Duration(minutes: 100);
  Duration oniTimerDuration = const Duration(minutes: 2);
  Timer? mainTimer;

  final CameraPosition initialCameraPosition = const CameraPosition(
    target: LatLng(33.570734171832, 130.24635431587),
    zoom: 16.0,
  );

  //画面のビルド
  @override
  Widget build(BuildContext context) {
    return LocationPermissionCheck(
      child: Scaffold(
        appBar: _buildAppBar(),
        body: _buildMap(),
        floatingActionButton: _buildFloatingActionButtons(),
      ),
    );
  }

  @override
  void dispose() {
    positionStreamSubscription.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _watchPosition();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final args = ModalRoute.of(context)!.settings.arguments as RoomArguments;
      roomId = args.roomId;

      final gameTimeLimit = await OniAssignmentService().getTimeLimit(roomId);

      setState(() {
        mainTimerDuration = gameTimeLimit;
        oniTimerDuration = const Duration(minutes: 1);
      });

      startMainTimer();

      // プレイヤーが鬼になったかを監視
      GameMonitorService().monitorPlayerOniState(
          roomId, FirebaseAuth.instance.currentUser?.uid, (isOni) {
        if (isOni) {
          // プレイヤーが鬼になった場合、鬼用マップ画面に遷移
          Navigator.pushReplacementNamed(context, '/map/oni',
              arguments: RoomArguments(roomId: roomId));
        }
      });

      GameMonitorService().monitorGameStart(roomId, (gameStarted) {
        if (!gameStarted) {
          // ゲームが終了したらリザルト画面へ遷移
          // Navigator.pushReplacementNamed(context, '/result');
          print("ゲーム終了");
        }
      });
    });
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
                    child: FutureBuilder<String?>(
                      future: PlayerService().getPlayer(),
                      builder: (BuildContext context,
                          AsyncSnapshot<String?> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          // ロード中の場合、インジケータを表示
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          // エラーが発生した場合、エラーメッセージを表示
                          return Text('Error: ${snapshot.error}');
                        } else if (snapshot.hasData) {
                          // データが取得できた場合、QrImageViewを表示
                          return QrImageView(
                            padding: const EdgeInsets.only(
                                left: 60, right: 20, top: 20, bottom: 20),
                            data: snapshot.data ?? '',
                            version: QrVersions.auto,
                            size: 200.0,
                          );
                        } else {
                          // データがnullの場合、何も表示しない
                          return const Text('No data available');
                        }
                      },
                    ),
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
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: initialCameraPosition,
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
          markers: markers,
        ),
        if (_mapIsLoading)
          Container(
            color: Colors.white,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
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
  }

  Future<void> _watchPosition() async {
    // 現在地の変化を監視
    positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) async {
      setState(() {
        markers.removeWhere(
            (Marker marker) => marker.markerId.value == 'current_location');
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
}
