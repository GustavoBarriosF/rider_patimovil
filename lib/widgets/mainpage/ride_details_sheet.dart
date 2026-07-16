import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:patimovil_rider/helpers/helper_methods.dart';
import 'package:patimovil_rider/models/direction_details.dart';
import 'package:patimovil_rider/utils/brand_colors.dart';
import 'package:patimovil_rider/utils/glovalvariable.dart';
import 'package:patimovil_rider/widgets/patimovil_button.dart';

class RideDetailsSheet extends StatelessWidget {
  final double rideDetailsSheetHeight;
  final DirectionDetails tripDirectionDetails;
  final Function onPressed;
  const RideDetailsSheet(
      {Key key,
      @required this.rideDetailsSheetHeight,
      @required this.tripDirectionDetails,
      @required this.onPressed})
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
            blurRadius: 15.0,
            spreadRadius: 0.5,
            offset: Offset(
              0.7,
              0.7,
            ),
          ),
        ],
      ),
      height: rideDetailsSheetHeight,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 18),
        child: Column(
          children: <Widget>[
            Container(
              width: double.infinity,
              color: BrandColors.patiAccent,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: <Widget>[
                    Image.asset(
                      'images/car_patimovil.png',
                      height: 70,
                      width: 70,
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    Column(
                      children: <Widget>[
                        Text(
                          'Patimovil',
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: 'FuturaMaxi-bold',
                            color: BrandColors.patiSecundary,
                          ),
                        ),
                        Text(
                          (tripDirectionDetails != null)
                              ? tripDirectionDetails.distanceText
                              : '',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'FuturaMaxi-book',
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Container(),
                    ),
                    Text(
                      (tripDirectionDetails != null)
                          ? '$currencyCode ${HelperMethods.estimateFares(tripDirectionDetails)}'
                          : '',
                      style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'FuturaMaxi-bold',
                          fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 22,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: <Widget>[
                  Icon(
                    FontAwesomeIcons.moneyBillAlt,
                    size: 18,
                    color: BrandColors.colorTextLight,
                  ),
                  SizedBox(
                    width: 16,
                  ),
                  Text('Efectivo'),
                  SizedBox(
                    width: 5,
                  ),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: BrandColors.colorTextLight,
                    size: 16,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 22,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: PatimovilButton(
                label: 'Solicitar Servicio',
                color: BrandColors.patiSecundary,
                fontFamily: 'FuturaMaxi-bold',
                onPressed: onPressed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
