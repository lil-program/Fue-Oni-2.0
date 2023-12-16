import 'package:flutter/material.dart';
import 'package:fueoni_ver2/components/locate_permission_check.dart';
import 'package:fueoni_ver2/models/arguments.dart';
import 'package:fueoni_ver2/services/room_management/player_service.dart';

class RoomLoadingScreen extends StatefulWidget {
  final RoomArguments roomArguments;
  const RoomLoadingScreen({Key? key, required this.roomArguments})
      : super(key: key);

  @override
  RoomLoadingScreenState createState() => RoomLoadingScreenState();
}

class RoomLoadingScreenState extends State<RoomLoadingScreen> {
  int? _roomId;
  final PlayerService _playerService =
      PlayerService(); // Instance of PlayerService

  @override
  Widget build(BuildContext context) {
    return LocationPermissionCheck(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ゲーム準備中'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: _navigateToMap,
            child: const Text('マップへ'),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _roomId = widget.roomArguments.roomId;
      });
    });
  }

  void _navigateToMap() async {
    bool isOni = await _playerService.isPlayerOni(_roomId!);
    if (isOni) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/map/oni',
            arguments: RoomArguments(roomId: _roomId));
      }
    } else {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/map/runner',
            arguments: RoomArguments(roomId: _roomId));
      }
    }
  }
}
