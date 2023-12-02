import 'package:flutter/material.dart';
import 'package:fueoni_ver2/color_schemes.dart';
import 'package:fueoni_ver2/screens/home_screen/home_screen.dart';
import 'package:fueoni_ver2/screens/home_screen/tabs/profile_settings/account_settings.dart';
import 'package:fueoni_ver2/screens/home_screen/tabs/room_settings/pages/create_room.dart';
import 'package:fueoni_ver2/screens/home_screen/tabs/room_settings/pages/search_room.dart';
import 'package:fueoni_ver2/screens/home_screen/tabs/room_settings/room_settings.dart';
import 'package:fueoni_ver2/screens/map_screen/map_screen.dart';
import 'package:fueoni_ver2/screens/startup_screen/startup_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fueoni ver2',
      initialRoute: '/',
      routes: {
        '/': (BuildContext context) => const StartupScreen(),
        '/home': (BuildContext context) => const HomeScreen(),
        '/map': (BuildContext context) => const MapScreen(),
        '/home/account_settings': (BuildContext context) =>
            const AccountSettingsScreen(),
        '/home/room_settings': (BuildContext context) =>
            const RoomSettingsScreen(),
        '/home/room_settings/create_room': (BuildContext context) =>
            const CreateRoomPage(),
        '/home/room_settings/search_room': (BuildContext context) =>
            const SearchRoomPage()
      },
      theme: ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
      darkTheme: ThemeData(useMaterial3: true, colorScheme: darkColorScheme),
    );
  }
}
