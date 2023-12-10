import 'package:flutter/material.dart';
import 'package:fueoni_ver2/services/creation_room_services.dart';

Widget roomCreationBackButton({
  required BuildContext context,
  required int? roomId,
}) {
  final roomIdGenerator = CreationRoomServices();
  return IconButton(
    icon: const Icon(Icons.arrow_back, color: Colors.black),
    onPressed: () {
      roomIdGenerator.removeRoomIdFromAllRoomId(roomId);
      Navigator.pushNamed(context, '/home/room_settings');
    },
  );
}
