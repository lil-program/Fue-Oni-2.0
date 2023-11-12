import 'package:flutter/material.dart';
import 'package:fueoni_ver2/screens/map_screen/map_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class StartupScreen extends StatelessWidget {
  const StartupScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            alignment: const Alignment(0, -0.3), // 位置を上に調整
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
                  backgroundColor:
                      Theme.of(context).colorScheme.primary, // ボタンの背景色をテーマの色に設定
                  shadowColor: Colors.transparent, // 影を透明に設定
                  elevation: 0, // 影の高さを0に設定
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30), // ボタンの角を丸く設定
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 48, vertical: 16), // ボタン内のパディングを調整
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FutureBuilder<MapScreen>(
                        future: initMapScreen(), // 非同期関数を呼び出す
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator(); // データを待っている間はローディングインジケータを表示
                          } else if (snapshot.hasError) {
                            return const Text(
                                'エラーが発生しました'); // エラーが発生した場合はエラーメッセージを表示
                          } else {
                            return snapshot.data!; // データが取得できたらMapScreenを表示
                          }
                        },
                      ),
                    ),
                  );
                },
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
    );
  }
}
