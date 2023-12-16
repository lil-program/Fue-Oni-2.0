import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fueoni_ver2/components/auth_modal/auth_modal.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';

class StartupScreen extends StatelessWidget {
  const StartupScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => navigateBasedOnAuth(context),
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/startup.png'), // 背景画像のパスを指定
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // タイトルを修正
            Align(
              alignment: const Alignment(0, -0.5), // 位置を上に調整
              child: Text(
                'Fue-Oni 2.0',
                style: GoogleFonts.playfairDisplay(
                  textStyle: TextStyle(
                    color: Colors.brown[800], // テキストの色を茶色に設定
                    fontSize: 48, // フォントサイズを調整
                    fontWeight: FontWeight.w700, // フォントの太さを700に設定
                    shadows: [
                      Shadow(
                        blurRadius: 2.0,
                        color: Colors.black.withOpacity(0.3),
                        offset: const Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter, // ボタンの位置を画面下部中央に設定
              child: Padding(
                padding: const EdgeInsets.only(bottom: 60.0), // 下から60ピクセルの位置に設定
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .primary, // ボタンの背景色をテーマの色に設定
                    shadowColor: Colors.transparent, // 影を透明に設定
                    elevation: 0, // 影の高さを0に設定
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), // ボタンの角を丸く設定
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 48, vertical: 16), // ボタン内のパディングを調整
                  ),
                  onPressed: () => navigateBasedOnAuth(context),
                  child: const Text(
                    'TAP TO START',
                    style: TextStyle(
                      fontSize: 24, // フォントサイズを調整
                      fontWeight: FontWeight.bold, // フォントの太さをboldに設定
                      letterSpacing: 2, // 文字の間隔を調整
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> navigateBasedOnAuth(BuildContext context) async {
    // 位置情報の許可を求める
    LocationPermission permission = await Geolocator.checkPermission();

    Future<void> requestPermission() async {
      await Geolocator.openAppSettings();
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    } else if (permission == LocationPermission.deniedForever) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('位置情報の許可が必要です'),
              content: const Text('設定から位置情報をONにしてください。'),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        ).then((_) => requestPermission());
      });
    }

    // 位置情報の許可が得られたら、ユーザー認証を行う
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacementNamed(context, '/home');
        });
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final size = MediaQuery.of(context).size;
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              contentPadding: EdgeInsets.zero,
              insetPadding: const EdgeInsets.all(20),
              content: SizedBox(
                height: size.height * 0.6,
                width: size.width,
                child: const AuthModal(),
              ),
            ),
          );
        });
      }
    }
  }
}
