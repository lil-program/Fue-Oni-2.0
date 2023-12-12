import 'package:flutter/material.dart';

Widget passcodeDisplay({
  required String passcode,
  String title = 'パスコード設定',
  IconData icon = Icons.vpn_key,
}) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon),
      const SizedBox(width: 8),
      Text(title),
      const SizedBox(width: 8),
      Text(passcode.isNotEmpty ? '' : 'パスコードを設定してください'),
    ],
  );
}

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
  PasscodeDialogState createState() => PasscodeDialogState();
}

class PasscodeDialogState extends State<PasscodeDialog> {
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
