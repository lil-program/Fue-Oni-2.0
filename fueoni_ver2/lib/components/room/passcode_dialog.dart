import 'package:flutter/material.dart';

Widget foundDisplay(Map<String, dynamic> gameInfo) {
  String gameInfoText = _formatGameInfo(gameInfo);
  return Column(
    children: <Widget>[
      ListTile(
        title: const Text('ゲーム情報'),
        subtitle: Text(gameInfoText),
      ),
    ],
  );
}

Widget passcodeSettingDisplay({
  required String passcode,
  required String hintText,
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
      Text(passcode.isNotEmpty ? '' : hintText),
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

String _formatGameInfo(Map<String, dynamic> info) {
  String ownerName = info['owner']['name'] ?? '未知';
  int timeLimit = info['settings']['timeLimit'] ?? 0;
  int participantCount = info['settings']['participantCount'] ?? 0;
  int initialOniCount = info['settings']['initialOniCount'] ?? 0;

  return 'オーナー: $ownerName\n'
      '時間制限: $timeLimit分\n'
      '参加者数: $participantCount\n'
      '初期鬼の数: $initialOniCount';
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
