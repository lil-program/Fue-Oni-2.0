import 'package:flutter/material.dart';

void showErrorDialog(context, String message) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('エラー'),
      content: Text(message),
      actions: <Widget>[
        TextButton(
          child: const Text('OK'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    ),
  );
}
