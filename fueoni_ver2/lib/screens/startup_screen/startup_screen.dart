import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fueoni_ver2/components/auth_modal/auth_modal.dart';
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
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          contentPadding: EdgeInsets.zero,
          insetPadding: const EdgeInsets.all(20), // 画面の周囲に20ピクセルのパディングを追加
          content: SizedBox(
            height:
                MediaQuery.of(context).size.height * 0.6, // ダイアログの高さを画面の80%に設定
            width: MediaQuery.of(context).size.width, // ダイアログの幅を画面の幅に設定
            child: const AuthModal(),
          ),
        ),
      );
    }
  }
}
