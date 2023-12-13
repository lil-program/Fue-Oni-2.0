import 'package:flutter/material.dart';
import 'package:fueoni_ver2/components/room/passcode_dialog.dart';

typedef DialogCallback = Future<void> Function();

class CustomIcons {
  static const _kFontFam = 'CustomIcons';
  static const String? _kFontPkg = null;

  static const IconData oni =
      IconData(0xea43, fontFamily: _kFontFam, fontPackage: _kFontPkg);
}

class RoomWidgets {
  static Widget displayRoomId({
    required BuildContext context,
    required int? roomId,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withAlpha(200),
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: SelectableText(
        'ルームID: ${roomId?.toString() ?? '生成中...'}',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
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
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.all(16.0),
      color: colorScheme.surface,
      elevation: 8.0, // カードの影の高さ
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: InkWell(
        onTap: () async {
          await showDialogCallback();
        },
        borderRadius: BorderRadius.circular(8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(children: [
            displayWidget,
          ]),
        ),
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
