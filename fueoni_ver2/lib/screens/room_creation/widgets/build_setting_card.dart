import 'package:flutter/material.dart';

Widget buildSettingCard({
  required String title,
  required IconData icon,
  required DialogCallback showDialogCallback,
  required Widget displayWidget,
}) {
  return Card(
    child: ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: displayWidget,
      trailing: IconButton(
        icon: const Icon(Icons.edit),
        onPressed: () async {
          await showDialogCallback();
        },
      ),
    ),
  );
}

typedef DialogCallback = Future<void> Function();
