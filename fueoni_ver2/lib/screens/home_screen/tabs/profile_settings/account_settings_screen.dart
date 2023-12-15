import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fueoni_ver2/hooks/use_location.dart';
import 'package:fueoni_ver2/main.dart';
import 'package:fueoni_ver2/services/database/user.dart';
import 'package:provider/provider.dart';

import 'components/accounting_info_card.dart';
import 'components/logout_button.dart';

class AccountSettingsScreen extends HookWidget {
  const AccountSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    useLocationPermissionCheck(context);
    final isExpanded = useState(false);
    final isLoading = useState(false);

    final User? user = FirebaseAuth.instance.currentUser;
    final String? photoURL = user?.photoURL;

    final userService =
        useMemoized(() => user != null ? UserService(user.uid) : null, [user]);

    final signOut = useCallback(() async {
      isLoading.value = true;
      await FirebaseAuth.instance.signOut();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        isLoading.value = false;
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      });
    }, const []);

    useEffect(() {
      bool isActive = true;
      final userNameProvider = context.read<UserNameProvider>();

      void fetchName() async {
        final fetchedName = await userService!.fetchName();
        if (isActive) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            userNameProvider.setUserName(fetchedName);
          });
        }
      }

      if (userNameProvider.userName == null) {
        fetchName();
      }

      return () {
        isActive = false; // クリーンアップ関数でisActiveをfalseに設定
      };
    }, []);

    return Scaffold(
      appBar: AppBar(
        title: const Text('アカウント設定'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: <Widget>[
          if (userService != null)
            AccountInfoCard(
              userService: ValueNotifier(userService),
              isExpanded: isExpanded,
              photoURL: photoURL,
            ),
          LogoutButton(
            isLoading: isLoading,
            signOut: signOut,
          ),
        ],
      ),
    );
  }
}
