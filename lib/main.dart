import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(new MaterialApp(home: new ExampleWidget()));
}

class ExampleWidget extends StatefulWidget {
  @override
  ExampleWidgetState createState() => ExampleWidgetState();
}


class CircleButton extends StatelessWidget {
  final GestureTapCallback onTap;
  final IconData iconData;
  final Color iconColor;

  const CircleButton({Key key, this.onTap, this.iconData, this.iconColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double size = 45.0;

    return new InkResponse(
      onTap: onTap,
      child: new Container(
        width: size,
        height: size,
        decoration: new BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: new Icon(
          iconData,
          color: iconColor,
        ),
      ),
    );
  }
}

class ExampleWidgetState extends State<ExampleWidget> with SingleTickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void spin() {
    _controller.reset();
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    Widget bigCircle = new Container(
      width: 300.0,
      height: 300.0,
      decoration: new BoxDecoration(
        color: Colors.orange,
        shape: BoxShape.circle,
      ),
    );
    var numSeats = 10;
    return new Material(
      color: Colors.black,
      child: new Center(
        child: new Stack(
          children: <Widget>[
            bigCircle,
            new Positioned(
              child: RotationTransition(
                turns: Tween(begin: 0.0, end: 2.0).animate(_controller),
                child: new CircleButton(onTap: () => spin(), iconColor: Colors.blue, iconData: Icons.arrow_upward,),
              ),
              top: 120.0,
              left: 130.0,
            ),
            for ( var i = 0 ; i < numSeats; i++ )
              Positioned(
                child: new CircleButton(
                  onTap: () {

                  },
                  iconData: Icons.golf_course,
                  iconColor: Colors.black,
                ),
                top: sin(2.0 * pi * i.toDouble()/numSeats.toDouble()) * 118 + 125,
                left: cos(2.0 * pi * i.toDouble()/numSeats.toDouble()) * 118 + 125,
              ),
          ],
        ),
      ),
    );
  }
}