import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class RankingsScreen extends StatelessWidget {
  final List rankings;

  const RankingsScreen({Key? key, required this.rankings}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rankings'),
      ),
      body: ListView.builder(
        itemCount: rankings.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Player: ${rankings[index]['player']}'),
            subtitle: Text('Rank: ${rankings[index]['rank']}'),
          );
        },
      ),
    );
  }
}

class TestScreen extends HookWidget {
  final String roomId;

  const TestScreen({Key? key, required this.roomId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gameStart = useState<bool>(true);
    final rankings = useState<List>([]);

    useEffect(() {
      final gameStartRef = FirebaseDatabase.instance
          .ref()
          .child('games')
          .child(roomId)
          .child('settings')
          .child('gameStart');

      final rankingsRef = FirebaseDatabase.instance
          .ref()
          .child('games')
          .child(roomId)
          .child('rankings');

      final gameStartSubscription = gameStartRef.onValue.listen((event) {
        gameStart.value = event.snapshot.value as bool;
      });

      final rankingsSubscription = rankingsRef.onValue.listen((event) {
        rankings.value = event.snapshot.value as List? ?? [];
      });

      return () {
        gameStartSubscription.cancel();
        rankingsSubscription.cancel();
      };
    }, []);

    return gameStart.value
        ? Scaffold(
            appBar: AppBar(
              title: const Text('Test Screen'),
            ),
            body: const Center(
              child: Text('Waiting for game to start...'),
            ),
          )
        : RankingsScreen(rankings: rankings.value);
  }
}
