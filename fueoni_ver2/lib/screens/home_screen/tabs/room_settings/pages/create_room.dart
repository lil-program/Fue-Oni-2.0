import 'package:flutter/material.dart';
import 'package:fueoni_ver2/screens/map_screen/map_screen.dart';

class CreateRoomPage extends StatefulWidget {
  const CreateRoomPage({Key? key}) : super(key: key);

  @override
  CreateRoomPageState createState() => CreateRoomPageState();
}

class CreateRoomPageState extends State<CreateRoomPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ルーム作成'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await initMapScreen();
            if (!mounted) return; // ここでmountedをチェック
            Navigator.pushReplacementNamed(context, '/map');
          },
          child: const Text('マップを開く'),
        ),
      ),
    );
  }
}
