import 'package:flutter/material.dart';
import 'package:fueoni_ver2/components/room/room.dart';
import 'package:fueoni_ver2/screens/room_creation/widgets/oni_dialog.dart';
import 'package:fueoni_ver2/screens/room_creation/widgets/timer_dialog.dart';

typedef DialogCallback = Future<void> Function();

class RoomCreationWidgets {
  static Widget oniDialogCard({
    required BuildContext context,
    required int oniCount,
    required Function(int) onSelected,
  }) {
    return RoomWidgets.settingDialogCard(
      context: context,
      showDialogCallback: () async {
        final int? result =
            await showOniDialog(context: context, initialOniCount: oniCount);
        if (result != null) {
          onSelected(result);
        }
      },
      displayWidget: oniDisplay(context: context, oniCount: oniCount),
    );
  }

  static Widget timerDialogCard({
    required BuildContext context,
    required Duration gameTimeLimit,
    required Function(Duration) onSelected,
  }) {
    return RoomWidgets.settingDialogCard(
      context: context,
      showDialogCallback: () async {
        final Duration? result = await showTimerDialog(context: context);
        if (result != null) {
          onSelected(result);
        }
      },
      displayWidget: timerDisplay(context: context, duration: gameTimeLimit),
    );
  }
}
