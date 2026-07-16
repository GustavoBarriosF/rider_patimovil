import 'package:flutter/material.dart';
import 'package:patimovil_rider/utils/brand_colors.dart';

class PatiOutlineButton extends StatelessWidget {
  final String title;
  final Function onPressed;
  final Color color;

  PatiOutlineButton({
    @required this.title,
    @required this.onPressed,
    @required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return OutlineButton(
        borderSide: BorderSide(color: color),
        shape: new RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(25.0),
        ),
        onPressed: onPressed,
        color: color,
        textColor: color,
        child: Container(
          height: 50.0,
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 15.0,
                fontFamily: 'FuturaMaxi-bold',
                color: color,
              ),
            ),
          ),
        ));
  }
}
