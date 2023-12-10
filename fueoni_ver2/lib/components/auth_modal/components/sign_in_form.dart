import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fueoni_ver2/components/auth_modal/components/auth_text_form_field.dart';
import 'package:fueoni_ver2/components/auth_modal/components/submit_button.dart';
import 'package:fueoni_ver2/services/auth/auth.dart';

import 'animated_error_message.dart';

class SignInForm extends HookWidget {
  const SignInForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final formKey = GlobalKey<FormState>();
    final isLoading = useState(false);
    final errorMessage = useState('');

    final authService = AuthService();

    Future<void> submit() async {
      if (formKey.currentState!.validate()) {
        isLoading.value = true;
        try {
          await authService.signInWithEmail(
            email: emailController.text,
            password: passwordController.text,
          );
          Future.microtask(() => Navigator.of(context).pop());
        } catch (e) {
          errorMessage.value = e.toString();
        } finally {
          isLoading.value = false;
        }
      }
    }

    return Form(
      key: formKey,
      child: Column(
        children: <Widget>[
          const Text(
            'Sign In',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16.0),
          AnimatedErrorMessage(
            errorMessage: errorMessage.value,
          ),
          const SizedBox(height: 16.0),
          AuthTextFormField(
            controller: emailController,
            labelText: 'Email',
            validator: validateNotEmpty,
            obscureText: false,
            onChanged: (value) => errorMessage.value = '',
          ),
          const SizedBox(height: 16.0),
          AuthTextFormField(
            controller: passwordController,
            labelText: 'Password',
            validator: validateNotEmpty,
            obscureText: true,
            onChanged: (value) => errorMessage.value = '',
          ),
          const SizedBox(height: 16.0),
          SubmitButton(
            labelName: 'Sign In',
            isLoading: isLoading.value,
            onTap: submit,
          ),
          const SizedBox(height: 16.0),
          GestureDetector(
            onTap: () async {
              isLoading.value = true;
              try {
                await authService.signInWithGoogle();
                Future.microtask(() => Navigator.of(context).pop());
              } catch (e) {
                errorMessage.value = e.toString();
              } finally {
                isLoading.value = false;
              }
            },
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image(
                  image: AssetImage("assets/images/google_logo.png"),
                  height: 35.0,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text(
                    'Sign in with Google',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  String? validateNotEmpty(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter some text';
    }
    return null;
  }
}
