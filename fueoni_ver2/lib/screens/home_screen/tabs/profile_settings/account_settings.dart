import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fueoni_ver2/screens/startup_screen/startup_screen.dart';
import 'package:fueoni_ver2/services/database/user.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({Key? key}) : super(key: key);

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  bool _isExpanded = false;
  final _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String? photoURL = user?.photoURL;

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
              expansionCallback: (int index, bool isExpanded) {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
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
                        title: Text(user?.displayName ?? 'No name'),
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
                                    controller: _nameController,
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
                                        final userService =
                                            UserService(user!.uid);
                                        userService
                                            .updateName(_nameController.text);
                                        Navigator.of(context).pop();
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
                  isExpanded: _isExpanded,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.exit_to_app),
              label: const Text('Logout'),
              onPressed: () {
                _signOut().then((_) => _navigateToHomeScreen(context));
              },
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

  void _navigateToHomeScreen(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const StartupScreen()),
      (route) => false,
    );
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}
