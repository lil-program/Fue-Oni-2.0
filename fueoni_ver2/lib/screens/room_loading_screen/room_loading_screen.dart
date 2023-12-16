import 'package:flutter/material.dart';
import 'package:fueoni_ver2/models/arguments.dart';
import 'package:fueoni_ver2/services/room_management/room_service.dart';
//import 'package:fueoni_ver2/services/database/loading_room_services.dart';
//import 'package:fueoni_ver2/services/database/room_services.dart';

class RoomLoadingScreen extends StatefulWidget {
  const RoomLoadingScreen({Key? key}) : super(key: key);

  @override
  RoomLoadingScreenState createState() => RoomLoadingScreenState();
}

class RoomLoadingScreenState extends State<RoomLoadingScreen> {
  final RoomService _roomServices = RoomService();
  int? roomId;
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ゲーム準備中'),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : const Text('すべてのプレイヤーが準備完了しました'),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)!.settings.arguments as RoomArguments;
      setState(() {
        roomId = args.roomId;
      });
      _checkAllPlayersReady();
    });
  }

  _checkAllPlayersReady() async {
    // 最初のチェックを行う前に2秒待機
    await Future.delayed(const Duration(seconds: 2));

    while (_isLoading) {
      bool allReady = await _roomServices.areAllPlayersLocationsSet(roomId);

      if (allReady) {
        setState(() {
          _isLoading = false;
        });
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        // プレイヤーがまだ準備完了していない場合、さらに10秒待機
        await Future.delayed(const Duration(seconds: 10));
      }
    }
  }
}
