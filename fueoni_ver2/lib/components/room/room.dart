import 'package:flutter/material.dart';

class RoomWidgets {
  static Widget displayRoomId({
    required int? roomId,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        'ルームID: ${roomId ?? '生成中...'}',
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  static AppBar roomAppbar({
    required BuildContext context,
    required int? roomId,
    required Widget? backButton,
    required String title,
  }) {
    return AppBar(
      title: Text(title),
      automaticallyImplyLeading: false,
      leading: backButton,
    );
  }
}
