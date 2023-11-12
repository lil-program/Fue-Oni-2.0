import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fueoni_ver2/components/auth_modal/components/animated_error_message.dart';
import 'package:fueoni_ver2/components/auth_modal/components/auth_text_form_field.dart';
import 'package:fueoni_ver2/components/auth_modal/components/submit_button.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String errorMessage = '';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          const Text(
            'Sign Up',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          AnimatedErrorMessage(
            errorMessage: errorMessage,
          ),
          const SizedBox(height: 16.0),
          AuthTextFormField(
            controller: _nameController, // ユーザー名用のコントローラを指定
            labelText: 'Name', // ラベルを設定
            validator: validateName, // バリデーション関数を設定
            obscureText: false,
          ),
          const SizedBox(height: 16.0),
          AuthTextFormField(
            controller: _emailController,
            labelText: 'Email',
            validator: validateEmail,
            obscureText: false,
          ),
          const SizedBox(height: 16.0),
          AuthTextFormField(
            controller: _passwordController,
            labelText: 'Password',
            validator: validatePassword,
            obscureText: true,
          ),
          const SizedBox(height: 16.0),
          AuthTextFormField(
            labelText: 'Confirm Password',
            validator: validatePassword,
            obscureText: true,
          ),
          const SizedBox(height: 16.0),
          SubmitButton(
            labelName: 'Sign Up',
            isLoading: _isLoading,
            onTap: () => _submit(context),
          ),
        ],
      ),
    );
  }

  Future<UserCredential?> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      _setIsLoading(true);
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Realtime Databaseにユーザー情報を保存
      DatabaseReference usersRef =
          FirebaseDatabase.instance.ref().child('users');
      usersRef.child(userCredential.user!.uid).set({
        'name': name,
        'email': email,
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        _setErrorMessage('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        _setErrorMessage('The account already exists for that email.');
      } else {
        _setErrorMessage('Unidentified error occurred while signing up.');
      }
    } finally {
      _setIsLoading(false);
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter some text';
    }
    return null;
  }

  String? validateName(String? value) {
    // ユーザー名のバリデーション関数を追加
    if (value == null || value.isEmpty) {
      return 'Please enter your name';
    }
    return null;
  }

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
    if (value != _passwordController.text) {
      return 'Password does not match';
    }
    return null;
  }

  void _setErrorMessage(String message) {
    setState(() {
      errorMessage = message;
    });
  }

  void _setIsLoading(bool value) {
    setState(() {
      _isLoading = value;
    });
  }

  Future<void> _submit(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final UserCredential? user = await signUp(
        email: _emailController.text,
        password: _passwordController.text,
        name: _nameController.text,
      );

      if (!mounted) {
        return;
      }

      if (user != null) {
        Navigator.of(context).pop();
      }
    }
  }
}
