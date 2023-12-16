import 'package:flutter/material.dart';

class SearchRoomScreen extends StatelessWidget {
  const SearchRoomScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ルーム検索'),
      ),
      body: const Center(
        child: Text('ここにルーム検索の内容を追加します'),
      ),
    );
  }
}