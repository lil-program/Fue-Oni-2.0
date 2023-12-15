import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationPermissionCheck extends StatefulWidget {
  final Widget child;

  const LocationPermissionCheck({super.key, required this.child});

  @override
  LocationPermissionCheckState createState() => LocationPermissionCheckState();
}

class LocationPermissionCheckState extends State<LocationPermissionCheck>
    with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkLocationPermission();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/');
      });
    }
  }
}
