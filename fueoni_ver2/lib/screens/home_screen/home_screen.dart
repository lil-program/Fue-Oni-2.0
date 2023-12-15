import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fueoni_ver2/hooks/use_location.dart';
import 'package:fueoni_ver2/screens/home_screen/tabs/profile_settings/account_settings_screen.dart';
import 'package:fueoni_ver2/screens/home_screen/tabs/room_settings/room_settings.dart';

class HomeScreen extends HookWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    useLocationPermissionCheck(context);
    final selectedIndex = useState(0);
    final authSubscription = useState<StreamSubscription<User?>?>(null);

    useEffect(() {
      authSubscription.value =
          FirebaseAuth.instance.authStateChanges().listen((User? user) {
        if (user == null) {
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        }
      });
      return () {
        authSubscription.value?.cancel();
      };
    }, const []);

    return Scaffold(
      body: _buildSelectedScreen(selectedIndex.value),
      bottomNavigationBar: _buildBottomNavigationBar(selectedIndex),
    );
  }

  NavigationBar _buildBottomNavigationBar(ValueNotifier<int> selectedIndex) {
    return NavigationBar(
      selectedIndex: selectedIndex.value,
      onDestinationSelected: (int index) {
        selectedIndex.value = index;
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.gamepad),
          label: 'プレイ',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings),
          label: '設定',
        ),
      ],
    );
  }

  Widget _buildSelectedScreen(int selectedIndex) {
    // 現在の選択に基づいて表示する画面を返します
    switch (selectedIndex) {
      case 0:
        return const RoomSettingsScreen();
      case 1:
        return const AccountSettingsScreen();
      default:
        return const RoomSettingsScreen(); // デフォルトの画面
    }
  }
}
