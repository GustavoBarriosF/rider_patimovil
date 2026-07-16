import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TripDetails {
  String destinationAddress,
      pickupAddress,
      rideID,
      paymentMethod,
      riderName,
      riderPhone,
      riderId,
      codeCountry,
      driverId,
      driverName,
      driverPhotoURL,
      carDetails,
      carPlate,
      carPhotoURL,
      qualification,
      nameCountry;
  LatLng pickup, destination;
  double fares, executionAt;

  TripDetails({
    this.destinationAddress,
    this.pickupAddress,
    this.rideID,
    this.riderName,
    this.paymentMethod,
    this.riderPhone,
    this.pickup,
    this.destination,
    this.riderId,
    this.driverId,
    this.driverName,
    this.driverPhotoURL,
    this.carDetails,
    this.carPlate,
    this.carPhotoURL,
    this.fares,
    this.codeCountry,
    this.executionAt,
    this.nameCountry,
    this.qualification,
  });
  TripDetails.fromSnapshot(DataSnapshot snapshot) {
    rideID = snapshot.key;
    destinationAddress = snapshot.value['destination_address'];
    pickupAddress = snapshot.value['pickup_address'];
    riderName = snapshot.value['rider_name'];
    paymentMethod = snapshot.value['payment_method'];
    riderId = snapshot.value['rider_id'];
    driverId = snapshot.value['driver_id'];
    driverName = snapshot.value['driver_name'];
    carDetails = snapshot.value['car_details'];
    carPlate = snapshot.value['car_plate'];
    fares = snapshot.value['fares'];
  }
}
