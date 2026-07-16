import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:patimovil_rider/helpers/push_notification_service.dart';
import 'package:patimovil_rider/models/trip_details.dart';
import 'package:patimovil_rider/screens/mainpage.dart';
import 'package:patimovil_rider/screens/map_client_booking_page.dart';
import 'package:patimovil_rider/utils/brand_colors.dart';
import 'package:patimovil_rider/utils/glovalvariable.dart';
import 'package:patimovil_rider/widgets/patimovil_button.dart';

class RecoverProcessPage extends StatefulWidget {
  final String idRide;

  const RecoverProcessPage({this.idRide});

  @override
  _RecoverProcessPageState createState() => _RecoverProcessPageState();
}

class _RecoverProcessPageState extends State<RecoverProcessPage> {
  void recoveryService() {
    DatabaseReference detailsRef =
        patimovilData.child('rideRequest/${this.widget.idRide}');
    detailsRef.once().then((DataSnapshot snapshot) {
      statusService = snapshot.value['status'].toString();
      if (snapshot.value != null) {
        double pickupLat =
            double.parse(snapshot.value['location']['latitude'].toString());
        double pickupLng =
            double.parse(snapshot.value['location']['longitude'].toString());
        String pickupAddress = snapshot.value['pickup_address'].toString();
        double destinationLat =
            double.parse(snapshot.value['destination']['latitude'].toString());
        double destinationLng =
            double.parse(snapshot.value['destination']['longitude'].toString());
        String destinationAddress =
            snapshot.value['destination_address'].toString();
        String paymentMethod = snapshot.value['payment_method'].toString();
        String riderName = snapshot.value['rider_name'].toString();
        String riderId = snapshot.value['rider_id'].toString();
        String driverId = snapshot.value['driver_id'].toString();
        String driverName = snapshot.value['driver_name'].toString();
        String driverPhotoURL = snapshot.value['driver_photoURL'].toString();
        String carDetails = snapshot.value['car_details'].toString();
        String carPlate = snapshot.value['car_plate'].toString();
        String carPhotoURL = snapshot.value['vehicle_photoURL'].toString();
        double fares = double.parse(snapshot.value['fares'].toString());
        control = false;

        TripDetails tripDetails = TripDetails();

        tripDetails.rideID = this.widget.idRide;
        tripDetails.pickupAddress = pickupAddress;
        tripDetails.destinationAddress = destinationAddress;
        tripDetails.pickup = LatLng(pickupLat, pickupLng);
        tripDetails.destination = LatLng(destinationLat, destinationLng);
        tripDetails.paymentMethod = paymentMethod;
        tripDetails.riderName = riderName;
        tripDetails.riderId = riderId;
        tripDetails.driverId = driverId;
        tripDetails.driverName = driverName;
        tripDetails.driverPhotoURL = driverPhotoURL;
        tripDetails.carDetails = carDetails;
        tripDetails.carPlate = carPlate;
        tripDetails.carPhotoURL = carPhotoURL;
        tripDetails.fares = fares;

        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (builder) => MapClientBookingPage(
                      tripDetails: tripDetails,
                      mIdDriverFound: driverId,
                    )),
            (route) => false);
      }
    });
  }

  void activeNotificationService() {
    PushNotificationService pushNotificationService = PushNotificationService();
    pushNotificationService.initialize(context);
    pushNotificationService.getToken();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 150,
              height: 150,
              child: Image.asset('images/LogoBlancoPatimovil.png'),
            ),
            Padding(
              padding: const EdgeInsets.all(25),
              child: Text(
                'Hola ${userSnapshot.displayName}, usted tiene un servicio en proceso y no podra continuar hasta no finalizar el servicio actual',
                style: TextStyle(
                  fontFamily: 'FuturaMaxi-bold',
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
              child: PatimovilButton(
                label: 'Recuperar Servicio',
                onPressed: () {
                  activeNotificationService();
                  recoveryService();
                },
                color: BrandColors.patiSecundary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
