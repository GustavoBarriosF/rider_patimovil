import 'package:flutter/material.dart';

class CircleButton extends StatelessWidget {
  final Color backgroundColor;
  final Function onTap;
  final Icon icons;

  const CircleButton({
    Key key,
    this.backgroundColor = Colors.white,
    @required this.onTap,
    @required this.icons,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 5.0,
                  spreadRadius: 0.5,
                  offset: Offset(
                    0.7,
                    0.7,
                  ),
                ),
              ]),
          child: CircleAvatar(
              backgroundColor: backgroundColor, radius: 20, child: icons),
        ),
      ),
    );
  }
}
