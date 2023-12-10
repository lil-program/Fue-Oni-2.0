import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fueoni_ver2/main.dart';
import 'package:fueoni_ver2/services/database/user.dart';
import 'package:provider/provider.dart';

class AccountInfoCard extends HookWidget {
  final ValueNotifier<UserService> userService;
  final ValueNotifier<bool> isExpanded;
  final String? photoURL;

  const AccountInfoCard({
    Key? key,
    required this.userService,
    required this.isExpanded,
    required this.photoURL,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final nameController = useTextEditingController();
    return Card(
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
                      photoURL != null ? NetworkImage(photoURL!) : null,
                  child: photoURL == null ? const Icon(Icons.person) : null,
                ),
                title: const Text('アカウント情報'),
                subtitle: const Text('アカウントを管理します'),
              );
            },
            body: Column(
              children: <Widget>[
                ListTile(
                  title: Text(Provider.of<UserNameProvider>(context).userName ??
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
                                  userService.value
                                      .updateName(nameController.text);
                                  Provider.of<UserNameProvider>(context,
                                          listen: false)
                                      .setUserName(nameController.text);
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
            isExpanded: isExpanded.value,
          ),
        ],
      ),
    );
  }
}
