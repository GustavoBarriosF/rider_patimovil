import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:patimovil_rider/models/trip_details.dart';
import 'package:patimovil_rider/screens/mainpage.dart';
import 'package:patimovil_rider/utils/brand_colors.dart';
import 'package:patimovil_rider/utils/glovalvariable.dart';
import 'package:patimovil_rider/widgets/patimovil_button.dart';

class QualificationDriverPage extends StatefulWidget {
  final TripDetails tripDetails;
  final String driverId;
  QualificationDriverPage({this.tripDetails, this.driverId});
  @override
  _QualificationDriverPageState createState() =>
      _QualificationDriverPageState();
}

class _QualificationDriverPageState extends State<QualificationDriverPage> {
  DatabaseReference rideRef;
  DatabaseReference ratingRef;
  double qualification;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: SafeArea(
          child: Container(
              width: double.infinity,
              height: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    alignment: Alignment.bottomCenter,
                    width: double.infinity,
                    height: 130,
                    child: Text(
                      'VIAJE FINALIZADO',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        fontFamily: 'FuturaMaxi-bold',
                        color: BrandColors.patiSecundary,
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Desde',
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: 'FuturaMaxi-bold',
                            color: BrandColors.patiSecundary,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          widget.tripDetails.pickupAddress,
                          style: TextStyle(
                            fontFamily: 'FuturaMaxi-book',
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          'Hasta',
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: 'FuturaMaxi-bold',
                            color: BrandColors.patiSecundary,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          widget.tripDetails.destinationAddress,
                          style: TextStyle(
                            fontFamily: 'FuturaMaxi-book',
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          'Valor del Servicio',
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: 'FuturaMaxi-bold',
                            color: BrandColors.patiSecundary,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          'USD\$ ${widget.tripDetails.fares}',
                          style: TextStyle(
                            fontFamily: 'FuturaMaxi-book',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: 80,
                    child: Center(
                      child: RatingBar.builder(
                        initialRating: 0,
                        minRating: 0,
                        itemSize: 55,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        unratedColor: BrandColors.patiAccent,
                        itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                        itemBuilder: (context, _) => Icon(
                          Icons.star,
                          color: BrandColors.patiSecundary,
                        ),
                        onRatingUpdate: (rating) {
                          print(rating);
                          qualification = rating;
                        },
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: 120,
                    alignment: Alignment.topCenter,
                    padding: const EdgeInsets.all(16.0),
                    child: PatimovilButton(
                      color: BrandColors.patiSecundary,
                      label: 'Calificar Conductor',
                      onPressed: qualificationDriver,
                      fontFamily: 'FuturaMaxi-bold',
                    ),
                  ),
                ],
              )),
        ),
      ),
    );
  }

  void qualificationDriver() {
    patimovilData.child('users/${userSnapshot.uid}/inService').remove();
    rideRef = patimovilData.child('rideRequest/${widget.tripDetails.rideID}');
    rideRef.child('qualification').set(qualification.toString());
    FirebaseDatabase.instance
        .reference()
        .child('tripsForRider/${userSnapshot.uid}/${widget.tripDetails.rideID}')
        .child('qualification')
        .set(qualification.toString());
    FirebaseDatabase.instance
        .reference()
        .child(
            'tripsForDriver/${widget.tripDetails.driverId}/${widget.tripDetails.rideID}')
        .child('qualification')
        .set(qualification.toString());
    cumulativeRating();
    Navigator.pushNamedAndRemoveUntil(
        context, MainPage.routeName, (route) => false);
  }

  void cumulativeRating() {
    ratingRef = patimovilData.child('drivers/${widget.driverId}/rating');
    ratingRef.once().then((DataSnapshot snapshot) {
      if (snapshot.value != null) {
        double oldRating = double.parse(snapshot.value.toString());
        double adjustedRating = (qualification + oldRating) / 2;
        ratingRef.set(adjustedRating.toString());
      } else {
        double adjustedRating = qualification;
        ratingRef.set(adjustedRating.toString());
      }
    });
  }

  Future<bool> _onWillPop() {
    return showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Alerta',
                style: new TextStyle(color: Colors.black, fontSize: 20.0)),
            content: new Text('La accion que esta haciendo no es permitida.'),
            actions: <Widget>[
              new FlatButton(
                onPressed: () =>
                    Navigator.pop(context), // this line dismisses the dialog
                child: new Text('Ok', style: new TextStyle(fontSize: 18.0)),
              )
            ],
          ),
        ) ??
        false;
  }
}
