import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(new MaterialApp(home: new ExampleWidget()));
}

class ExampleWidget extends StatefulWidget {
  final numSeats = 10;

  @override
  ExampleWidgetState createState() => ExampleWidgetState();
}

class CircleButton extends StatefulWidget {
  final Function(bool) onTapCallback;
  final IconData iconData;
  final Color initialColor;

  CircleButton({this.onTapCallback, this.iconData, this.initialColor});

  @override
  CircleButtonState createState() => CircleButtonState();
}


class CircleButtonState extends State<CircleButton> {
  Color _iconColor;
  GestureTapCallback onTap;

    @override void initState() {
    super.initState();
    _iconColor = widget.initialColor;
    onTap = () {
      setState(() {
        if(_iconColor == Colors.black) {
          _iconColor = Colors.red;
          widget.onTapCallback(true);
        } else {
          _iconColor = Colors.black;
          widget.onTapCallback(false);
        }
      });
    };
  }

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
          widget.iconData,
          color:_iconColor,
        ),
      ),
    );
  }
}

class SpinnerButton extends StatelessWidget {
  final GestureTapCallback onTap;

  SpinnerButton({this.onTap});

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
          Icons.arrow_upward,
          color: Colors.blue,
        ),
      ),
    );
  }
}

class ExampleWidgetState extends State<ExampleWidget> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  List<bool> seatButtonsSelected;
  List<bool> visibilities;

  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    seatButtonsSelected = List<bool>();
    visibilities = List<bool>();
    for ( var i = 0 ; i < widget.numSeats; i++ ) {
      seatButtonsSelected.add(false);
      visibilities.add(true);
    }

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void spin() {

    setState(() {
      visibilities = seatButtonsSelected;
    });

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
    return new Material(
      color: Colors.black,
      child: new Center(
        child: new Stack(
          children: <Widget>[
            bigCircle,
            new Positioned(
              child: RotationTransition(
                turns: Tween(begin: 0.0, end: 2.0).animate(_controller),
                child: new SpinnerButton(onTap: () => spin()),
              ),
              top: 120.0,
              left: 130.0,
            ),
            for ( var i = 0 ; i < widget.numSeats; i++ )
              Positioned (
                child: Visibility (
                  visible: visibilities[i],
                  child: new CircleButton (
                  initialColor: Colors.black,
                    iconData: Icons.golf_course,
                    onTapCallback: (bool selected){ seatButtonsSelected[i] = selected;},
                  ),
                ),
                top: sin(2.0 * pi * i.toDouble()/widget.numSeats.toDouble()) * 118 + 125,
                left: cos(2.0 * pi * i.toDouble()/widget.numSeats.toDouble()) * 118 + 125,
              )

          ],
        ),
      ),
    );
  }
}