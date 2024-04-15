import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import 'confetti_maker_widget.dart';
import 'seat.dart';
import 'spinner_button.dart';

// Constants
const int NUM_SEATS = 12;
const int SPIN_DURATION = 3000;

class StartupPickerWidget extends StatefulWidget {
  final _confettiController = ConfettiController();

  //Evenly position the seats in a circle around the spinner
  final _seatPositions = List<_SeatPosition>.generate(
      NUM_SEATS,
      (index) => _SeatPosition(
            top: sin(2.0 * pi * index.toDouble() / NUM_SEATS.toDouble() -
                        pi / 2) *
                    118 +
                117,
            left: cos(2.0 * pi * index.toDouble() / NUM_SEATS.toDouble() -
                        pi / 2) *
                    118 +
                117,
          ));

  @override
  StartupPickerWidgetState createState() => StartupPickerWidgetState();
}

class StartupPickerWidgetState extends State<StartupPickerWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  GlobalKey confettiKey = GlobalKey();
  var _seatStatuses = List.filled(NUM_SEATS, SeatStatus.unselected);
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
        widget._confettiController.play();
        _showResetButton();
      }
    });

    super.initState();
  }

  void _resetApp() {
    setState(() {
      _resetConfetti();
      _resetButtonVisible = false;
      _seatStatuses = List.filled(NUM_SEATS, SeatStatus.unselected);
      _controller.reset();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _resetConfetti() {
    setState(() {
      widget._confettiController.stop();
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

  void spin() {
    _resetConfetti();
    _hideResetButton();
    setState(() {
      for (var i = 0; i < NUM_SEATS; i++) {
        if (_seatStatuses[i] == SeatStatus.unselected) {
          _seatStatuses[i] = SeatStatus.hidden;
        }
      }
      List<int> activePositions = List<int>.empty(growable: true);

      for (var i = 0; i < NUM_SEATS; i++) {
        if (_seatStatuses[i] == SeatStatus.selected) {
          activePositions.add(i);
        }
      }

      if (activePositions.length == 0) {
        _seatStatuses = List.filled(NUM_SEATS, SeatStatus.selected);
        activePositions = List.generate(NUM_SEATS, (i) => i, growable: false);
      }

      var randomNum = _randomNumberGenerator.nextInt((activePositions.length));
      final winnerSeatPos = activePositions[randomNum];
      var additionalSpins = _randomNumberGenerator.nextInt(4) + 5;
      _spinRadians = (1.0 * winnerSeatPos / NUM_SEATS) + additionalSpins;
    });
    _controller.reset();
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    Animation<double> curve =
        CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    return new Material(
        color: Colors.teal,
        child: new Stack(
          children: <Widget>[
            new Center(
              child: new Stack(
                children: <Widget>[
                  Container(
                    width: 300.0,
                    height: 300.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  for (var i = 0; i < NUM_SEATS; i++)
                    Positioned(
                      child: Seat(
                        index: i,
                        color: Colors.blue,
                        onTap: () {
                          setState(() {
                            if (_seatStatuses[i] != SeatStatus.selected) {
                              _seatStatuses[i] = SeatStatus.selected;
                            } else {
                              _seatStatuses[i] = SeatStatus.unselected;
                            }
                          });
                        },
                        status: _seatStatuses[i],
                        iconData: Icons.add_circle,
                      ),
                      top: widget._seatPositions[i].top,
                      left: widget._seatPositions[i].left,
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
                          if (widget._confettiController.state ==
                              ConfettiControllerState.playing)
                            Positioned(
                              child: ConfettiMakerWidget(
                                controller: widget._confettiController,
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

class _SeatPosition {
  final double top;
  final double left;

  _SeatPosition({required this.top, required this.left});
}
