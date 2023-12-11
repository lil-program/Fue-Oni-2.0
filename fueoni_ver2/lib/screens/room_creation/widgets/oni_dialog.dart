import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
  _OniDialogState createState() => _OniDialogState();
}

class OniDisplay extends StatelessWidget {
  final int oniCount;

  const OniDisplay({super.key, required this.oniCount});

  @override
  Widget build(BuildContext context) {
    return Text('鬼の数: $oniCount');
  }
}

class _OniDialogState extends State<OniDialog> {
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
