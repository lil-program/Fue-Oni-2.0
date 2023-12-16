import 'package:flutter/material.dart';
import 'package:fueoni_ver2/components/locate_permission_check.dart';

class RoomSettingsScreen extends StatelessWidget {
  const RoomSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LocationPermissionCheck(
        child: Scaffold(
      appBar: AppBar(
        title: const Text('ルーム設定'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Card(
              child: InkWell(
                onTap: () => Navigator.pushNamed(
                    context, '/home/room_settings/create_room'),
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
                onTap: () => Navigator.pushNamed(
                    context, '/home/room_settings/search_room'),
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
    ));
  }
}
