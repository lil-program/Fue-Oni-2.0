import 'package:flutter/material.dart';

class AppLoading extends StatelessWidget {
  final double dimension;

  const AppLoading({Key? key, this.dimension = 20}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: dimension,
      child: const CircularProgressIndicator(
        strokeWidth: 2,
        color: Colors.white,
      ),
    );
  }
}
