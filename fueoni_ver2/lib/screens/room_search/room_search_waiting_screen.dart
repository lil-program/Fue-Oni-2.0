import 'package:flutter/material.dart';
import 'package:fueoni_ver2/components/room/room.dart';
import 'package:fueoni_ver2/services/room_services.dart';
import 'package:fueoni_ver2/services/search_room_services.dart';

class RoomSearchWaitingScreen extends StatefulWidget {
  const RoomSearchWaitingScreen({super.key});

  @override
  RoomSearchWaitingScreenState createState() => RoomSearchWaitingScreenState();
}

class RoomSearchWaitingScreenState extends State<RoomSearchWaitingScreen> {
  final RoomServices _roomServices = RoomServices();
  final SearchRoomServices _searchRoomServices = SearchRoomServices();
  List<String> users = [];
  String? ownerName;

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as SearchRoomArguments;

    return Scaffold(
      appBar: RoomWidgets.roomAppbar(
        context: context,
        roomId: args.roomId,
        title: "ルーム待機",
        onBackButtonPressed: (int? roomId) {
          _searchRoomServices.removePlayerId(roomId);
          Navigator.pushReplacementNamed(context, '/home');
        },
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          RoomWidgets.displayRoomId(context: context, roomId: args.roomId),
          RoomWidgets.userList(users),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final args =
          ModalRoute.of(context)!.settings.arguments as SearchRoomArguments;
      final roomId = args.roomId;
      ownerName = await _roomServices.getRoomOwnerName(roomId);

      _roomServices.updatePlayersList(roomId, (updatedUsers) {
        setState(() {
          users = updatedUsers;
          users.insert(0, ownerName ?? "RoomOwner");
        });
      });

      _searchRoomServices.monitorGameStart(roomId, (gameStarted) async {
        if (gameStarted) {
          bool hasPermission = await RoomServices.requestLocationPermission();
          if (hasPermission) {
            await RoomServices.updateCurrentLocation(_roomServices, roomId);
            //ここにゲーム画面への遷移を書く
            Navigator.pushReplacementNamed(context, '/home/room_settings');
          } else {
            print("パーミッションが拒否されました");
          }
        }
      });
    });
  }
}
