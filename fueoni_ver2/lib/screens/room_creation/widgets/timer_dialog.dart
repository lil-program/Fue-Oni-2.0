import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<Duration?> showTimerDialog({
  required BuildContext context,
  TransitionBuilder? builder,
  bool useRootNavigator = true,
  Duration initialDuration = Duration.zero,
}) {
  final Widget dialog = _TimerDialog(initialDuration: initialDuration);
  return showCupertinoModalPopup<Duration>(
    context: context,
    useRootNavigator: useRootNavigator,
    builder: (BuildContext context) => builder?.call(context, dialog) ?? dialog,
  );
}

Widget timerDisplay({
  required Duration duration,
  String title = 'タイマー',
  IconData icon = Icons.timer,
}) {
  String hours = duration.inHours.toString().padLeft(2, '0');
  String minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
  String seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');

  return Row(
    mainAxisSize: MainAxisSize.max,
    children: [
      Icon(icon),
      const SizedBox(width: 8),
      Text(title),
      const SizedBox(width: 8),
      Text('$hours:$minutes:$seconds'),
    ],
  );
}

class _TimerDialog extends StatefulWidget {
  final Duration initialDuration;

  const _TimerDialog({Key? key, required this.initialDuration})
      : super(key: key);

  @override
  State createState() => _TimerDialogState();
}

class _TimerDialogState extends State<_TimerDialog> {
  late Duration timerDuration;

  @override
  Widget build(BuildContext context) {
    MaterialLocalizations localizations = MaterialLocalizations.of(context);
    final List<Widget> actions = [
      CupertinoActionSheetAction(
        child: Text(localizations.okButtonLabel),
        onPressed: () {
          Navigator.pop<Duration>(context, timerDuration);
        },
      ),
    ];

    final actionSheet = CupertinoActionSheet(
      title: const Text("Set Timer"),
      message: SizedBox(
        height: 200,
        child: CupertinoTimerPicker(
          initialTimerDuration: timerDuration,
          onTimerDurationChanged: (newDuration) => timerDuration = newDuration,
        ),
      ),
      actions: actions,
      cancelButton: CupertinoActionSheetAction(
        child: Text(localizations.cancelButtonLabel),
        onPressed: () => Navigator.pop(context),
      ),
    );

    return actionSheet;
  }

  @override
  void initState() {
    super.initState();
    timerDuration = widget.initialDuration;
  }
}
