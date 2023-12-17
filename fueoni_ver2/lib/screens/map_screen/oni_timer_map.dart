import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// PlayerLocationScreen クラス内

class RunnerLocationScreen extends StatefulWidget {
  final List<LatLng> locations;

  const RunnerLocationScreen({Key? key, required this.locations})
      : super(key: key);

  @override
  _RunnerLocationScreenState createState() => _RunnerLocationScreenState();
}

class _RunnerLocationScreenState extends State<RunnerLocationScreen> {
  Timer? _timer;
  Duration _duration = const Duration(minutes: 2);
  List<LatLng> locations = [];

  final Set<Marker> _markers = {};

  late GoogleMapController _mapController;

  // TODO: 鬼タイマー戻るボタン戻りますかの確認

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('逃走者の場所'),
      ),
      body: Stack(
        children: <Widget>[
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: const CameraPosition(
              target: LatLng(0, 0),
              zoom: 10,
            ),
            markers: _markers,
            myLocationButtonEnabled: false,
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 0,
            child: Container(
              color: Colors.black45, // タイマーの背景色
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Text(
                  '自分のマップに戻るまであと: ${_formatDuration(_duration)}',
                  style: const TextStyle(fontSize: 20, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _startLocationTimer();
    _createMarkers(widget.locations); // ここでウィジェットのプロパティを使用
  }

  void updateCameraBounds() {
    if (locations.isEmpty) return;

    LatLngBounds bounds;
    if (locations.length == 1) {
      bounds = LatLngBounds(
        southwest: locations.first,
        northeast: locations.first,
      );
    } else {
      var southWest = LatLng(
          locations.map((loc) => loc.latitude).reduce(math.min),
          locations.map((loc) => loc.longitude).reduce(math.min));
      var northEast = LatLng(
          locations.map((loc) => loc.latitude).reduce(math.max),
          locations.map((loc) => loc.longitude).reduce(math.max));
      bounds = LatLngBounds(southwest: southWest, northeast: northEast);
    }

    CameraUpdate u2 = CameraUpdate.newLatLngBounds(bounds, 50);
    _mapController.animateCamera(u2);
  }

  void _createMarkers(List<LatLng> locations) {
    for (var location in locations) {
      _markers.add(
        Marker(
          markerId: MarkerId(location.toString()),
          position: location,
        ),
      );
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    updateCameraBounds();
  }

  void _startLocationTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_duration.inSeconds <= 0) {
          timer.cancel();
          Navigator.of(context).pop();
        } else {
          _duration = _duration - const Duration(seconds: 1);
        }
      });
    });
  }
}
