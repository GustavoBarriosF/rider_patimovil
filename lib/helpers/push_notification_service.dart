import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:patimovil_rider/models/trip_details.dart';
import 'package:patimovil_rider/screens/chat_page.dart';
import 'package:patimovil_rider/screens/map_client_booking_page.dart';
import 'package:patimovil_rider/utils/glovalvariable.dart';
import 'package:patimovil_rider/widgets/progress_dialog.dart';

class PushNotificationService {
  final FirebaseMessaging fcm = FirebaseMessaging();
  Future initialize(BuildContext context) async {
    if (Platform.isIOS) {
      fcm.requestNotificationPermissions(IosNotificationSettings());
    }

    fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        switch (getServiceID(message)) {
          case 'DriverCancel':
            print('El Conductor Cancelo el servicio');
            patimovilData.child('users/${userSnapshot.uid}/inService').remove();
            break;
          case 'DriverAccept':
            notificationResponse(context, getRideID(message));
            statusService = 'accepted';
            break;
          case 'DriverArrived':
            statusService = 'arrived';
            break;
          case 'DriverInService':
            statusService = 'onTrip';
            break;
          case 'DriverEndService':
            statusService = 'ended';
            break;
          case 'DriverRejected':
            inRejected = true;
            break;
          case 'chat':
            statusService = 'Chat';
            break;
        }
      },
      onLaunch: (Map<String, dynamic> message) async {
        // switch (getServiceID(message)) {
        //   case 'DriverCancel':
        //     print('El Conductor Cancelo el servicio');
        //     patimovilData.child('users/${userSnapshot.uid}/inService').remove();
        //     break;
        //   case 'DriverAccept':
        //     notificationResponse(context, getRideID(message));
        //     statusService = 'accepted';
        //     break;
        //   case 'DriverArrived':
        //     statusService = 'arrived';
        //     break;
        //   case 'DriverInService':
        //     statusService = 'onTrip';
        //     break;
        //   case 'DriverEndService':
        //     statusService = 'ended';
        //     break;
        //   case 'DriverRejected':
        //     inRejected = true;
        //     break;
        //   case 'chat':
        //     statusService = 'Chat';
        //     break;
        // }
      },
      onResume: (Map<String, dynamic> message) async {
        switch (getServiceID(message)) {
          case 'DriverCancel':
            print('El Conductor Cancelo el servicio');
            patimovilData.child('users/${userSnapshot.uid}/inService').remove();
            break;
          case 'DriverAccept':
            notificationResponse(context, getRideID(message));
            statusService = 'accepted';
            break;
          case 'DriverArrived':
            statusService = 'arrived';
            break;
          case 'DriverInService':
            statusService = 'onTrip';
            break;
          case 'DriverEndService':
            statusService = 'ended';
            break;
          case 'DriverRejected':
            inRejected = true;
            break;
          case 'chat':
            statusService = 'Chat';
            break;
        }
      },
    );
  }

  void getToken() async {
    String token = await fcm.getToken();
    DatabaseReference tokenRef =
        patimovilData.child('users/${userSnapshot.uid}/token');
    tokenRef.set(token);
    fcm.subscribeToTopic('alldrivers');
    fcm.subscribeToTopic('alluser');
  }

  String getRideID(Map<String, dynamic> message) {
    String rideID = '';
    if (Platform.isAndroid) {
      rideID = message['data']['ride_id'];
    } else {
      rideID = message['ride_id'];
    }
    return rideID;
  }

  String getServiceID(Map<String, dynamic> message) {
    String serviceID = '';
    if (Platform.isAndroid) {
      serviceID = message['data']['id_message'];
    } else {
      serviceID = message['id_message'];
    }
    return serviceID;
  }

  void openChat(String newRideId, BuildContext context) {
    DatabaseReference rideRef = patimovilData.child('rideRequest/$newRideId');
    rideRef.once().then((DataSnapshot snapshot) {
      if (snapshot.value != null) {
        String riderId = snapshot.value['rider_id'].toString();
        String driverId = snapshot.value['driver_id'].toString();
        String chatRoomId = '$riderId-$driverId';
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChatPage(
              chatRoomId: chatRoomId,
              idNewTrip: newRideId,
              idUser: driverId,
            ),
          ),
        );
      }
    });
  }

  void notificationResponse(BuildContext context, String rideID) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => ProgressDialog(
        status: 'Obteniendo detalles',
      ),
    );
    DatabaseReference rideRef = patimovilData.child('rideRequest/$rideID');
    rideRef.once().then((DataSnapshot snapshot) {
      Navigator.pop(context);
      Navigator.pop(context);
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

        tripDetails.rideID = rideID;
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

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) => MapClientBookingPage(
            mIdDriverFound: driverId,
            tripDetails: tripDetails,
          ),
        );
      }
    });
  }
}
