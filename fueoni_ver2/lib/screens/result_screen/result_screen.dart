import 'package:fueoni_ver2/screens/map_screen/oni_map_screen.dart';
import 'package:fueoni_ver2/screens/map_screen/runner_map_screen.dart';
import 'package:flutter/material.dart';
import 'package:fueoni_ver2/screens/startup_screen/startup_screen.dart';


class ResultScreen extends StatelessWidget {

  final List<String> playerNames = ["kazuki","daiki","hyuuga","ou"]; // プレイヤー名のリスト
  ResultScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('結果'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: playerNames.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('${index + 1}位: ${playerNames[index]}'),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // ボタンの処理（例: ホーム画面に戻る）
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StartupScreen(),
                  ),
                );
              },
              child: Text('continue'),
            ),
          ],
        ),
      ),
    );
  }
}
