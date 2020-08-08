import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:confetti/confetti.dart';
import 'dart:async';

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
        if(_iconColor == widget.initialColor) {
          _iconColor = Colors.red;
          widget.onTapCallback(true);
        } else {
          _iconColor = widget.initialColor;
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
          child: _iconColor == Colors.red ? Image.asset('assets/ManSitting' + widget.index.toString() + '.png',
            height: 60,
            width: 60,
          ) :
          Icon(
            Icons.add_circle,
            color: widget.initialColor,
          )
        ),
      ),
    );
  }
}

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

class ExampleWidgetState extends State<ExampleWidget> with TickerProviderStateMixin {
  AnimationController _controller;
  ConfettiController _controllerCenter;
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
    _controllerCenter =  ConfettiController(duration: const Duration(seconds: 3));
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int spin() {
    var winnerSeatPos = 0;
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
      winnerSeatPos = activePositions[randomNum];
      var additionalSpins = _rng.nextInt(2);
      _spinRadians = (1.0 * winnerSeatPos / widget.numSeats) + additionalSpins;
    });
    _controller.reset();
    _controller.forward();
    _spinOrReset = false;
    return winnerSeatPos;
  }

  void blast(int winnerSeat) {
   Timer(
        Duration(milliseconds: 800),
            (){ _controllerCenter.play(); }
    );
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
            for ( var i = 0 ; i < widget.numSeats; i++ )
              Positioned (
                child: Visibility (
                  visible: _visibilities[i],
                  child: new CircleButton (
                    index: i,
                    initialColor: Colors.blue,
                    iconData: Icons.add_circle,
                    onTapCallback: (bool selected){ _seatButtonsSelected[i] = selected;},
                  ),
                ),
                top: sin(2.0 * pi * i.toDouble()/widget.numSeats.toDouble() - pi/2) * 118 + 117,
                left: cos(2.0 * pi * i.toDouble()/widget.numSeats.toDouble() - pi/2) * 118 + 117,
              )
            ,
            new Positioned(
              child: RotationTransition (
                turns: Tween(begin: 0.0, end: _spinRadians).animate(_controller),
                child: new Stack(
                  children: <Widget>[
                    new SpinnerButton(
                      onTap: () {
                        if (_spinOrReset) {
                          var winnerSeat = spin();
                          blast(winnerSeat);
                        } else {
                          Phoenix.rebirth(context);
                        }
                      },
                    ),
                    new Positioned (
                      child: new ConfettiWidget (
                        confettiController: _controllerCenter,
                        blastDirection: -pi/2, // radial value - LEFT
                        particleDrag: 0.3, // apply drag to the confetti
                        emissionFrequency: 0.05, // how often it should emit
                        numberOfParticles: 20, // number of particles to emit
                        gravity: 0.01, // gravity - or fall speed
                        shouldLoop: false,
                        minimumSize: const Size(1,1),
                        maximumSize: const Size(10, 10),
                        minBlastForce: 7,
                        maxBlastForce: 8,
                        colors: const [
                          Colors.green,
                          Colors.blue,
                          Colors.pink
                        ], // manually specify the colors to be used
                      ),
                      top: 0.0,
                      left: 20.0,
                    ),
                  ],
                ),
              ),
              top: 115.0,
              left: 135.0,
            ),
          ],
        ),
      ),
    );
  }
}