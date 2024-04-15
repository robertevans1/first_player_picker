import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import 'circle_button.dart';
import 'confetti_maker_widget.dart';
import 'spinner_button.dart';

// Constants
const int NUM_SEATS = 12;
const int SPIN_DURATION = 3000;

class StartupPickerWidget extends StatefulWidget {
  @override
  StartupPickerWidgetState createState() => StartupPickerWidgetState();
}

class StartupPickerWidgetState extends State<StartupPickerWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  ConfettiController _confettiController = ConfettiController();
  GlobalKey confettiKey = GlobalKey();
  ConfettiMakerWidget? _confettiWidget;
  var _seatButtonsSelected = List.filled(NUM_SEATS, false);
  var _visibilities = List.filled(NUM_SEATS, true);
  bool _resetButtonVisible = false;
  double _spinRadians = 0.0;
  final _randomNumberGenerator = new Random();

  @override
  void initState() {
    _controller = AnimationController(
      duration: Duration(milliseconds: SPIN_DURATION),
      vsync: this,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        print("Animation completed");
        _confettiController.play();
        _showResetButton();
      }
    });

    super.initState();
  }

  void _resetApp() {
    setState(() {
      _resetConfetti();
      _resetButtonVisible = false;
      _seatButtonsSelected = List.filled(NUM_SEATS, false);
      _visibilities = List.filled(NUM_SEATS, true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _resetConfetti() {
    setState(() {
      _confettiController.stop();
      confettiKey = GlobalKey();
    });
  }

  void _hideResetButton() {
    setState(() {
      _resetButtonVisible = false;
    });
  }

  void _showResetButton() {
    setState(() {
      _resetButtonVisible = true;
    });
  }

  int spin() {
    var winnerSeatPos = 0;
    _resetConfetti();
    _hideResetButton();
    setState(() {
      _visibilities = List.from(_seatButtonsSelected);
      List<int> activePositions = List<int>.empty(growable: true);

      for (var i = 0; i < NUM_SEATS; i++) {
        if (_visibilities[i] == true) {
          activePositions.add(i);
        }
      }

      if (activePositions.length == 0) {
        _visibilities = List.filled(NUM_SEATS, true);
        _seatButtonsSelected = List.filled(NUM_SEATS, true);
        activePositions = List.generate(NUM_SEATS, (i) => i, growable: false);
      }

      var randomNum = _randomNumberGenerator.nextInt((activePositions.length));
      winnerSeatPos = activePositions[randomNum];
      var additionalSpins = _randomNumberGenerator.nextInt(4) + 5;
      _spinRadians = (1.0 * winnerSeatPos / NUM_SEATS) + additionalSpins;
    });
    _controller.reset();
    _controller.forward();
    return winnerSeatPos;
  }

  @override
  Widget build(BuildContext context) {
    Animation<double> curve =
        CurvedAnimation(parent: _controller, curve: Curves.easeOut);
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
        child: new Stack(
          children: <Widget>[
            new Center(
              child: new Stack(
                children: <Widget>[
                  bigCircle,
                  for (var i = 0; i < NUM_SEATS; i++)
                    Positioned(
                      child: Visibility(
                        visible: _visibilities[i],
                        child: CircleButton(
                          index: i,
                          color: Colors.blue,
                          onTap: () {
                            setState(() {
                              _seatButtonsSelected[i] =
                                  !_seatButtonsSelected[i];
                            });
                          },
                          showChair: _seatButtonsSelected[i],
                          iconData: Icons.add_circle,
                        ),
                      ),
                      top: sin(2.0 * pi * i.toDouble() / NUM_SEATS.toDouble() -
                                  pi / 2) *
                              118 +
                          117,
                      left: cos(2.0 * pi * i.toDouble() / NUM_SEATS.toDouble() -
                                  pi / 2) *
                              118 +
                          117,
                    ),
                  new Positioned(
                    child: RotationTransition(
                      turns:
                          Tween(begin: 0.0, end: _spinRadians).animate(curve),
                      child: new Stack(
                        children: <Widget>[
                          new SpinnerButton(
                            onTap: () {
                              spin();
                            },
                          ),
                          if (_confettiController.state ==
                              ConfettiControllerState.playing)
                            Positioned(
                              child: ConfettiMakerWidget(
                                controller: _confettiController,
                                key: confettiKey,
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
            Visibility(
                visible: _resetButtonVisible,
                child: Positioned(
                    bottom: 20,
                    right: 0,
                    child: RawMaterialButton(
                      onPressed: () {
                        _resetApp();
                      },
                      elevation: 20.0,
                      fillColor: Colors.white,
                      child: Icon(
                        Icons.refresh,
                        size: 25.0,
                        color: Colors.blueGrey,
                      ),
                      padding: EdgeInsets.all(5.0),
                      shape: CircleBorder(),
                    )))
          ],
        ));
  }
}
