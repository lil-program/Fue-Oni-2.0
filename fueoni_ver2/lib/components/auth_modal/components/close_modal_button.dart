import 'package:flutter/material.dart';

class CloseModalButton extends StatelessWidget {
  final VoidCallback onPressed;

  const CloseModalButton({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: const Icon(Icons.close),
    );
  }
}
