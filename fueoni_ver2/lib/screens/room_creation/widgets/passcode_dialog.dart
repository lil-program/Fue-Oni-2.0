import 'package:flutter/material.dart';

Future<String?> showPasscodeDialog({
  required BuildContext context,
  String passcode = '',
}) {
  return showDialog<String>(
    context: context,
    builder: (BuildContext context) => PasscodeDialog(passcode: passcode),
  );
}

class PasscodeDialog extends StatefulWidget {
  final String passcode;

  const PasscodeDialog({Key? key, this.passcode = ''}) : super(key: key);

  @override
  _PasscodeDialogState createState() => _PasscodeDialogState();
}

class PasscodeDisplay extends StatelessWidget {
  final String passcode;

  const PasscodeDisplay({super.key, required this.passcode});

  @override
  Widget build(BuildContext context) {
    return Text(passcode.isNotEmpty ? '設定済み: $passcode' : 'パスコードを設定してください');
  }
}

class _PasscodeDialogState extends State<PasscodeDialog> {
  final _passcodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('パスコード'),
      content: TextField(
        controller: _passcodeController,
        decoration: const InputDecoration(labelText: 'パスコードを入力してください'),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('キャンセル'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          child: const Text('OK'),
          onPressed: () {
            Navigator.pop<String>(context, _passcodeController.text);
          },
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _passcodeController.text = widget.passcode;
  }
}
