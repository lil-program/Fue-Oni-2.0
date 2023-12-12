import 'package:flutter/material.dart';
import 'package:fueoni_ver2/components/room/passcode_dialog.dart';

typedef DialogCallback = Future<void> Function();

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

  static Widget passcodeDialogCard({
    required BuildContext context,
    required String passcode,
    required Widget Function(String passcode) displayWidgetFactory,
    required Function(String) onSelected,
  }) {
    return settingDialogCard(
      context: context,
      showDialogCallback: () async {
        final String? result =
            await showPasscodeDialog(context: context, passcode: passcode);
        if (result != null && result.isNotEmpty) {
          onSelected(result);
        }
      },
      displayWidget: displayWidgetFactory(passcode),
    );
  }

  static AppBar roomAppbar({
    required BuildContext context,
    required int? roomId,
    required String title,
    required Function(int?) onBackButtonPressed,
  }) {
    return AppBar(
      title: Text(title),
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => onBackButtonPressed(roomId),
      ),
    );
  }

  static Widget settingDialogCard({
    required BuildContext context,
    required DialogCallback showDialogCallback,
    required Widget displayWidget,
  }) {
    return GestureDetector(
      onTap: () async {
        await showDialogCallback();
      },
      child: Card(
        child: Column(children: [
          displayWidget,
        ]),
      ),
    );
  }

  static Widget userList(List<String> users) {
    return Expanded(
      child: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              title: Text(users[index]),
              leading: const Icon(Icons.person),
            ),
          );
        },
      ),
    );
  }
}
