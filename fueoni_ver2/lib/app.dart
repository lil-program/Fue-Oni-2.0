import 'package:flutter/material.dart';
import 'package:fueoni_ver2/color_schemes.dart';
import 'package:fueoni_ver2/models/arguments.dart';
import 'package:fueoni_ver2/routes/slide_left_route.dart';
import 'package:fueoni_ver2/routes/slide_right_route.dart';
import 'package:fueoni_ver2/screens/home_screen/home_screen.dart';
import 'package:fueoni_ver2/screens/home_screen/tabs/profile_settings/account_settings_screen.dart';
import 'package:fueoni_ver2/screens/home_screen/tabs/room_settings/room_settings.dart';
import 'package:fueoni_ver2/screens/map_screen/oni_map_screen.dart';
import 'package:fueoni_ver2/screens/map_screen/runner_map_screen.dart';
import 'package:fueoni_ver2/screens/result_screen/result_screen.dart';
import 'package:fueoni_ver2/screens/room_creation_screen/room_creation_screen.dart';
import 'package:fueoni_ver2/screens/room_creation_screen/room_creation_settings_screen.dart';
import 'package:fueoni_ver2/screens/room_creation_screen/room_creation_waiting_screen.dart';
import 'package:fueoni_ver2/screens/room_loading_screen/room_loading_screen.dart';
import 'package:fueoni_ver2/screens/room_search_screen/room_search_screen.dart';
import 'package:fueoni_ver2/screens/room_search_screen/room_search_waiting_screen.dart';
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
          //'/home': (BuildContext context) => const HomeScreen(),
          '/result': (BuildContext context) => ResultScreen(),
          '/map/oni': (BuildContext context) => const OniMapScreen(),
          '/map/runner': (BuildContext context) => const RunnerMapScreen(),
          '/home/account_settings': (BuildContext context) =>
              const AccountSettingsScreen(),
          '/home/room_settings': (BuildContext context) =>
              const RoomSettingsScreen(),
          '/home/room_settings/create_room': (BuildContext context) =>
              const CreateRoomScreen(),
          //'/home/room_settings/create_room/room_creation_waiting':
          //    (BuildContext context) => const RoomCreationWaitingScreen(),
          '/home/room_settings/create_room/room_creation_settings':
              (BuildContext context) => const RoomCreationSettingsScreen(),
          '/home/room_settings/search_room': (BuildContext context) =>
              const RoomSearchPage(),
          '/home/room_settings/search_room/room_search_waiting':
              (BuildContext context) => const RoomSearchWaitingScreen(),
          /*
          '/home/room_settings/loading_room': (BuildContext context) =>
              const RoomLoadingScreen(),
              */
          '/home/room_settings/loading_room': (BuildContext context) {
            final RoomArguments args =
                ModalRoute.of(context)!.settings.arguments as RoomArguments;
            return RoomLoadingScreen(roomArguments: args);
          },
        },
        theme: ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
        darkTheme: ThemeData(useMaterial3: true, colorScheme: darkColorScheme),
        onGenerateRoute: (RouteSettings settings) {
          if (settings.name == '/home') {
            bool useAnimation = settings.arguments as bool? ?? false;
            if (useAnimation) {
              return SlideRightRoute(newScreen: const HomeScreen());
            } else {
              return MaterialPageRoute(
                  builder: (context) => const HomeScreen());
            }
          }
          if (settings.name ==
              '/home/room_settings/create_room/room_creation_waiting') {
            final RoomArguments args = settings.arguments as RoomArguments;

            return SlideLeftRoute(
                newScreen: RoomCreationWaitingScreen(roomArguments: args));
          }
          return null;
        });
  }
}
