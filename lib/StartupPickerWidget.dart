import 'dart:math';
import 'package:confetti/confetti.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

import 'CircleButton.dart';
import 'SpinnerButton.dart';

class StartupPickerWidget extends StatefulWidget {
  final numSeats = 12;
  final spinDuration = 2000;

  @override
  StartupPickerWidgetState createState() => StartupPickerWidgetState();
}

class StartupPickerWidgetState extends State<StartupPickerWidget> with TickerProviderStateMixin {
  AnimationController _controller;
  ConfettiController _controllerCenter;
  List<bool> _seatButtonsSelected;
  List<bool> _visibilities;
  List<CircleButton> circleButtons;
  bool _spinOrReset;
  double _spinRadians;
  final _rng = new Random();

  @override
  void initState() {
    _controller = AnimationController(
      duration: Duration(milliseconds: widget.spinDuration),
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
          _seatButtonsSelected[i] = true;
          activePositions.add(i);
        }
      }

      print("len = $activePositions.length");
      var randomNum = _rng.nextInt((activePositions.length));
      print("ran = $randomNum");
      winnerSeatPos = activePositions[randomNum];
      var additionalSpins = _rng.nextInt(4) + 3;
      _spinRadians = (1.0 * winnerSeatPos / widget.numSeats) + additionalSpins;
    });
    _controller.reset();
    _controller.forward();
    _spinOrReset = false;
    return winnerSeatPos;
  }

  void blast(int winnerSeat) {
    Timer(
        Duration(milliseconds: widget.spinDuration),
            (){ _controllerCenter.play(); }
    );
  }

  @override
  Widget build(BuildContext context) {
    Animation curve = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    Widget bigCircle = new Container(
      width: 300.0,
      height: 300.0,
      decoration: new BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
    return new Material(
      color: Colors.teal,
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
                    color: Colors.blue,
                    onTap: () { setState(() {
                      _seatButtonsSelected[i] = !_seatButtonsSelected[i];
                    });},
                    showChair: _seatButtonsSelected[i],
                    iconData: Icons.add_circle,
                  ),
                ),
                top: sin(2.0 * pi * i.toDouble()/widget.numSeats.toDouble() - pi/2) * 118 + 117,
                left: cos(2.0 * pi * i.toDouble()/widget.numSeats.toDouble() - pi/2) * 118 + 117,
              )
            ,
            new Positioned(
              child: RotationTransition (
                turns: Tween(begin: 0.0, end: _spinRadians).animate(curve),
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