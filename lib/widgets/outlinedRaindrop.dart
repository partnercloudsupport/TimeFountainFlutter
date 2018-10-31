import 'package:flutter/material.dart';

class OutlinedRaindrop extends StatelessWidget {
  final Color color;
  OutlinedRaindrop(this.color);

  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment(0.0, 0.25), children: <Widget>[
      Center(
          child: Image(
              width: 24.0,
              image: AssetImage('assets/raindrop.png'),
              color: Color(0xFF000000))),
      Center(
          child: Image(
              width: 20.0,
              image: AssetImage('assets/raindrop.png'),
              color: color))
    ]);
  }
}
