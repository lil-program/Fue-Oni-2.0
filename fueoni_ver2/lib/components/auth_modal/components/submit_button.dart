import 'package:flutter/material.dart';
import 'package:fueoni_ver2/components/app_loading.dart';

class SubmitButton extends StatelessWidget {
  final String labelName;
  final VoidCallback onTap;

  final bool isLoading;

  const SubmitButton({
    Key? key,
    required this.labelName,
    required this.onTap,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      height: 40,
      child: ElevatedButton(
        onPressed: onTap,
        child: isLoading
            ? const AppLoading()
            : Text(
                labelName,
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
