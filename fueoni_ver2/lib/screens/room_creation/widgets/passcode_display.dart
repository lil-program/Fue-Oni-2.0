import 'package:flutter/material.dart';

class PasscodeDisplay extends StatelessWidget {
  final String passcode;

  const PasscodeDisplay({super.key, required this.passcode});

  @override
  Widget build(BuildContext context) {
    return Text(passcode.isNotEmpty ? '設定済み: $passcode' : 'パスコードを設定してください');
  }
}
