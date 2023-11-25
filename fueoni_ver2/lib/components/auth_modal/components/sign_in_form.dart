import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fueoni_ver2/components/auth_modal/components/auth_text_form_field.dart';
import 'package:fueoni_ver2/components/auth_modal/components/submit_button.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'animated_error_message.dart';

class SignInForm extends StatefulWidget {
  const SignInForm({super.key});

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
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
            errorMessage: errorMessage,
          ),
          const SizedBox(height: 16.0),
          AuthTextFormField(
            controller: _emailController,
            labelText: 'Email',
            validator: validateEmail,
            obscureText: false,
            onChanged: (value) => _clearErrorMessage(),
          ),
          const SizedBox(height: 16.0),
          AuthTextFormField(
            controller: _passwordController,
            labelText: 'Password',
            validator: validatePassword,
            obscureText: true,
            onChanged: (value) => _clearErrorMessage(),
          ),
          const SizedBox(height: 16.0),
          SubmitButton(
            labelName: 'Sign In',
            isLoading: _isLoading,
            onTap: () => _submit(context),
          ),
          const SizedBox(height: 16.0),
          GestureDetector(
            onTap: () {
              signInWithGoogle();
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

  Future<UserCredential?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _setIsLoading(true);
      return await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _setErrorMessage('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        _setErrorMessage('Wrong password provided for that user.');
      } else {
        _setErrorMessage('Unidentified error occurred while signing in.');
      }
    } finally {
      _setIsLoading(false);
    }
    return null;
  }

  Future<void> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    if (googleUser != null) {
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);
        print(userCredential.user); // Print the authenticated user
        final context = this.context;
        return _pop(context, userCredential);
      } on FirebaseAuthException catch (e) {
        // Handle Firebase authentication error
        print(e);
      } catch (e) {
        // Handle other errors
        print(e);
      }
    }

    return;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter some text';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter some text';
    }
    return null;
  }

  void _clearErrorMessage() {
    setState(() {
      errorMessage = '';
    });
  }

  void _pop(BuildContext context, UserCredential? user) {
    if (user != null) {
      Navigator.of(context).pop();
    }
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
      final UserCredential? user = await signIn(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (!mounted) {
        return;
      }

      final context = this.context;
      return _pop(context, user);
    }
  }
}
