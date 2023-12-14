import 'package:flutter/material.dart';
//import 'package:fueoni_ver2/services/database/room_services.dart';
import 'package:fueoni_ver2/color_schemes.dart';
////import 'package:fueoni_ver2/components/room/error_handling.dart';
//import 'package:fueoni_ver2/components/room/passcode_dialog.dart';
//import 'package:fueoni_ver2/components/room/room.dart';
//import 'package:fueoni_ver2/screens/room_creation/widgets/room_creation_widgets.dart';
import 'package:fueoni_ver2/services/database/creation_room_services.dart';

class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({Key? key}) : super(key: key);

  @override
  CreateRoomScreenState createState() => CreateRoomScreenState();
}

class CreateRoomScreenState extends State<CreateRoomScreen> {
  //final Duration _gameTimeLimit = Duration.zero;
  //final int _oniCount = 0;
  //final String _passcode = '';
  int? roomId;
  final _creationRoomServices = CreationRoomServices();
  //final _roomServices = RoomServices();
/*
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: RoomWidgets.roomAppbar(
        context: context,
        roomId: roomId,
        title: "ルーム設定",
        onBackButtonPressed: (int? roomId) {
          _creationRoomServices.removeRoomIdFromAllRoomId(roomId);
          Navigator.pushReplacementNamed(context, '/home');
        },
      ),
      floatingActionButton: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double width = MediaQuery.of(context).size.width;
          final double height = MediaQuery.of(context).size.height;

          //const double floatingActionButtonwidth = 56.0;
          //final double rightButtonwidthOffset = width * (1 - 0.1);
          //final double leftButtonwidthOffset = width * 0.15;
          final double screenWidth = MediaQuery.of(context).size.width;
          print("AAAAAAAAAAAAAAAAAAAaa");
          print(screenWidth);
          const double buttonWidth = 56.0;
          const double offsetFromCenter = 40.0;

          final double heightOffset = height * 0.01;

          return Stack(children: <Widget>[
            Positioned(
              //left: leftButtonwidthOffset - (floatingActionButtonwidth / 2),
              //left: (screenWidth / 2) - buttonWidth - offsetFromCenter,
              left:
                  1.0, //(screenWidth / 2) - buttonWidth / 2 - offsetFromCenter,
              bottom: heightOffset,
              child: FloatingActionButton(
                onPressed: () {
                  _creationRoomServices.removeRoomIdFromAllRoomId(roomId);
                  Navigator.pushReplacementNamed(context, '/home');
                },
                heroTag: 'leftButton',
                backgroundColor: lightColorScheme.primary,
                child:
                    Icon(Icons.arrow_back, color: lightColorScheme.onPrimary),
              ),
            ),
            Positioned(
              //left: rightButtonwidthOffset - (floatingActionButtonwidth / 2),
              //left: (screenWidth / 2) + buttonWidth - offsetFromCenter,
              //left: (screenWidth / 2) + offsetFromCenter - buttonWidth / 2,
              right: 0,
              bottom: heightOffset,
              child: FloatingActionButton(
                onPressed: () async {
                  try {
                    bool success = await _createRoom();
                    _roomServices.registerPlayer(roomId);
                    if (success && mounted) {
                      Navigator.pushReplacementNamed(context,
                          '/home/room_settings/create_room/room_creation_waiting',
                          arguments: CreationRoomArguments(roomId: roomId));
                    }
                  } catch (e) {
                    if (mounted) {
                      showErrorDialog(context, 'ルームの作成に失敗しました: $e');
                    }
                  }
                },
                heroTag: 'rightButton',
                backgroundColor: lightColorScheme.primary,
                child: Icon(Icons.check, color: lightColorScheme.onPrimary),
              ),
            ),
          ]);
        },
      ),
      body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    RoomWidgets.displayRoomId(context: context, roomId: roomId),
                    Column(
                      children: <Widget>[
                        RoomWidgets.passcodeDialogCard(
                          context: context,
                          passcode: _passcode,
                          displayWidgetFactory: (passcode) =>
                              passcodeSettingDisplay(
                            context: context,
                            passcode: passcode,
                            hintText: 'パスコードなし',
                          ),
                          onSelected: (selectedPasscode) {
                            setState(() {
                              _passcode = selectedPasscode;
                            });
                          },
                        ),
                        RoomCreationWidgets.timerDialogCard(
                          context: context,
                          gameTimeLimit: _gameTimeLimit,
                          onSelected: (selectedTimeLimit) {
                            setState(() {
                              _gameTimeLimit = selectedTimeLimit;
                            });
                          },
                        ),
                        RoomCreationWidgets.oniDialogCard(
                          context: context,
                          oniCount: _oniCount,
                          onSelected: (selectedOni) {
                            setState(() {
                              _oniCount = selectedOni;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ]),
    );
  }
  */

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    double headerHeight = screenHeight * 0.20;
    double footerHeight = screenHeight * 0.10;

    return Scaffold(
      backgroundColor: lightColorScheme.primary,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          //ヘッダー
          buildHeader(headerHeight, screenWidth),
          //フォーム
          Expanded(
            child: buildFormSection(screenWidth),
          ),
          //フッター
          buildFooter(footerHeight, screenWidth, context),
        ],
      ),
    );
  }

  Widget buildFooter(double height, double width, BuildContext context) {
    return Container(
      height: height,
      width: width,
      color: Theme.of(context).colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back button
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {},
            ),
            // Check button
            IconButton(
              icon: const Icon(Icons.check, color: Colors.white),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget buildFormSection(double width) {
    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: buildListTiles(),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildHeader(double height, double width) {
    return Container(
      height: height,
      width: width,
      color: lightColorScheme.primary,
      child: const Center(
        child: Text(
          'Choose your camera equipment',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  ListTile buildListTile(
      IconData leadingIcon, String title, IconData trailingIcon) {
    return ListTile(
      leading: Icon(leadingIcon),
      title: Text(title),
      trailing: Icon(trailingIcon),
    );
  }

  List<Widget> buildListTiles() {
    return [
      buildListTile(Icons.camera_alt, 'Crop sensor', Icons.close),
      buildListTile(Icons.camera_roll, 'Film', Icons.add),
      buildListTile(Icons.camera, 'Full frame', Icons.close),
      buildListTile(Icons.camera_rear, 'Mirrorless', Icons.add),
    ];
  }

  void _navigateToGameScreen() {
    _creationRoomServices.removeRoomIdFromAllRoomId(roomId);
    Navigator.pushReplacementNamed(context, '/home');
  }
}
