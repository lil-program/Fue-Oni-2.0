import 'package:flutter/material.dart';
import 'package:fueoni_ver2/components/auth_modal/components/close_modal_button.dart';
import 'package:fueoni_ver2/components/auth_modal/components/sign_in_form.dart';
import 'package:fueoni_ver2/components/auth_modal/components/sign_up_form.dart';

class AuthModal extends StatefulWidget {
  const AuthModal({
    Key? key,
  }) : super(key: key);

  @override
  State<AuthModal> createState() => _AuthModalState();
}

enum AuthModalType {
  singIn,
  signUp,
}

class _AuthModalState extends State<AuthModal> {
  AuthModalType _authModalType = AuthModalType.singIn;
  String buttonLabel = '新規登録へ';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => unFocus(context),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                CloseModalButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                _authModalType == AuthModalType.singIn
                    ? const SignInForm()
                    : const SignUpForm(),
                TextButton(
                    onPressed: _toggleAuthModalType, child: Text(buttonLabel)),
                const SizedBox(height: 300)
              ],
            ),
          ),
        ),
      ),
    );
  }

  void unFocus(BuildContext context) {
    final FocusScopeNode currentScope = FocusScope.of(context);
    if (!currentScope.hasPrimaryFocus && currentScope.hasFocus) {
      FocusManager.instance.primaryFocus!.unfocus();
    }
  }

  void _toggleAuthModalType() {
    setState(() {
      _authModalType = _authModalType == AuthModalType.singIn
          ? AuthModalType.signUp
          : AuthModalType.singIn;
    });

    buttonLabel = _authModalType == AuthModalType.singIn ? '新規登録へ' : 'ログインへ';
  }
}
