import 'package:flutter/material.dart';

class AnimatedErrorMessage extends StatelessWidget {
  final String errorMessage;

  const AnimatedErrorMessage({
    Key? key,
    required this.errorMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: errorMessage.isEmpty ? 0 : 1,
      duration: const Duration(milliseconds: 500),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(8),
          ),
          color: Colors.red,
        ),
        child: Text(
          errorMessage,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
