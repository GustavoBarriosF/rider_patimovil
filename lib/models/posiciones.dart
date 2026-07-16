import 'package:firebase_database/firebase_database.dart';

class Posiciones {
  double latitud;
  double longitud;

  Posiciones(this.latitud, this.longitud);

  Posiciones.fromSnapshot(DataSnapshot snapshot) {
    latitud = snapshot.value['l'][0];
    longitud = snapshot.value['l'][1];
  }
}
