import 'package:flutter/cupertino.dart';
import 'package:patimovil_rider/models/address.dart';

class AppDataProvider extends ChangeNotifier{
  Address pickupAddress;
  Address destinationAddress;
  void updatePickupAddress(Address pickup){
    pickupAddress = pickup;
    notifyListeners();
  }

  void updateDestinationAddress(Address destination){
    destinationAddress = destination;
    notifyListeners();
  }
}