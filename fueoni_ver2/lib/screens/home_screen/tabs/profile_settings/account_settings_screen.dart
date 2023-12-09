import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fueoni_ver2/main.dart';
import 'package:fueoni_ver2/services/database/user.dart';
import 'package:provider/provider.dart';

import 'components/accounting_info_card.dart';
import 'components/logout_button.dart';

class AccountSettingsScreen extends HookWidget {
  const AccountSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
      void fetchName() async {
        final fetchedName = await userService!.fetchName();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Provider.of<UserNameProvider>(context, listen: false)
              .setUserName(fetchedName);
        });
      }

      if (Provider.of<UserNameProvider>(context, listen: false).userName ==
          null) {
        fetchName();
      }

      return () {}; // cleanup function
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