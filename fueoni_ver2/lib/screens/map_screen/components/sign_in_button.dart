import 'package:flutter/material.dart';
import 'package:fueoni_ver2/components/auth_modal/auth_modal.dart';

class SignInButton extends StatelessWidget {
  const SignInButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          builder: (BuildContext context) {
            return const AuthModal();
          },
        );
      },
      label: const Text('SIGN IN'),
    );
  }
}
