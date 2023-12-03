import 'package:flutter/material.dart';

class TimerDisplay extends StatelessWidget {
  final Duration duration;

  TimerDisplay({required this.duration});

  @override
  Widget build(BuildContext context) {
    String hours = duration.inHours.toString().padLeft(2, '0');
    String minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    String seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');

    return Text('$hours:$minutes:$seconds');
  }
}
