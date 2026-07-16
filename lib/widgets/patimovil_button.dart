import 'package:flutter/material.dart';

class PatimovilButton extends StatelessWidget {
  final String label;
  final Color color;
  final Function onPressed;
  final Color textColor;
  final double heightButton;
  final String fontFamily;

  const PatimovilButton({
    Key key,
    @required this.label,
    this.color,
    @required this.onPressed,
    this.textColor,
    this.heightButton,
    this.fontFamily,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      onPressed: onPressed,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      color: (color != null) ? color : Colors.black,
      textColor: (textColor != null) ? textColor : Colors.white,
      child: Container(
        height: (heightButton != null) ? heightButton : 50,
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontFamily: (fontFamily != null) ? fontFamily : 'Brand-bold',
            ),
          ),
        ),
      ),
    );
  }
}
