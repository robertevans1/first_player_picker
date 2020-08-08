import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:confetti/confetti.dart';

void main() {
  runApp(
      Phoenix(
          child: new MaterialApp(home: new ExampleWidget()),
      )
  );
}

class ExampleWidget extends StatefulWidget {
  final numSeats = 12;

  @override
  ExampleWidgetState createState() => ExampleWidgetState();
}

class CircleButton extends StatefulWidget {
  final int index;
  final Function(bool) onTapCallback;
  final IconData iconData;
  final Color initialColor;

  CircleButton({this.index, this.onTapCallback, this.iconData, this.initialColor});

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
    double size = 65.0;
    return new InkResponse(
      onTap: onTap,
      child: new Container(
        width: size,
        height: size,
        child: ColorFiltered(
          colorFilter: _iconColor == Colors.red ? ColorFilter.mode(
            Colors.transparent,
            BlendMode.multiply,
          ) : ColorFilter.matrix(<double>[
            0.2126,0.7152,0.0722,0,0,
            0.2126,0.7152,0.0722,0,0,
            0.2126,0.7152,0.0722,0,0,
            0,0,0,1,0,
          ]),
          child: Image.asset('assets/ManSitting' + widget.index.toString() + '.png',
            height: 60,
            width: 60,
          ),
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
    return new GestureDetector(
       child: Image.asset('assets/wine.png',
          height: 70,
          width: 30,
        ),
      onTap: onTap);
  }
}

class ExampleWidgetState extends State<ExampleWidget> with TickerProviderStateMixin {
  AnimationController _controller;
  List<bool> _seatButtonsSelected;
  List<bool> _visibilities;
  bool _spinOrReset;
  double _spinRadians;
  final _rng = new Random();

  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _seatButtonsSelected = List<bool>();
    _visibilities = List<bool>();
    for ( var i = 0 ; i < widget.numSeats; i++ ) {
      _seatButtonsSelected.add(false);
      _visibilities.add(true);
    }
    _spinOrReset = true;

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void spin() {
    setState(() {
      _visibilities = _seatButtonsSelected;
      List<int> activePositions = List<int>();

      for(var i = 0 ; i < widget.numSeats; i++) {
        if(_visibilities[i] == true){
          activePositions.add(i);
        }
      }
      if(activePositions.length == 0) {
        for(var i = 0 ; i < widget.numSeats; i++) {
          _visibilities[i] = true;
          activePositions.add(i);
        }
      }

      print("len = $activePositions.length");
      var randomNum = _rng.nextInt((activePositions.length));
      print("ran = $randomNum");
      var winnerSeatPos = activePositions[randomNum];
      var additionalSpins = _rng.nextInt(2);
      _spinRadians = (1.0 * winnerSeatPos / widget.numSeats) + additionalSpins;
    });
    _controller.reset();
    _controller.forward();
    _spinOrReset = false;
  }

  @override
  Widget build(BuildContext context) {
    Widget bigCircle = new Container(
      width: 300.0,
      height: 300.0,
      decoration: new BoxDecoration(
        color: Colors.white,
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
                turns: Tween(begin: 0.0, end: _spinRadians).animate(_controller),
                child: new SpinnerButton(onTap: () {
                  if (_spinOrReset) {
                    spin();
                  } else {
                    Phoenix.rebirth(context);
                  }
                }),
              ),
              top: 110.0,
              left: 140.0,
            ),
            for ( var i = 0 ; i < widget.numSeats; i++ )
              Positioned (
                child: Visibility (
                  visible: _visibilities[i],
                  child: new CircleButton (
                    index: i,
                    initialColor: Colors.black,
                    iconData: Icons.golf_course,
                    onTapCallback: (bool selected){ _seatButtonsSelected[i] = selected;},
                  ),
                ),
                top: sin(2.0 * pi * i.toDouble()/widget.numSeats.toDouble() - pi/2) * 118 + 117,
                left: cos(2.0 * pi * i.toDouble()/widget.numSeats.toDouble() - pi/2) * 118 + 117,
              )
          ],
        ),
      ),
    );
  }
}