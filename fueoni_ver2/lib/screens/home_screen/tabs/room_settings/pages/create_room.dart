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

/*
  Future<void> initMapScreen() async {
    // 位置情報の許可をリクエストする
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }

    // FirebaseAuthの現在のユーザーを取得（必要に応じて）
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // ユーザーがログインしていない場合の処理（必要に応じて）
    }

    // 他に必要な初期化処理があればここに記述
  }
  */
}
