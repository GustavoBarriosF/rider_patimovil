import 'dart:math';

import 'package:connectivity/connectivity.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:patimovil_rider/helpers/request_helper.dart';
import 'package:patimovil_rider/models/address.dart';
import 'package:patimovil_rider/models/direction_details.dart';
import 'package:patimovil_rider/provider/appdata_provider.dart';
import 'package:patimovil_rider/utils/glovalvariable.dart';
import 'package:provider/provider.dart';

class HelperMethods {
  static Future<String> findCordinateAddress(
      Position position, BuildContext context) async {
    String placeAddress = '';
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult != ConnectivityResult.mobile &&
        connectivityResult != ConnectivityResult.wifi) {
      return placeAddress;
    }
    String url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey';
    var response = await RequestHelper.getRequest(url);
    if (response != 'failed') {
      placeAddress = response['results'][0]['formatted_address'];
      Address pickupAddress = Address();
      pickupAddress.longitude = position.longitude;
      pickupAddress.latitude = position.latitude;
      pickupAddress.placeName = placeAddress;
      Provider.of<AppDataProvider>(context, listen: false)
          .updatePickupAddress(pickupAddress);
      if (countryControl) {
        List dondeEsta = response['results'];
        int longitud = dondeEsta.length;
        List busqCodCountry =
            response['results'][longitud - 2]['address_components'];
        int posiCodCountry = busqCodCountry.length;
        longNameCountry = response['results'][longitud - 2]
            ['address_components'][posiCodCountry - 1]['long_name'];
        shortNameCountry = response['results'][longitud - 2]
            ['address_components'][posiCodCountry - 1]['short_name'];
        loadingData(shortNameCountry);
        print('🏓 🏓 $shortNameCountry 🏓 🏓');
        countryControl = false;
      }
    }
    return placeAddress;
  }

  static Future<DirectionDetails> getDirectionDetails(
      LatLng startPosition, LatLng endPosition) async {
    String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${startPosition.latitude},${startPosition.longitude}&destination=${endPosition.latitude},${endPosition.longitude}&key=$mapKey&mode=driving';
    var response = await RequestHelper.getRequest(url);
    if (response == 'failed') {
      return null;
    }
    DirectionDetails directionDetails = DirectionDetails();
    directionDetails.durationText =
        response['routes'][0]['legs'][0]['duration']['text'];
    directionDetails.distanceText =
        response['routes'][0]['legs'][0]['distance']['text'];
    directionDetails.durationValue =
        response['routes'][0]['legs'][0]['duration']['value'];
    directionDetails.distanceValue =
        response['routes'][0]['legs'][0]['distance']['value'];

    directionDetails.encodedPoints =
        response['routes'][0]['overview_polyline']['points'];

    return directionDetails;
  }

  static double estimateFares(DirectionDetails details) {
    int decimals = 2;
    int fac = pow(10, decimals);
    double distanceFare = (details.distanceValue / 1000) * perKm;
    double timeFare = (details.durationValue / 60) * perMinute;
    double subtotal = distanceFare + timeFare + baseFare + 1.5;
    if (subtotal < baseFare) {
      return (baseFare * fac).round() / fac;
    } else {
      return (subtotal * fac).round() / fac;
    }
  }

  static double generateRandomNumber(int max) {
    var randomGenerator = Random();
    int radInt = randomGenerator.nextInt(max);

    return radInt.toDouble();
  }
}

void loadingData(String codeCountry) {
  patimovilData
      .child('Admin/Country/$codeCountry')
      .once()
      .then((DataSnapshot snapshot) {
    baseFare = double.parse(snapshot.value['base_fare'].toString());
    perKm = double.parse(snapshot.value['per_km'].toString());
    perMinute = double.parse(snapshot.value['per_minute'].toString());
    currencyCode = snapshot.value['currency_code'].toString();
    searchRadius = snapshot.value['radius'];
  });
}
