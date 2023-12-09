import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fueoni_ver2/components/app_loading.dart';
import 'package:fueoni_ver2/main.dart';
import 'package:fueoni_ver2/services/database/user.dart';
import 'package:provider/provider.dart';

class AccountSettingsScreen extends HookWidget {
  const AccountSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isExpanded = useState(false);
    final nameController = useTextEditingController();
    final isLoading = useState(false);

    final User? user = FirebaseAuth.instance.currentUser;
    final String? photoURL = user?.photoURL;
    final userService = useState<UserService?>(null);
    if (user != null && userService.value == null) {
      userService.value = UserService(user.uid);
    }

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
        if (userService.value != null) {
          final fetchedName = await userService.value!.fetchName();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Provider.of<UserNameProvider>(context, listen: false)
                .setUserName(fetchedName);
          });
        }
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
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: ExpansionPanelList(
              expansionCallback: (int index, bool isCurrentlyExpanded) {
                isExpanded.value = !isExpanded.value;
              },
              children: [
                ExpansionPanel(
                  headerBuilder: (BuildContext context, bool isExpanded) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage:
                            photoURL != null ? NetworkImage(photoURL) : null,
                        child:
                            photoURL == null ? const Icon(Icons.person) : null,
                      ),
                      title: const Text('アカウント情報'),
                      subtitle: const Text('アカウントを管理します'),
                    );
                  },
                  body: Column(
                    children: <Widget>[
                      ListTile(
                        title: Text(
                            Provider.of<UserNameProvider>(context).userName ??
                                'No name'),
                        subtitle: const Text('ゲームで使用される名前です'),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('名前を編集'),
                                  content: TextField(
                                    controller: nameController,
                                    decoration: const InputDecoration(
                                      labelText: '新しい名前',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text('キャンセル'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: const Text('保存'),
                                      onPressed: () {
                                        if (userService.value != null) {
                                          userService.value!
                                              .updateName(nameController.text);
                                          Provider.of<UserNameProvider>(context,
                                                  listen: false)
                                              .setUserName(nameController.text);
                                          Navigator.of(context).pop();
                                        }
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  isExpanded: isExpanded.value,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: ElevatedButton.icon(
              icon: isLoading.value
                  ? const AppLoading()
                  : const Icon(Icons.exit_to_app),
              label: const Text('Logout'),
              onPressed: signOut,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
