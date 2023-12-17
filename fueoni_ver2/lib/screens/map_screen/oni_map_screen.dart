import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fueoni_ver2/components/locate_permission_check.dart';
import 'package:fueoni_ver2/screens/map_screen/oni_timer_map.dart';
import 'package:fueoni_ver2/services/room_creation/oni_assignment_service.dart';
import 'package:fueoni_ver2/services/room_management/game_service.dart';
import 'package:fueoni_ver2/services/room_management/location_service.dart';
import 'package:fueoni_ver2/services/room_management/player_service.dart';
import 'package:fueoni_ver2/services/room_search/game_monitor_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

String? scannaData;

class OniMapGameScreen extends StatefulWidget {
  final int? roomId;

  const OniMapGameScreen({
    Key? key,
    required this.roomId,
  }) : super(key: key);

  @override
  State<OniMapGameScreen> createState() => _OniMapGameScreenState();
}

class OniMapScreen extends StatefulWidget {
  final int? roomId;

  const OniMapScreen({
    Key? key,
    required this.roomId,
  }) : super(key: key);

  @override
  State<OniMapScreen> createState() => _OniMapScreenState();
}

class QRViewExample extends StatefulWidget {
  final int? roomId; // roomIdを追加

  const QRViewExample({super.key, required this.roomId});

  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _OniMapGameScreenState extends State<OniMapGameScreen> {
  String? baseOniPlayerId;
  GoogleMapController? mapController;
  late StreamSubscription<Position> positionStreamSubscription;
  Set<Marker> markers = {};

  LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high, // 高精度の位置情報
    distanceFilter: 10, // 最小の距離変化（メートル）
  );

  Duration? mainTimerDuration; // 残り時間のタイマー
  //Duration oniTimerDuration = const Duration(seconds: 2); // 鬼タイマー
  Duration oniTimerDuration = const Duration(seconds: 10); // 鬼タイマー
  Timer? mainTimer;
  Timer? oniTimer;

  int? roomId;

  bool isSignedIn = false;

  bool isLoading = false;

  bool _mapIsLoading = true;

  int countOni = 0;
  int countNonOni = 0;

  final CameraPosition initialCameraPosition = const CameraPosition(
    target: LatLng(33.570734171832, 130.24635431587),
    zoom: 16.0,
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
                '残り時間${_formatDuration(mainTimerDuration ?? const Duration(seconds: 0))}',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: initialCameraPosition,
            onMapCreated: (GoogleMapController controller) async {
              mapController = controller;
              await _moveToCurrentLocation();
              await _watchPosition();
              if (mounted) {
                setState(() {
                  _mapIsLoading = false;
                });
              }
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
      ),
      floatingActionButton: Stack(
        children: <Widget>[
          Positioned(
            left: 0.0,
            bottom: 50,
            child: FloatingActionButton(
              heroTag: "uniqueTag1",
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
            child: Align(
              alignment: const Alignment(-0.15, -0.6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0),
                    bottomLeft: Radius.circular(20.0),
                    bottomRight: Radius.circular(20.0),
                  ),
                  boxShadow: const [
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
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 30,
            bottom: 50.0,
            child: FloatingActionButton(
              heroTag: "uniqueTag2",
              onPressed: () async {
                var scannedData = await Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => QRViewExample(
                            roomId: roomId,
                          )),
                );

                if (scannedData != null) {
                  // スキャンされたデータに基づいて何かの処理を行う
                  print(scannedData); // 例: コンソールにスキャンされたデータを表示
                }
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
    ));
  }

  @override
  void dispose() {
    mainTimer?.cancel();
    oniTimer?.cancel();
    mapController?.dispose();
    positionStreamSubscription.cancel();
    super.dispose();
  }

  void initializeOniPlayers() async {
    Map<String, bool> oniPlayers = await PlayerService().getOniPlayers(roomId);

    // oniPlayersをIDに基づいてソート
    var sortedOniPlayers = oniPlayers.keys.toList()..sort();
    if (sortedOniPlayers.isNotEmpty) {
      // 最初のプレイヤーを基準の鬼として保存
      setState(() {
        baseOniPlayerId = sortedOniPlayers.first;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _watchPosition();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      roomId = widget.roomId;

      final gameTimeLimit = await OniAssignmentService().getTimeLimit(roomId);
      final nononiCount = await OniAssignmentService().getPlayersList(roomId);

      GameMonitorService().monitorOniPlayers(roomId, (oniPlayers) async {
        countOni = oniPlayers.length;
        countNonOni = nononiCount.length - countOni;
      });

      if (mounted) {
        setState(() {
          mainTimerDuration = gameTimeLimit;
          oniTimerDuration = const Duration(minutes: 1);
        });
      }

      // mainTimerDurationが設定された後でタイマーを起動します
      startMainTimer(); // 主タイマーを起動します。
      startOniTimer(); // 鬼タイマーを起動します。
      initializeOniPlayers();
    });
  }

  Future<void> navigateToRunnerLocationScreen() async {
    List<LatLng> nonOniPlayerLocations =
        await LocationService().getNonOniPlayerLocations(roomId);

    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              RunnerLocationScreen(locations: nonOniPlayerLocations)),
    );

    oniTimerDuration = const Duration(minutes: 1);
    startOniTimer();
  }

  void setIsLoading(bool value) {
    setState(() {
      isLoading = value;
    });
  }

  void startMainTimer() {
    mainTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (mainTimerDuration == null || mainTimerDuration!.inSeconds <= 0) {
            timer.cancel();
            // Navigator.pushReplacement(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => ResultScreen(),
            //   ),
            // );
            // gameStartをfalseにする
            FirebaseDatabase.instance
                .ref()
                .child('games')
                .child(roomId.toString())
                .child('settings')
                .child('gameStart')
                .set(false);
          } else {
            mainTimerDuration = mainTimerDuration! - const Duration(seconds: 1);
          }
        });
      } else {
        timer.cancel();
      }
    });
  }

  /*
  void navigateToRunnerLocationScreen() async {
    List<LatLng> nonOniPlayerLocations =
        await LocationService().getNonOniPlayerLocations(roomId);

    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              RunnerLocationScreen(locations: nonOniPlayerLocations)),
    ).then((_) {
      oniTimerDuration = const Duration(minutes: 1);
      startOniTimer();
    });
  }
  */

  void startOniTimer() {
    oniTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (oniTimerDuration.inSeconds <= 0) {
        timer.cancel();

        if (FirebaseAuth.instance.currentUser?.uid == baseOniPlayerId) {
          await GameService().setOniScanStart(roomId, true);
        }

        await navigateToRunnerLocationScreen();

        setState(() {
          oniTimerDuration = const Duration(minutes: 1);
        });
        startOniTimer();
      } else {
        setState(() {
          oniTimerDuration = oniTimerDuration - const Duration(seconds: 1);
        });
      }
    });
  }

/*
  void startOniTimer() {
    oniTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (oniTimerDuration.inSeconds <= 0) {
            timer.cancel();

            if (FirebaseAuth.instance.currentUser?.uid == baseOniPlayerId) {
              GameService().setOniScanStart(roomId, true);
            }

            navigateToRunnerLocationScreen();
          } else {
            oniTimerDuration = oniTimerDuration - const Duration(seconds: 1);
          }
        });
      } else {
        timer.cancel();
      }
    });
  }
  */

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');

    // 全体の分数を取得
    String minutes = twoDigits(duration.inMinutes);
    // 分を超える秒数を取得
    String seconds = twoDigits(duration.inSeconds.remainder(60));

    return "$minutes:$seconds";
  }

  Future<void> _moveToCurrentLocation() async {
    // 現在地を取得
    final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      // 現在地マーカーを削除
      markers.removeWhere(
          (Marker marker) => marker.markerId.value == 'current_location');

      // 現在地マーカーを追加
      markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: LatLng(position.latitude, position.longitude),
          infoWindow: const InfoWindow(title: '現在地'),
        ),
      );
    });

    // 現在地にカメラを移動
    await mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 16.0,
        ),
      ),
    );
  }

  Future<void> _watchPosition() async {
    positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) async {
      if (mounted && mapController != null) {
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
        await mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 16.0,
            ),
          ),
        );
      }
    });
  }
}

class _OniMapScreenState extends State<OniMapScreen> {
  bool gameStart = true;
  List rankings = [];

  StreamSubscription? gameStartSubscription;
  StreamSubscription? rankingsSubscription;

  @override
  Widget build(BuildContext context) {
    if (!gameStart) {
      Future.delayed(Duration.zero, () {
        Navigator.pushNamed(context, '/result',
            arguments: {'rankings': rankings, 'roomId': widget.roomId});
      });
    }

    return gameStart
        ? OniMapGameScreen(
            roomId: widget.roomId,
          )
        : Container();
  }

  @override
  void dispose() {
    gameStartSubscription?.cancel();
    rankingsSubscription?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final gameStartRef = FirebaseDatabase.instance
          .ref()
          .child('games')
          .child(widget.roomId.toString())
          .child('settings')
          .child('gameStart');

      gameStartSubscription = gameStartRef.onValue.listen((event) {
        setState(() {
          gameStart = event.snapshot.value as bool? ?? true;
        });
      });

      final rankingsRef = FirebaseDatabase.instance
          .ref()
          .child('games')
          .child(widget.roomId.toString())
          .child('rankings');

      rankingsSubscription = rankingsRef.onValue.listen((event) {
        setState(() {
          rankings = (event.snapshot.value as List? ?? [])
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        });
      });
    });
  }
}

class _QRViewExampleState extends State<QRViewExample> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QRコードスキャン'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isIOS) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      setState(() {
        scannaData = scanData.code;
      });
      // スキャンされたQRコードデータを処理
      await OniAssignmentService()
          .setOni(widget.roomId, scannaData); // widgetを使用してroomIdにアクセス
      if (mounted) {
        Navigator.pop(context, scannaData);
      }
      controller.dispose();
    });
  }
}
