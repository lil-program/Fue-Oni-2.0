import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget oniDisplay({
  required int oniCount,
  String title = '鬼の数',
  IconData icon = Icons.person_outline,
}) {
  return Row(
    mainAxisSize: MainAxisSize.max,
    children: <Widget>[
      Icon(icon),
      const SizedBox(width: 8),
      Text(title),
      const SizedBox(width: 8),
      Text('$oniCount'),
    ],
  );
}

Future<int?> showOniDialog({
  required BuildContext context,
  TransitionBuilder? builder,
  bool useRootNavigator = true,
  int initialOniCount = 0,
}) {
  final Widget dialog = OniDialog(initialOniCount: initialOniCount);
  return showCupertinoModalPopup<int>(
    context: context,
    useRootNavigator: useRootNavigator,
    builder: (BuildContext context) => builder?.call(context, dialog) ?? dialog,
  );
}

class OniDialog extends StatefulWidget {
  final int initialOniCount;

  const OniDialog({Key? key, required this.initialOniCount}) : super(key: key);

  @override
  OniDialogState createState() => OniDialogState();
}

class OniDialogState extends State<OniDialog> {
  late int tempOniCount;
  final List<int> oniCounts = List.generate(11, (index) => index);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('鬼の数を選択'),
      content: SizedBox(
        height: 200,
        child: CupertinoPicker(
          itemExtent: 32,
          diameterRatio: 1.1,
          onSelectedItemChanged: (int value) =>
              setState(() => tempOniCount = value),
          scrollController:
              FixedExtentScrollController(initialItem: tempOniCount),
          children: oniCounts.map((count) => Text(count.toString())).toList(),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('キャンセル'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: const Text('OK'),
          onPressed: () => Navigator.of(context).pop(tempOniCount),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    tempOniCount = widget.initialOniCount;
  }
}
