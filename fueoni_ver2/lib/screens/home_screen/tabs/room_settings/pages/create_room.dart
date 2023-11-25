import 'package:flutter/material.dart';
import 'package:fueoni_ver2/screens/map_screen/map_screen.dart';

class CreateRoomPage extends StatelessWidget {
  const CreateRoomPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ルーム作成'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => FutureBuilder<void>(
                  future: initMapScreen(), // 非同期関数を呼び出す
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator(); // データを待っている間はローディングインジケータを表示
                    } else if (snapshot.hasError) {
                      return const Text('エラーが発生しました'); // エラーが発生した場合はエラーメッセージを表示
                    } else {
                      return const MapScreen(); // データが取得できたらMapScreenを表示
                    }
                  },
                ),
              ),
            );
          },
          child: const Text('マップを開く'),
        ),
      ),
    );
  }
}
