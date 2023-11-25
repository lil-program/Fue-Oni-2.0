import 'package:flutter/material.dart';
import 'package:fueoni_ver2/screens/home_screen/tabs/room_settings/pages/create_room.dart';
import 'package:fueoni_ver2/screens/home_screen/tabs/room_settings/pages/search_room.dart';

class RoomSettingsScreen extends StatelessWidget {
  const RoomSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ルーム設定'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Card(
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CreateRoomPage()),
                  );
                },
                child: const SizedBox(
                  width: 300,
                  height: 100,
                  child: Center(child: Text('ルーム作成')),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SearchRoomPage()),
                  );
                },
                child: const SizedBox(
                  width: 300,
                  height: 100,
                  child: Center(child: Text('ルーム検索')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
