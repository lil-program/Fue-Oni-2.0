// logout_button.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fueoni_ver2/components/app_loading.dart';

class LogoutButton extends HookWidget {
  final ValueNotifier<bool> isLoading;
  final Function signOut;

  const LogoutButton({
    Key? key,
    required this.isLoading,
    required this.signOut,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: ElevatedButton.icon(
        icon: isLoading.value
            ? const AppLoading()
            : const Icon(Icons.exit_to_app),
        label: const Text('Logout'),
        onPressed: () async {
          await signOut();
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.red,
        ),
      ),
    );
  }
}
