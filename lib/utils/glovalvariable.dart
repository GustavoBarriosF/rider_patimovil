import 'dart:async';

// import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:audioplayer/audioplayer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:patimovil_rider/models/trip_details.dart';
import 'package:patimovil_rider/models/userdata.dart';

String mapKey = 'AIzaSyDvsh8o12Alob1bqbEWv2p9w4_inMur3e0';
String serverKey =
    'AAAABeDzeeg:APA91bF8-O8RCe2hW0wAuWetwg3msG9aFHL3F_e12CuIp8VtOP5zcQjdmWm-Zv-LXtQLxdxG70mHykiGTrZGuPdu8H_8LKJEUAgtr6MfKDZCvXlE8ew_JfkkQWloQqL8jA_U_dFQSoES';

bool controlCancel = false;

final CameraPosition googlePlex = CameraPosition(
  target: LatLng(9.008407, -79.506997),
  zoom: 14.4746,
);

User currentFirebaseUser, userSnapshot;
UserDataSnapshot currentUserInfo;
Position currentPosition;
DatabaseReference patimovilData = FirebaseDatabase.instance.reference();
FirebaseStorage patimovilStorage = FirebaseStorage.instance;
FirebaseMessaging patimovilMessaging = FirebaseMessaging();
bool control = true;
bool pruebaControl = true;
bool searchControl = true;
bool onFocused = false;
bool countryControl = true;
bool controlNotification = true;
bool inRejected = false;
String currencyCode;
double baseFare, perKm, perMinute;
String statusService = '';
String longNameCountry, shortNameCountry;
int searchRadius;
StreamSubscription<Position> riderPositionStream;
StreamSubscription<Position> ridePositionStream;
// final assetsAudioPlayer = AssetsAudioPlayer();
AudioPlayer audioPlayer = AudioPlayer();
