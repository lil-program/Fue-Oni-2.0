import 'package:flutter/material.dart';
import 'package:fueoni_ver2/components/locate_permission_check.dart';
import 'package:fueoni_ver2/screens/startup_screen/startup_screen.dart';
import 'package:fueoni_ver2/services/room_creation/oni_assignment_service.dart';

class ResultScreen extends StatefulWidget {
  final List<Map<String, dynamic>> rankings; // ランキング情報のリストを引数として受け取る
  final int? roomId; // ルームIDを引数として受け取る

  const ResultScreen({Key? key, required this.rankings, required this.roomId})
      : super(key: key);

  @override
  ResultScreenState createState() => ResultScreenState();
}

class ResultScreenState extends State<ResultScreen> {
  late Future<int> initialOniCountFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: initialOniCountFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        final initialOniCount = snapshot.data ?? 0;

        // 逃走者と鬼に分ける
        final escapedPlayers =
            widget.rankings.where((player) => !player['isOni']).toList();
        final oniPlayers =
            widget.rankings.where((player) => player['isOni']).toList();

        return LocationPermissionCheck(
          child: Scaffold(
            appBar: AppBar(
              title: const Text('結果'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  if (escapedPlayers.isNotEmpty) ...[
                    const Text('完全逃走者！！'),
                    ...escapedPlayers.map(
                      (player) => Row(
                        children: [
                          if (player["rank"] == 1)
                            const Icon(Icons.star, color: Colors.yellow),
                          Text('${player["rank"]}位: ${player["name"]}'),
                        ],
                      ),
                    ),
                  ],
                  if (oniPlayers.isNotEmpty) ...[
                    const Text('捕まったひと！'),
                    ...oniPlayers.map(
                      (player) => Row(
                        children: [
                          if (player["rank"] == 1)
                            const Icon(Icons.star, color: Colors.yellow),
                          Text(
                              '${player["rank"]}位: ${player["name"]}${player["rank"] > widget.rankings.length - initialOniCount ? ' (最初の鬼)' : ''}'),
                        ],
                      ),
                    ),
                  ],
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
      },
    );
  }

  @override
  void initState() {
    super.initState();
    initialOniCountFuture =
        OniAssignmentService().getInitialOniCount(widget.roomId);
  }
}
