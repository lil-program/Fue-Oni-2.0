import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fueoni_ver2/components/auth_modal/components/close_modal_button.dart';
import 'package:fueoni_ver2/components/auth_modal/components/sign_in_form.dart';
import 'package:fueoni_ver2/components/auth_modal/components/sign_up_form.dart';

class AuthModal extends HookWidget {
  const AuthModal({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authModalType = useState(AuthModalType.singIn);
    final buttonLabel = useState('新規登録へ');

    void toggleAuthModalType() {
      authModalType.value = authModalType.value == AuthModalType.singIn
          ? AuthModalType.signUp
          : AuthModalType.singIn;

      buttonLabel.value =
          authModalType.value == AuthModalType.singIn ? '新規登録へ' : 'ログインへ';
    }

    void unFocus(BuildContext context) {
      final FocusScopeNode currentScope = FocusScope.of(context);
      if (!currentScope.hasPrimaryFocus && currentScope.hasFocus) {
        FocusManager.instance.primaryFocus!.unfocus();
      }
    }

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
                authModalType.value == AuthModalType.singIn
                    ? const SignInForm()
                    : const SignUpForm(),
                TextButton(
                    onPressed: toggleAuthModalType,
                    child: Text(buttonLabel.value)),
                const SizedBox(height: 300)
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum AuthModalType {
  singIn,
  signUp,
}
