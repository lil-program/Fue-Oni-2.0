import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fueoni_ver2/screens/home_screen/tabs/profile_settings/pages/profile_view.dart';
import 'package:fueoni_ver2/screens/startup_screen/startup_screen.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({Key? key}) : super(key: key);

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  bool _isExpanded = false;

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
                  _isExpanded = !isExpanded;
                });
              },
              elevation: 1,
              expandedHeaderPadding: const EdgeInsets.all(0),
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
                  body: ProfileView(
                    name: user?.displayName ?? 'デフォルト名',
                    icon: Icons.person,
                  ),
                  isExpanded: _isExpanded,
                ),
              ],
            ),
          ),
          // 他のカードやウィジェットをここに追加できます
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
