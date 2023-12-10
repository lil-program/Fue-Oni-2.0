import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fueoni_ver2/components/auth_modal/components/auth_text_form_field.dart';
import 'package:fueoni_ver2/components/auth_modal/components/submit_button.dart';
import 'package:fueoni_ver2/services/auth/auth.dart';

import 'animated_error_message.dart';

class SignUpForm extends HookWidget {
  const SignUpForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();
    final nameController = useTextEditingController();
    final formKey = GlobalKey<FormState>();
    final isLoading = useState(false);
    final errorMessage = useState('');

    final authService = AuthService();

    String? validatePassword(String? value) {
      if (value == null || value.isEmpty) {
        return 'Please enter some text';
      }
      if (value.length < 6) {
        return 'Password must be at least 6 characters';
      }
      if (value.length > 20) {
        return 'Password must be less than 20 characters';
      }
      if (value != passwordController.text) {
        return 'Password does not match';
      }
      return null;
    }

    Future<void> submit() async {
      if (formKey.currentState!.validate()) {
        isLoading.value = true;
        try {
          await authService.signUp(
            email: emailController.text,
            password: passwordController.text,
            name: nameController.text,
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
            'Sign Up',
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
            controller: nameController,
            labelText: 'Name',
            validator: validateNotEmpty,
            obscureText: false,
            onChanged: (value) => errorMessage.value = '',
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
            validator: validatePassword,
            obscureText: true,
            onChanged: (value) => errorMessage.value = '',
          ),
          const SizedBox(height: 16.0),
          AuthTextFormField(
            controller: confirmPasswordController,
            labelText: 'Confirm Password',
            validator: validatePassword,
            obscureText: true,
            onChanged: (value) => errorMessage.value = '',
          ),
          const SizedBox(height: 16.0),
          SubmitButton(
            labelName: 'Sign Up',
            isLoading: isLoading.value,
            onTap: submit,
          ),
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
