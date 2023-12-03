import 'package:flutter/material.dart';

class PasscodeDialog extends StatefulWidget {
  final String passcode;

  PasscodeDialog({Key? key, this.passcode = ''}) : super(key: key);

  @override
  _PasscodeDialogState createState() => _PasscodeDialogState();
}

class _PasscodeDialogState extends State<PasscodeDialog> {
  final _passcodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _passcodeController.text = widget.passcode;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('パスコード設定'),
      content: TextField(
        controller: _passcodeController,
        decoration: InputDecoration(labelText: 'パスコードを入力してください'),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('キャンセル'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          child: Text('設定'),
          onPressed: () {
            Navigator.pop<String>(context, _passcodeController.text);
          },
        ),
      ],
    );
  }
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
