import 'package:flutter/material.dart';

class CircleButton extends StatelessWidget {
  final int index;
  final GestureTapCallback onTap;
  final IconData iconData;
  final Color color;
  final bool showChair;

  CircleButton({this.index, this.onTap, this.iconData, this.color, this.showChair});

  @override
  Widget build(BuildContext context) {
    double size = 65.0;
    return new InkResponse(
      onTap: onTap,
      child: new Container(
        width: size,
        height: size,
        child: ColorFiltered(
            colorFilter: color == Colors.blue ? ColorFilter.mode(
              Colors.transparent,
              BlendMode.multiply,
            ) : ColorFilter.matrix(<double>[
              0.2126,0.7152,0.0722,0,0,
              0.2126,0.7152,0.0722,0,0,
              0.2126,0.7152,0.0722,0,0,
              0,0,0,1,0,
            ]),
            child: showChair ? Image.asset('assets/ManSitting' + index.toString() + '.png',
              height: 60,
              width: 60,
            ) :
            Icon(
              Icons.add_circle,
              color: color,
            )
        ),
      ),
    );
  }
}