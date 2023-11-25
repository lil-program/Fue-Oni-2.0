import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fueoni_ver2/screens/home_screen/tabs/profile_settings/account_settings.dart';
import 'package:fueoni_ver2/screens/home_screen/tabs/room_settings/room_settings.dart';
import 'package:fueoni_ver2/screens/startup_screen/startup_screen.dart';

class Destination {
  final int index;
  final String title;
  final IconData icon;
  const Destination(this.index, this.title, this.icon);
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const List<Destination> allDestinations = <Destination>[
    Destination(0, 'プレイ', Icons.gamepad),
    Destination(1, '設定', Icons.settings),
  ];

  StreamSubscription<User?>? _authSubscription;
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _selectedIndex == 0
            ? const RoomSettingsScreen()
            : const AccountSettingsScreen(),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: allDestinations.map((Destination destination) {
          return NavigationDestination(
            icon: Icon(destination.icon),
            label: destination.title,
          );
        }).toList(),
      ),
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
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const StartupScreen()),
          (route) => false,
        );
      }
    });
  }
}
