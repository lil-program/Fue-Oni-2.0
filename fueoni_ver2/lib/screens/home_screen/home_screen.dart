import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fueoni_ver2/screens/home_screen/tabs/profile_settings/account_settings.dart';
import 'package:fueoni_ver2/screens/home_screen/tabs/room_settings/room_settings.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  StreamSubscription<User?>? _authSubscription;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildSelectedScreen(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _authSubscription =
        FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/startup', (route) => false);
      }
    });
  }

  NavigationBar _buildBottomNavigationBar() {
    return NavigationBar(
      selectedIndex: _selectedIndex,
      onDestinationSelected: (int index) {
        setState(() {
          _selectedIndex = index;
        });
        _navigateToSelectedScreen(index);
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

  Widget _buildSelectedScreen() {
    // 現在の選択に基づいて表示する画面を返します
    switch (_selectedIndex) {
      case 0:
        return const RoomSettingsScreen();
      case 1:
        return const AccountSettingsScreen();
      default:
        return const RoomSettingsScreen(); // デフォルトの画面
    }
  }

  void _navigateToSelectedScreen(int index) {
    // 名前付きルートに基づいてナビゲートします
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/home/room_settings');
        break;
      case 1:
        Navigator.pushNamed(context, '/home/account_settings');
        break;
      // 他のインデックスに対するケースを追加
    }
  }
}
