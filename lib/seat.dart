import 'package:flutter/material.dart';

enum SeatStatus {
  hidden,
  unselected,
  selected;
}

class Seat extends StatelessWidget {
  final int index;
  final GestureTapCallback onTap;
  final IconData iconData;
  final Color color;
  final SeatStatus status;

  Seat(
      {required this.index,
      required this.onTap,
      required this.iconData,
      required this.color,
      required this.status});

  @override
  Widget build(BuildContext context) {
    double size = 65.0;
    return Visibility(
      visible: status != SeatStatus.hidden,
      child: new InkResponse(
        onTap: onTap,
        child: new Container(
          width: size,
          height: size,
          child: ColorFiltered(
              colorFilter: color == Colors.blue
                  ? ColorFilter.mode(
                      Colors.transparent,
                      BlendMode.multiply,
                    )
                  : ColorFilter.matrix(<double>[
                      0.2126,
                      0.7152,
                      0.0722,
                      0,
                      0,
                      0.2126,
                      0.7152,
                      0.0722,
                      0,
                      0,
                      0.2126,
                      0.7152,
                      0.0722,
                      0,
                      0,
                      0,
                      0,
                      0,
                      1,
                      0,
                    ]),
              child: status == SeatStatus.selected
                  ? Image.asset(
                      'assets/ManSitting' + index.toString() + '.png',
                      height: 60,
                      width: 60,
                    )
                  : Icon(
                      Icons.add_circle,
                      color: color,
                    )),
        ),
      ),
    );
  }
}
