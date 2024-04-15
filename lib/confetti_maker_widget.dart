import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

const double _PARTICLE_DRAG = 0.3;
const double _EMISSION_FREQUENCY = 0.05;
const int _NUMBER_OF_PARTICLES = 20;
const double _GRAVITY = 0.01;
const double _MIN_BLAST_FORCE = 7;
const double _MAX_BLAST_FORCE = 8;

class ConfettiMakerWidget extends StatelessWidget {
  final ConfettiController controller;

  ConfettiMakerWidget({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    return ConfettiWidget(
      confettiController: controller,
      blastDirection: -pi / 2, // radial value - LEFT
      particleDrag: _PARTICLE_DRAG, // apply drag to the confetti
      emissionFrequency: _EMISSION_FREQUENCY, // how often it should emit
      numberOfParticles: _NUMBER_OF_PARTICLES, // number of particles to emit
      gravity: _GRAVITY, // gravity - or fall speed
      shouldLoop: false,
      minimumSize: const Size(1, 1),
      maximumSize: const Size(10, 10),
      minBlastForce: _MIN_BLAST_FORCE,
      maxBlastForce: _MAX_BLAST_FORCE,
      colors: const [Colors.green, Colors.blue, Colors.pink],
    );
  }
}
