import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:patimovil_rider/firebase/Auth.dart';
import 'package:patimovil_rider/helpers/fire_helper.dart';
import 'package:patimovil_rider/helpers/helper_methods.dart';
import 'package:patimovil_rider/helpers/push_notification_service.dart';
import 'package:patimovil_rider/models/direction_details.dart';
import 'package:patimovil_rider/models/near_by_driver.dart';
import 'package:patimovil_rider/models/userdata.dart';
import 'package:patimovil_rider/provider/appdata_provider.dart';
import 'package:patimovil_rider/screens/abaut.dart';
import 'package:patimovil_rider/screens/help_desk.dart';
import 'package:patimovil_rider/screens/payment_methods.dart';
import 'package:patimovil_rider/screens/scheduled_trips.dart';
import 'package:patimovil_rider/screens/dialogs.dart';
import 'package:patimovil_rider/screens/trips_history.dart';
import 'package:patimovil_rider/styles/maps_styles.dart';
import 'package:patimovil_rider/styles/styles.dart';
import 'package:patimovil_rider/utils/brand_colors.dart';
import 'package:patimovil_rider/utils/extras.dart';
import 'package:patimovil_rider/utils/glovalvariable.dart';
import 'package:patimovil_rider/utils/notification_messaging.dart';
import 'package:patimovil_rider/widgets/brand_divider.dart';
import 'package:patimovil_rider/widgets/mainpage/menu_button.dart';
import 'package:patimovil_rider/widgets/mainpage/request_sheet.dart';
import 'package:patimovil_rider/widgets/mainpage/ride_details_sheet.dart';
import 'package:patimovil_rider/widgets/mainpage/search_sheet.dart';
import 'package:patimovil_rider/widgets/progress_dialog.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:screen/screen.dart';
import 'package:toast/toast.dart';
import 'package:permission_handler/permission_handler.dart';

class MainPage extends StatefulWidget {
  static final routeName = 'mainpage';
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  double searchSheetHeight = (Platform.isIOS) ? 180 : 160;
  double rideDetailsSheetHeight = 0; // (Platform.isAndroid) ? 235 : 260
  double requestingSheetHeight = 0; // (Platform.isAndroid) ? 195 : 220
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController mapController;
  double mapBottomPadding = 0;
  List<LatLng> polylineCoordinates = [];
  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};
  BitmapDescriptor nearByIcon;
  Position currentPosition;
  DirectionDetails tripDirectionDetails;
  bool drawerCanOpen = true;
  DatabaseReference rideRef;
  DatabaseReference driverRef;
  DatabaseReference rideProgramRef;
  DatabaseReference riderInServiceRef;
  bool nearByDriversKeysLoaded = false;
  bool mDriverFound = false;
  double mRadius = 0.1;
  String mIdDriverFound;
  String photoImages;
  String photoURL;
  bool validationListener = false;
  bool _isControlState = true;
  Timer _timer;
  int seconds = 180;

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      seconds = seconds - 1;
      if (seconds == 0) {
        Toast.show("No se encontro un conductor para su servicio", context,
            duration: 6, gravity: Toast.CENTER);
        cancelRequest();
        resetApp();
      }
    });
  }

  void setupPositionLocator() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPosition = position;
    LatLng pos = LatLng(position.latitude, position.longitude);
    CameraPosition cameraPosition = CameraPosition(target: pos, zoom: 14);
    mapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String address =
        await HelperMethods.findCordinateAddress(position, context);
    print(address);

    final Uint8List bytesPickup = await toMarkerInit(address, true);

    Marker pickupMarker = Marker(
      markerId: MarkerId('pickupInit'),
      position: pos,
      icon: BitmapDescriptor.fromBytes(bytesPickup),
    );

    if (_isControlState) {
      setState(() {
        _markers.add(pickupMarker);
      });
    }

    //startGeofireListener();
  }

  void showDetailSheet() async {
    await getDirection();
    if (_isControlState) {
      setState(() {
        searchSheetHeight = 0;
        rideDetailsSheetHeight = (Platform.isAndroid) ? 235 : 260;
        mapBottomPadding = (Platform.isAndroid) ? 240 : 230;
        drawerCanOpen = false;
      });
    }
  }

  void showRequestingSheet() {
    if (_isControlState) {
      setState(() {
        rideDetailsSheetHeight = 0;
        requestingSheetHeight = (Platform.isAndroid) ? 195 : 220;
        mapBottomPadding = (Platform.isAndroid) ? 200 : 190;
        drawerCanOpen = true;
      });
    }
    startTimer();
    Navigator.pop(context);
    createRideRequest();
  }

  void queryRequest() {
    var pickup =
        Provider.of<AppDataProvider>(context, listen: false).pickupAddress;
    if (!validationListener) {
      Geofire.queryAtLocation(pickup.latitude, pickup.longitude, mRadius)
          .listen((map) async {
        if (inRejected) {
          print('este listener si me sirve 🌦️ 🌦️ 🌦️');
          mDriverFound = false;
          validationListener = false;
          mRadius = 0;
          inRejected = false;
          actionRadius();
        }
        if (map != null) {
          var callBack = map['callBack'];
          switch (callBack) {
            case Geofire.onKeyEntered:
              if (!mDriverFound) {
                mDriverFound = true;
                validationListener = true;
                mIdDriverFound = map['key'];
                rideRef.once().then((value) {
                  NotificationMessaging.sendNotification(
                      value.key,
                      mIdDriverFound,
                      'Nuevo Servicio Patimovil',
                      'El cliente ${userSnapshot.displayName} ha solicitado un servicio, desde ${pickup.placeName}');
                });
              }
              break;
            case Geofire.onKeyExited:
              break;
            case Geofire.onKeyMoved:
              break;
            case Geofire.onGeoQueryReady:
              if (!mDriverFound) {
                mRadius = mRadius + 0.1;
                actionRadius();
              }
              break;
          }
        }
      });
    }
  }

  void actionRadius() {
    if (mRadius > searchRadius) {
      print('No se encontro un conductor');
      return;
    } else {
      queryRequest();
    }
  }

  void createMarker() {
    if (nearByIcon == null) {
      ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context, size: Size(2, 2));
      BitmapDescriptor.fromAssetImage(
              imageConfiguration,
              (Platform.isIOS)
                  ? 'images/car_ios.png'
                  : 'images/car_android.png')
          .then((icon) {
        nearByIcon = icon;
      });
    }
  }

  void captureType() async {
    DialogsAlert dialogsAlert = DialogsAlert(context);
    PermissionStatus status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
    dialogsAlert.showAlertDialog(
      title: "Seleccione",
      description: "Seleccione un metodo de captura para su imagen.",
      buttonLeft: "Camara",
      actionButtonLeft: () {
        setState(() {
          photoImages = null;
        });
        _openCamera();
      },
      buttonRight: "Galeria",
      actionButtonRight: () {
        setState(() {
          photoImages = null;
        });
        _openGallery();
      },
    );
  }

  void _openCamera() async {
    File picture = await ImagePicker.pickImage(source: ImageSource.camera);
    Toast.show("Espere un momento...", context,
        duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
    picture = await compressPhotoProfile(picture);
    uploadFile(photoImage: picture, userID: userSnapshot.uid);
    Navigator.of(context).pop();
  }

  void _openGallery() async {
    var picture = await ImagePicker.pickImage(source: ImageSource.gallery);
    Toast.show("Espere un momento...", context,
        duration: 5, gravity: Toast.CENTER);
    picture = await compressPhotoProfile(picture);
    uploadFile(
      photoImage: picture,
      userID: userSnapshot.uid,
    );
    Navigator.of(context).pop();
  }

  Future<void> uploadFile({
    @required File photoImage,
    @required String userID,
  }) async {
    String dataBase = 'users/$userID';
    String imageName = "$userID-photoperfil.jpg";
    if (photoImage != null) {
      try {
        await patimovilStorage.ref('$dataBase/$imageName').putFile(photoImage);
      } on FirebaseException catch (e) {
        // e.g, e.code == 'canceled'
      }
      photoURL =
          await patimovilStorage.ref('$dataBase/$imageName').getDownloadURL();
      userSnapshot.updateProfile(photoURL: photoURL);
    }
    setState(() {
      photoImages = photoURL;
    });
    await FirebaseDatabase.instance
        .reference()
        .child('users/$userID')
        .update({'photoUrl': photoURL});
  }

  void getCurrentUserInfo() {
    PushNotificationService pushNotificationService = PushNotificationService();
    pushNotificationService.initialize(context);
    pushNotificationService.getToken();
    Auth.instance.userData.then((value) {
      userSnapshot = value;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Screen.keepOn(true);
    Geofire.initialize('driversAvailable');
    getCurrentUserInfo();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _isControlState = false;
    Geofire.stopListener();
    resetRequest();
    resetApp();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Auth.instance.userData.then((value) {
      userSnapshot = value;
      photoImages = userSnapshot.photoURL;
    });
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    createMarker();
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: scaffoldKey,
        drawer: Container(
          width: 320,
          color: Colors.white,
          child: Drawer(
            child: ListView(
              padding: EdgeInsets.all(0),
              children: <Widget>[
                Container(
                  color: Colors.white,
                  height: 215,
                  child: DrawerHeader(
                    decoration: BoxDecoration(
                      color: BrandColors.patiSecundary,
                    ),
                    child: Column(
                      children: <Widget>[
                        if (photoImages != null)
                          Container(
                            height: 80,
                            width: 80,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.circular(50),
                              image: DecorationImage(
                                image: NetworkImage(photoImages),
                                fit: BoxFit.fill,
                              ),
                            ),
                          )
                        else
                          Image.asset(
                            'images/Avatar_blanco_rosa.png',
                            height: 80,
                            width: 80,
                          ),
                        SizedBox(
                          height: 8,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            if (userSnapshot.displayName != null)
                              Text(
                                userSnapshot.displayName,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'FuturaMaxi-bold',
                                  color: Colors.white,
                                ),
                              )
                            else
                              Text(
                                'Nombre de Usuario',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'FuturaMaxi-bold',
                                  color: Colors.white,
                                ),
                              ),
                            SizedBox(
                              height: 5,
                            ),
                            FlatButton(
                              child: Text(
                                'Actualizar Foto',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontFamily: 'FuturaMaxi-book',
                                  color: Colors.white,
                                ),
                              ),
                              onPressed: () => captureType(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                ListTile(
                  leading: Image.asset(
                    'images/car_trips.png',
                    height: 30,
                    width: 30,
                  ),
                  title: Text(
                    'Mis Viajes',
                    style: kDrawerItemStyle,
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TripsHistory()));
                  },
                ),
                BrandDivider(),
                ListTile(
                  leading: Image.asset(
                    'images/tarjeta_rosa.png',
                    height: 30,
                    width: 30,
                  ),
                  title: Text(
                    'Pagos',
                    style: kDrawerItemStyle,
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PaymentMethods()));
                  },
                ),
                BrandDivider(),
                ListTile(
                  leading: Image.asset(
                    'images/car_rosa.png',
                    height: 30,
                    width: 30,
                  ),
                  title: Text(
                    'Viajes Programados',
                    style: kDrawerItemStyle,
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ScheduledTrips()));
                  },
                ),
                BrandDivider(),
                ListTile(
                  leading: Image.asset(
                    'images/herramientas_rosa.png',
                    height: 30,
                    width: 30,
                  ),
                  title: Text(
                    'Soporte',
                    style: kDrawerItemStyle,
                  ),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => HelpDesk()));
                  },
                ),
                BrandDivider(),
                ListTile(
                  leading: Image.asset(
                    'images/acerca_rosa.png',
                    height: 30,
                    width: 30,
                  ),
                  title: Text(
                    'Acerca de...',
                    style: kDrawerItemStyle,
                  ),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Abaut()));
                  },
                ),
                BrandDivider(),
                ListTile(
                  leading: Image.asset(
                    'images/cerrar_rosa.png',
                    height: 30,
                    width: 30,
                  ),
                  title: Text(
                    'Cerrar Sesión',
                    style: kDrawerItemStyle,
                  ),
                  onTap: () {
                    Auth.instance.logOut(context);
                  },
                ),
              ],
            ),
          ),
        ),
        body: Stack(
          children: <Widget>[
            ///Google Maps
            GoogleMap(
              padding: EdgeInsets.only(bottom: mapBottomPadding, top: 30),
              mapType: MapType.normal,
              myLocationEnabled: false,
              myLocationButtonEnabled: true,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: true,
              polylines: _polylines,
              markers: _markers,
//            circles: _circles,
              initialCameraPosition: googlePlex,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
                controller.setMapStyle(jsonEncode(mapsStyles));
                mapController = controller;

                setState(() {
                  mapBottomPadding = (Platform.isAndroid) ? 170 : 160;
                });

                setupPositionLocator();
              },
            ),

            ///MenuButton
            Positioned(
              top: 44,
              left: 20,
              child: MenuButton(
                drawerCanOpen: drawerCanOpen,
                onTap: () {
                  if (drawerCanOpen) {
                    scaffoldKey.currentState.openDrawer();
                  } else {
                    resetApp();
                  }
                },
              ),
            ),

            ///SearchSheet - Busqueda
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SearchSheet(
                searchSheetHeight: searchSheetHeight,
                showDetailSheet: showDetailSheet,
              ),
            ),

            ///RideDetails Sheet - Detalles del viaje
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedSize(
                  vsync: this,
                  duration: Duration(milliseconds: 150),
                  child: RideDetailsSheet(
                    rideDetailsSheetHeight: rideDetailsSheetHeight,
                    tripDirectionDetails: tripDirectionDetails,
                    onPressed: () {
                      _submit();
                    },
                  )),
            ),

            ///Request Sheet
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedSize(
                vsync: this,
                duration: Duration(milliseconds: 150),
                curve: Curves.easeIn,
                child: RequestSheet(
                  requestingSheetHeight: requestingSheetHeight,
                  onTap: () {
                    NotificationMessaging.sendNotificationCancel(
                      mIdDriverFound,
                    );
                    cancelRequest();
                    resetApp();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

//  void getToControlAppReset() {
//    if (controlCancel) {
//      cancelRequest();
//      resetApp();
//      controlCancel = false;
//    }
//  }

  Future<void> getDirection() async {
    var pickup =
        Provider.of<AppDataProvider>(context, listen: false).pickupAddress;
    var destination =
        Provider.of<AppDataProvider>(context, listen: false).destinationAddress;
    LatLng pickupLatLng = LatLng(pickup.latitude, pickup.longitude);
    LatLng destinationLatLng =
        LatLng(destination.latitude, destination.longitude);

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => ProgressDialog(
        status: 'Espere ...',
      ),
    );

    var thisDetails = await HelperMethods.getDirectionDetails(
        pickupLatLng, destinationLatLng);

    if (_isControlState) {
      setState(() {
        tripDirectionDetails = thisDetails;
      });
    }

    Navigator.pop(context);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> result =
        polylinePoints.decodePolyline(thisDetails.encodedPoints);

    polylineCoordinates.clear();
    if (result.isNotEmpty) {
      result.forEach((PointLatLng points) {
        polylineCoordinates.add(LatLng(points.latitude, points.longitude));
      });
    }

    _polylines.clear();
    _markers.clear();

    if (_isControlState) {
      setState(() {
        Polyline polyline = Polyline(
          polylineId: PolylineId('polyid'),
          color: BrandColors.patiSecundary,
          points: polylineCoordinates,
          jointType: JointType.round,
          width: 4,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          geodesic: true,
        );
        _polylines.add(polyline);
      });
    }
    LatLngBounds bounds;
    if (pickupLatLng.latitude > destinationLatLng.latitude &&
        pickupLatLng.longitude > destinationLatLng.longitude) {
      bounds =
          LatLngBounds(southwest: destinationLatLng, northeast: pickupLatLng);
    } else if (pickupLatLng.longitude > destinationLatLng.longitude) {
      bounds = LatLngBounds(
        southwest: LatLng(pickupLatLng.latitude, destinationLatLng.longitude),
        northeast: LatLng(destinationLatLng.latitude, pickupLatLng.longitude),
      );
    } else if (pickupLatLng.latitude > destinationLatLng.latitude) {
      bounds = LatLngBounds(
        southwest: LatLng(destinationLatLng.latitude, pickupLatLng.longitude),
        northeast: LatLng(pickupLatLng.latitude, destinationLatLng.longitude),
      );
    } else {
      bounds =
          LatLngBounds(southwest: pickupLatLng, northeast: destinationLatLng);
    }
    mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 90));

    final Uint8List bytesPickup = await placeToMarker(pickup, isPickup: true);

    Marker pickupMarker = Marker(
      markerId: MarkerId('pickup'),
      position: pickupLatLng,
      icon: BitmapDescriptor.fromBytes(bytesPickup),
    );

    final Uint8List bytesDestination = await placeToMarker(destination,
        isPickup: false, directionDetails: tripDirectionDetails);

    Marker destinationMarker = Marker(
      markerId: MarkerId('destination'),
      position: destinationLatLng,
      icon: BitmapDescriptor.fromBytes(bytesDestination),
    );

    if (_isControlState) {
      setState(() {
        _markers.add(pickupMarker);
        _markers.add(destinationMarker);
      });
    }

    Circle pickupCircle = Circle(
      circleId: CircleId('pickup'),
      strokeColor: Colors.green,
      strokeWidth: 3,
      radius: 12,
      center: pickupLatLng,
      fillColor: BrandColors.colorGreen,
    );

    Circle destinationCircle = Circle(
      circleId: CircleId('destination'),
      strokeColor: Colors.red,
      strokeWidth: 3,
      radius: 12,
      center: destinationLatLng,
      fillColor: BrandColors.colorAccentPurple,
    );

    if (_isControlState) {
      setState(() {
        _circles.add(pickupCircle);
        _circles.add(destinationCircle);
      });
    }
  }

  void startGeofireListener() {
    Geofire.queryAtLocation(
            currentPosition.latitude, currentPosition.longitude, 20)
        .listen((map) {
      if (map != null) {
        var callBack = map['callBack'];

        //latitude will be retrieved from map['latitude']
        //longitude will be retrieved from map['longitude']

        switch (callBack) {
          case Geofire.onKeyEntered:
            NearByDriver nearByDriver = NearByDriver();
            nearByDriver.key = map['key'];
            nearByDriver.latitude = map['latitude'];
            nearByDriver.longitude = map['longitude'];
            FireHelper.nearByDriverList.add(nearByDriver);
            if (nearByDriversKeysLoaded) {
              updateDriverOnMap();
            }
            break;

          case Geofire.onKeyExited:
            FireHelper.removeFromList(map['key']);
            updateDriverOnMap();
            break;

          case Geofire.onKeyMoved:
            // Update your key's location
            NearByDriver nearByDriver = NearByDriver();
            nearByDriver.key = map['key'];
            nearByDriver.latitude = map['latitude'];
            nearByDriver.longitude = map['longitude'];
            FireHelper.updateNearbyLocation(nearByDriver);
            FireHelper.nearByDriverList.add(nearByDriver);
            updateDriverOnMap();
            break;

          case Geofire.onGeoQueryReady:
            // All Intial Data is loaded
            nearByDriversKeysLoaded = true;
            updateDriverOnMap();
            break;
        }
      }
    });
  }

  void updateDriverOnMap() {
    if (_isControlState) {
      setState(() {
        _markers.clear();
      });
    }
    Set<Marker> tempMarkers = Set<Marker>();
    for (NearByDriver driver in FireHelper.nearByDriverList) {
      LatLng driverPosition = LatLng(driver.latitude, driver.longitude);
      Marker thisMarker = Marker(
        markerId: MarkerId('driver${driver.key}'),
        position: driverPosition,
        icon: nearByIcon,
        rotation: HelperMethods.generateRandomNumber(360),
      );

      tempMarkers.add(thisMarker);
    }
    if (_isControlState) {
      setState(() {
        _markers = tempMarkers;
      });
    }
  }

  void createRideRequestProgram(DateTime newDate) {
    validationListener = false;
    mDriverFound = false;
    Auth.instance.userData.then((User user) async {
      if (user != null) {
        String userId = user.uid;
        DatabaseReference userRef =
            FirebaseDatabase.instance.reference().child('users/$userId');
        userRef.once().then((DataSnapshot snapshot) {
          if (snapshot != null) {
            UserDataSnapshot currentUserInfo =
                UserDataSnapshot.fromSnapshot(snapshot);
            rideRef = FirebaseDatabase.instance
                .reference()
                .child('rideRequest')
                .push();
            var pickup = Provider.of<AppDataProvider>(context, listen: false)
                .pickupAddress;
            var destination =
                Provider.of<AppDataProvider>(context, listen: false)
                    .destinationAddress;
            Map pickupMap = {
              'latitude': pickup.latitude.toString(),
              'longitude': pickup.longitude.toString(),
            };
            Map destinationMap = {
              'latitude': destination.latitude.toString(),
              'longitude': destination.longitude.toString(),
            };
            Map rideMap = {
              'create_at': DateTime.now().millisecondsSinceEpoch,
              'execution_at': newDate.millisecondsSinceEpoch,
              'rider_id': currentUserInfo.id,
              'rider_name': currentUserInfo.fullName,
              'rider_phone': currentUserInfo.phone,
              'pickup_address': pickup.placeName,
              'destination_address': destination.placeName,
              'location': pickupMap,
              'destination': destinationMap,
              'payment_method': 'card',
              'driver_id': 'waiting',
              'code_country': shortNameCountry,
              'name_country': longNameCountry,
              'status': 'waiting',
              'time': tripDirectionDetails.durationText,
              'distance': tripDirectionDetails.distanceText,
              'fares': HelperMethods.estimateFares(tripDirectionDetails),
            };
            rideRef.set(rideMap);
            Map scheduledTripsMap = {
              'execution_at': newDate.millisecondsSinceEpoch,
              'rider_id': currentUserInfo.id,
              'rider_name': currentUserInfo.fullName,
              'rider_phone': currentUserInfo.phone,
              'pickup_address': pickup.placeName,
              'destination_address': destination.placeName,
              'payment_method': 'card',
              'code_country': shortNameCountry,
              'name_country': longNameCountry,
              'time': tripDirectionDetails.durationText,
              'distance': tripDirectionDetails.distanceText,
              'fares': HelperMethods.estimateFares(tripDirectionDetails),
            };
            programRideRequest(newDate, scheduledTripsMap);
          }
        });
      }
    });
  }

  void programRideRequest(DateTime newDate, Map scheduledTripsMap) {
    rideRef.once().then((DataSnapshot snapshot) {
      rideProgramRef = FirebaseDatabase.instance.reference().child(
          'TransportationSchedule/${newDate.year}/${newDate.month}/${newDate.day}/${newDate.hour}/${newDate.minute}/${newDate.second}');
      rideProgramRef.set(snapshot.key);
      DatabaseReference scheduledTrips = FirebaseDatabase.instance
          .reference()
          .child('ScheduledTrips/${userSnapshot.uid}/${snapshot.key}');
      scheduledTrips.set(scheduledTripsMap);
    });
  }

  void clientInService(idRide, idUserRider) {
    riderInServiceRef = FirebaseDatabase.instance
        .reference()
        .child('users/$idUserRider/inService');
    riderInServiceRef.set(idRide);
  }

  void createRideRequest() {
    validationListener = false;
    mDriverFound = false;
    Auth.instance.userData.then((User user) async {
      if (user != null) {
        String userId = user.uid;
        DatabaseReference userRef =
            FirebaseDatabase.instance.reference().child('users/$userId');
        userRef.once().then((DataSnapshot snapshot) {
          if (snapshot != null) {
            UserDataSnapshot currentUserInfo =
                UserDataSnapshot.fromSnapshot(snapshot);
            rideRef = FirebaseDatabase.instance
                .reference()
                .child('rideRequest')
                .push();
            var pickup = Provider.of<AppDataProvider>(context, listen: false)
                .pickupAddress;
            var destination =
                Provider.of<AppDataProvider>(context, listen: false)
                    .destinationAddress;
            Map pickupMap = {
              'latitude': pickup.latitude.toString(),
              'longitude': pickup.longitude.toString(),
            };
            Map destinationMap = {
              'latitude': destination.latitude.toString(),
              'longitude': destination.longitude.toString(),
            };
            Map rideMap = {
              'create_at': DateTime.now().millisecondsSinceEpoch,
              'execution_at': DateTime.now().millisecondsSinceEpoch,
              'rider_id': currentUserInfo.id,
              'rider_name': currentUserInfo.fullName,
              'rider_phone': currentUserInfo.phone,
              'pickup_address': pickup.placeName,
              'destination_address': destination.placeName,
              'location': pickupMap,
              'destination': destinationMap,
              'payment_method': 'card',
              'driver_id': 'waiting',
              'code_country': shortNameCountry,
              'name_country': longNameCountry,
              'status': 'waiting',
              'time': tripDirectionDetails.durationText,
              'distance': tripDirectionDetails.distanceText,
              'fares': HelperMethods.estimateFares(tripDirectionDetails),
            };
            rideRef.set(rideMap);
            // clientInService(rideRef.key, currentUserInfo.id);
            queryRequest();
          }
        });
      }
    });
  }

  void cancelRequest() async {
    validationListener = await Geofire.stopListener();
    mDriverFound = true;
    rideRef.remove();
    riderInServiceRef.remove();
    patimovilData.child('users/${userSnapshot.uid}/inService').remove();
    _timer?.cancel();
    seconds = 180;
  }

  void resetRequest() async {
    validationListener = await Geofire.stopListener();
    mDriverFound = true;
  }

  resetApp() {
    if (_isControlState) {
      setState(() {
        polylineCoordinates.clear();
        _polylines.clear();
        _markers.clear();
        _circles.clear();
        rideDetailsSheetHeight = 0;
        requestingSheetHeight = 0;
        searchSheetHeight = (Platform.isAndroid) ? 160 : 180;
        mapBottomPadding = (Platform.isAndroid) ? 170 : 160;
        drawerCanOpen = true;
      });
    }
    setupPositionLocator();
  }

  void _submit() {
    DialogsAlert dialogsAlert = DialogsAlert(context);
    dialogsAlert.showAlertDialog(
        title: "Solicitud de Servicio",
        description: "Para cuando necesitas el servicio.",
        buttonLeft: "Ahora",
        actionButtonLeft: showRequestingSheet,
        buttonRight: "Programar",
        actionButtonRight: transportationSchedule);
  }

  void _confirmProgram(DateTime dateProgram) {
    DialogsAlert dialogsAlert = DialogsAlert(context);
    dialogsAlert.showAlertDialog(
        title: "Confirmacion de Servicio",
        description:
            "Esta apunto de programar un servicio para el dia ${dateProgram.day} del mes ${dateProgram.month} del año ${dateProgram.year} a las ${dateProgram.hour}:${dateProgram.minute}, esta seguro de programar este servicio",
        buttonLeft: "Si",
        actionButtonLeft: () {
          createRideRequestProgram(dateProgram);
          Navigator.pop(context);
          Navigator.pop(context);
          resetRequest();
          resetApp();
          Toast.show("El servicio se ha programado satisfactoriamente", context,
              duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
        },
        buttonRight: "No",
        actionButtonRight: () {
          Navigator.pop(context);
          Navigator.pop(context);
          Toast.show(
              "El servicio no se ha programado, vuelva a intenrar", context,
              duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
        });
  }

  void transportationSchedule() {
    _selectTime();
    //Navigator.pop(context);
  }

  void _selectTime() {
    final DateTime now = DateTime.now();
    DateTime newDate;
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(hours: 24 * 15)),
    ).then((date) {
      if (date != null) {
        showTimePicker(
                context: context,
                initialTime: TimeOfDay(hour: now.hour, minute: now.minute))
            .then((value) {
          if (value != null) {
            newDate = DateTime(
                date.year,
                date.month,
                date.day,
                value.hour,
                value.minute,
                DateTime.now().second,
                DateTime.now().millisecond);
            if (newDate != null) {
              _confirmProgram(newDate);
            }
          }
        });
      }
    });
  }

  Future<bool> _onWillPop() {
    return showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Confirmar salida?',
                style: new TextStyle(color: Colors.black, fontSize: 20.0)),
            content: new Text(
                '¿Seguro que quieres salir de la aplicación? Toque \'Sí \' para salir \'No \' para cancelar.'),
            actions: <Widget>[
              new FlatButton(
                onPressed: () {
                  // this line exits the app.
                  exit(0);
                },
                child: new Text('Sí', style: new TextStyle(fontSize: 18.0)),
              ),
              new FlatButton(
                onPressed: () =>
                    Navigator.pop(context), // this line dismisses the dialog
                child: new Text('No', style: new TextStyle(fontSize: 18.0)),
              )
            ],
          ),
        ) ??
        false;
  }
}
