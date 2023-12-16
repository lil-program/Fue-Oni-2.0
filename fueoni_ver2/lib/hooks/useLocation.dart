import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:geolocator/geolocator.dart';

// Future<bool> checkLocationPermission() async {
//   LocationPermission permission = await Geolocator.checkPermission();
//   if (permission == LocationPermission.denied ||
//       permission == LocationPermission.deniedForever) {
//     return false;
//   }
//   return true;
// }

// void useLocationPermissionCheck(BuildContext context) {
//   useEffect(() {
//     final observer = LifecycleObserver(
//       onResume: () async {
//         bool hasPermission = await checkLocationPermission();
//         print(hasPermission);
//         if (!hasPermission) {
//           // WidgetsBinding.instance.addPostFrameCallback((_) {
//           //   Navigator.pushReplacementNamed(context, '/');
//           // });
//         }
//       },
//     );
//     WidgetsBinding.instance.addObserver(observer);
//     return () => WidgetsBinding.instance.removeObserver(observer);
//   }, const []);
// }

Future<bool> checkLocationPermission() async {
  try {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return false;
    }
    return true;
  } catch (e) {
    print('位置情報の許可のチェック中にエラーが発生しました: $e');
    return false;
  }
}

void useLocationPermissionCheck(BuildContext context) {
  useEffect(() {
    final observer = LifecycleObserver(
      onResume: () async {
        try {
          bool hasPermission = await checkLocationPermission();
          print(hasPermission);
          if (!hasPermission) {
            try {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushNamed(context, '/');
              });
            } catch (e) {
              print('リダイレクト中にエラーが発生しました: $e');
            }
          }
        } catch (e) {
          print('位置情報の許可のチェック中にエラーが発生しました: $e');
        }
      },
    );
    WidgetsBinding.instance.addObserver(observer);
    return () => WidgetsBinding.instance.removeObserver(observer);
  }, const []);
}

class LifecycleObserver extends WidgetsBindingObserver {
  final Function onResume;

  LifecycleObserver({required this.onResume});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      onResume();
    }
  }
}
