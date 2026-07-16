import 'package:patimovil_rider/models/near_by_driver.dart';

class FireHelper {
  static List<NearByDriver> nearByDriverList = [];

  static void removeFromList(String key) {
    int index = nearByDriverList.indexWhere((element) => element.key == key);
    nearByDriverList.removeAt(index);
  }

  static void updateNearbyLocation(NearByDriver driver) {
    int index = nearByDriverList.indexWhere((element) => element.key == driver);
    nearByDriverList[index].longitude = driver.longitude;
    nearByDriverList[index].latitude = driver.latitude;
  }
}
