import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fueoni_ver2/app.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserNameProvider()),
        // 他のプロバイダーがあればここに追加
      ],
      child: const MyApp(),
    ),
  );
}

// ユーザー名を保持するクラス
class UserNameProvider with ChangeNotifier {
  String? _userName;

  String? get userName => _userName;

  void setUserName(String? userName) {
    _userName = userName;
    notifyListeners();
  }
}
