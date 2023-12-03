import 'package:flutter/material.dart';

class OniDisplay extends StatelessWidget {
  final int oniCount;

  OniDisplay({required this.oniCount});

  @override
  Widget build(BuildContext context) {
    return Text('鬼の数: $oniCount');
  }
}
