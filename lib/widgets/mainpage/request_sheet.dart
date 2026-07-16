import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:patimovil_rider/utils/brand_colors.dart';
import 'package:patimovil_rider/utils/notification_messaging.dart';

class RequestSheet extends StatelessWidget {
  final double requestingSheetHeight;
  final Function onTap;
  const RequestSheet(
      {Key key, @required this.requestingSheetHeight, @required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15), topRight: Radius.circular(15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 15.0, //soften the shadow
              spreadRadius: 0.5, //extend the shadow
              offset: Offset(
                0.7, // Move to right 10 horizontally
                0.7, // Move to bottom 10 vertically
              ),
            ),
          ]),
      height: requestingSheetHeight,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 10,
            ),
            SizedBox(
              width: double.infinity,
              child: TextLiquidFill(
                text: 'Solicitando Servicio...',
                waveColor: BrandColors.colorTextSemiLight,
                boxBackgroundColor: Colors.white,
                textStyle: TextStyle(
                  fontSize: 22.0,
                  fontFamily: 'Brand-bold',
                ),
                boxHeight: 40.0,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: onTap,
              child: Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                      width: 1.0, color: BrandColors.colorLightGrayFair),
                ),
                child: Icon(
                  Icons.close,
                  size: 25,
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              width: double.infinity,
              child: Text(
                'Cancelar Servicio',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
