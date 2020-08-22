import 'package:flutter/material.dart';

class SpinnerButton extends StatelessWidget {
  final GestureTapCallback onTap;
  Container container;

  SpinnerButton({this.onTap, this.container});

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
        child: Image.asset('assets/wine.png',
          height: 70,
          width: 30,
        ),
        onTap: onTap);
  }
}