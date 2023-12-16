import 'package:flutter/material.dart';
import 'package:fueoni_ver2/components/locate_permission_check.dart';
import 'package:fueoni_ver2/models/arguments.dart';

class RoomLoadingScreen extends StatefulWidget {
  final RoomArguments roomArguments;
  const RoomLoadingScreen({Key? key, required this.roomArguments})
      : super(key: key);

  @override
  RoomLoadingScreenState createState() => RoomLoadingScreenState();
}

class RoomLoadingScreenState extends State<RoomLoadingScreen> {
  int? _roomId;

  @override
  Widget build(BuildContext context) {
    return LocationPermissionCheck(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ゲーム準備中'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: _navigateOniMap,
            child: const Text('鬼マップへ'),
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

  void _navigateOniMap() {
    Navigator.pushReplacementNamed(context, '/map/oni',
        arguments: RoomArguments(roomId: _roomId));
  }
}
