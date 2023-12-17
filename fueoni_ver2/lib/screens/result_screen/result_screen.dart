import 'package:flutter/material.dart';
import 'package:fueoni_ver2/components/locate_permission_check.dart';
import 'package:fueoni_ver2/screens/startup_screen/startup_screen.dart';

class ResultScreen extends StatelessWidget {
  final List<String> playerNames; // プレイヤー名のリストを引数として受け取る

  const ResultScreen({Key? key, required this.playerNames}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LocationPermissionCheck(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('結果'),
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
                      builder: (context) => const StartupScreen(),
                    ),
                  );
                },
                child: const Text('continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
