import 'package:flutter/material.dart';
import 'package:fueoni_ver2/components/app_loading.dart';

class SignOutButton extends StatelessWidget {
  final VoidCallback onPressed;

  final bool isLoading;

  const SignOutButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      child: isLoading ? const AppLoading() : const Icon(Icons.logout),
    );
  }
}
