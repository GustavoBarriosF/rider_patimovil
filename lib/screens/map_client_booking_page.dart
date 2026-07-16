import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:patimovil_rider/helpers/database_methods.dart';
import 'package:patimovil_rider/helpers/helper_methods.dart';
import 'package:patimovil_rider/helpers/map_kit_helper.dart';
import 'package:patimovil_rider/models/posiciones.dart';
import 'package:patimovil_rider/models/trip_details.dart';
import 'package:patimovil_rider/screens/chat_page.dart';
import 'package:patimovil_rider/screens/qualification_driver_page.dart';
import 'package:patimovil_rider/styles/maps_styles.dart';
import 'package:patimovil_rider/utils/brand_colors.dart';
import 'package:patimovil_rider/utils/extras.dart';
import 'package:patimovil_rider/utils/glovalvariable.dart';
import 'package:patimovil_rider/widgets/bottom_view.dart';
import 'package:patimovil_rider/widgets/circle_button.dart';
import 'package:patimovil_rider/widgets/progress_dialog.dart';
import 'package:screen/screen.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:toast/toast.dart';

class MapClientBookingPage extends StatefulWidget {
  final String mIdDriverFound;
  final TripDetails tripDetails;
  MapClientBookingPage({this.mIdDriverFound, this.tripDetails});
  @override
  _MapClientBookingPageState createState() => _MapClientBookingPageState();
}

class _MapClientBookingPageState extends State<MapClientBookingPage> {
  GoogleMapController rideMapController;
  Completer<GoogleMapController> _controller = Completer();
  Geolocator geoLocator = Geolocator();
  Set<Marker> _markers = Set<Marker>();
  Set<Polyline> _polylines = Set<Polyline>();
  BitmapDescriptor movingMarkerIcon;
  bool _isControlState = true;
  List<LatLng> polylineCoordinates = [];
  DatabaseReference riderInServiceRef;
  DatabaseReference locationDriverRef;
  StreamSubscription<Event> locationDriverlisten;
  BitmapDescriptor markerDriver;
  LatLng oldPosition = LatLng(0, 0);

  void createMarker() {
    if (movingMarkerIcon == null) {
      ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context, size: Size(2, 2));
      BitmapDescriptor.fromAssetImage(
              imageConfiguration,
              (Platform.isIOS)
                  ? 'images/car_pasajero.png'
                  : 'images/car_pasajero.png')
          .then((icon) {
        movingMarkerIcon = icon;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    Screen.keepOn(true);
    Geofire.initialize('inService');
    locationDriverRef =
        patimovilData.child('driverInService/${this.widget.mIdDriverFound}');
    locationDriverlisten = locationDriverRef.onValue.listen(_listenDriver);
    // locationDriverlisten =
    //     locationDriverRef.onChildChanged.listen(_listenDriver);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _isControlState = false;
    Geofire.stopListener();
    locationDriverlisten.cancel();
    super.dispose();
  }

  void _listenDriver(Event event) async {
    DataSnapshot valores = event.snapshot;
    Posiciones posiciones = Posiciones.fromSnapshot(valores);
    markerDriver = await createMarkerDriver('images/car_pasajero.png');
    addMarkerDriver(
      'diverInService',
      LatLng(posiciones.latitud, posiciones.longitud),
      this.widget.tripDetails.driverName,
      this.widget.tripDetails.carPlate,
      markerDriver,
    );
  }

  Future<BitmapDescriptor> createMarkerDriver(String path) async {
    ImageConfiguration configuration = ImageConfiguration();
    BitmapDescriptor bitmapDescriptor =
        await BitmapDescriptor.fromAssetImage(configuration, path);
    return bitmapDescriptor;
  }

  void addMarkerDriver(
    String markerId,
    LatLng positionDriver,
    String title,
    String descriptor,
    BitmapDescriptor iconMarker,
  ) {
    double rotation = MapKitHelper.getMarkerRotation(
      oldPosition.latitude,
      oldPosition.longitude,
      positionDriver.latitude,
      positionDriver.longitude,
    );
    MarkerId id = MarkerId(markerId);
    Marker markerMovingDriver = Marker(
      markerId: id,
      icon: iconMarker,
      position: positionDriver,
      rotation: rotation,
      infoWindow: InfoWindow(title: title, snippet: descriptor),
    );
    setState(() {
      CameraPosition cp = CameraPosition(
        target: positionDriver,
        zoom: 18,
      );
      rideMapController.animateCamera(CameraUpdate.newCameraPosition(cp));
      _markers.removeWhere((marker) => marker.markerId.value == markerId);
      _markers.add(markerMovingDriver);
    });
    oldPosition = positionDriver;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: SlidingUpPanel(
          panel: BottomView(
            mIdDriverFound: widget.mIdDriverFound,
            tripDetails: widget.tripDetails,
          ),
          minHeight: 110,
          body: Stack(
            children: <Widget>[
              GoogleMap(
                padding: EdgeInsets.only(bottom: 130),
                myLocationEnabled: false,
                myLocationButtonEnabled: false,
                compassEnabled: true,
                mapToolbarEnabled: true,
                trafficEnabled: false,
                markers: _markers,
                polylines: _polylines,
                initialCameraPosition: googlePlex,
                onMapCreated: (GoogleMapController controller) async {
                  _controller.complete(controller);
                  controller.setMapStyle(jsonEncode(mapsStyles));
                  rideMapController = controller;
                  getLocationUpdate();
                },
              ),
              Positioned(
                right: 15,
                bottom: 250,
                child: CircleButton(
                  onTap: () {
                    startChat(
                      context,
                      userSnapshot.uid,
                      widget.mIdDriverFound,
                    );
                  },
                  icons: Icon(
                    Icons.message_rounded,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void clientInService(idRide, idUserRider) {
    riderInServiceRef = FirebaseDatabase.instance
        .reference()
        .child('users/$idUserRider/inService');
    riderInServiceRef.set(idRide);
  }

  void getLocationUpdate() {
    riderPositionStream = Geolocator.getPositionStream(
            desiredAccuracy: LocationAccuracy.bestForNavigation)
        .listen((Position position) async {
      LatLng pos = LatLng(position.latitude, position.longitude);
      final Uint8List bytesPickup = await loadAsset(
        'images/point_pasajero.png',
        width: 50,
        height: 65,
      );
      final customIconPickup = BitmapDescriptor.fromBytes(bytesPickup);
      Marker movingMarker = Marker(
        markerId: MarkerId('riderMoving'),
        position: widget.tripDetails.pickup,
        icon: customIconPickup,
        infoWindow: InfoWindow(title: 'Ubicacion Actual'),
      );
      if (_isControlState) {
        setState(() {
          if (statusService == 'accepted') {
            clientInService(widget.tripDetails.rideID, userSnapshot.uid);
            patimovilData
                .child(
                    'rideRequest/${widget.tripDetails.rideID}/driver_location')
                .once()
                .then(
              (DataSnapshot snapshot) {
                double driverLocationLat =
                    double.parse(snapshot.value['latitude'].toString());
                double driverLocationLng =
                    double.parse(snapshot.value['longitude'].toString());
                LatLng driverLocation =
                    LatLng(driverLocationLat, driverLocationLng);
                getDirection(driverLocation, widget.tripDetails.pickup);
              },
            );
            Toast.show(
              'El servicio a sido aceptado por el conductor ${widget.tripDetails.driverName} el estatus de su servicio a cambiado y el vehiculo se encuentra en camino',
              context,
              duration: 8,
              gravity: Toast.CENTER,
            );
            statusService = 'Espera';
          } else if (statusService == 'arrived') {
            _polylines.clear();
            _markers.clear();
            CameraPosition cp =
                CameraPosition(target: widget.tripDetails.pickup, zoom: 17);
            rideMapController.animateCamera(CameraUpdate.newCameraPosition(cp));
            _markers.removeWhere(
                (marker) => marker.markerId.value == 'riderMoving');
            _markers.add(movingMarker);
            Toast.show(
              'El vehiculo ha llegado y esta a la espera.',
              context,
              duration: 8,
              gravity: Toast.CENTER,
            );
            statusService = 'Espera';
          } else if (statusService == 'onTrip') {
            getDirection(
              widget.tripDetails.pickup,
              widget.tripDetails.destination,
            );
            Toast.show(
              'El estado de su servicio ha cambiado a iniciado, el vehiculo se dirige a ${widget.tripDetails.destinationAddress}.',
              context,
              duration: 8,
              gravity: Toast.CENTER,
            );
            statusService = 'Espera';
          } else if (statusService == 'ended') {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => QualificationDriverPage(
                tripDetails: widget.tripDetails,
                driverId: widget.mIdDriverFound,
              ),
            ));
            statusService = 'Espera';
          } else if (statusService == 'Chat') {
            if (controlNotification) {
              String chatRoomId =
                  '${userSnapshot.uid}-${widget.mIdDriverFound}';
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ChatPage(
                    chatRoomId: chatRoomId,
                    idNewTrip: widget.tripDetails.rideID,
                    idUser: widget.mIdDriverFound,
                  ),
                ),
              );
            }
            statusService = 'Espera';
          }
        });
      }
    });
  }

  Future<void> getDirection(LatLng initialLatLng, LatLng finalLatLng) async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => ProgressDialog(
        status: 'Espere ...',
      ),
    );

    var thisDetails =
        await HelperMethods.getDirectionDetails(initialLatLng, finalLatLng);

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
    if (initialLatLng.latitude > finalLatLng.latitude &&
        initialLatLng.longitude > finalLatLng.longitude) {
      bounds = LatLngBounds(southwest: finalLatLng, northeast: initialLatLng);
    } else if (initialLatLng.longitude > finalLatLng.longitude) {
      bounds = LatLngBounds(
        southwest: LatLng(initialLatLng.latitude, finalLatLng.longitude),
        northeast: LatLng(finalLatLng.latitude, initialLatLng.longitude),
      );
    } else if (initialLatLng.latitude > finalLatLng.latitude) {
      bounds = LatLngBounds(
        southwest: LatLng(finalLatLng.latitude, initialLatLng.longitude),
        northeast: LatLng(initialLatLng.latitude, finalLatLng.longitude),
      );
    } else {
      bounds = LatLngBounds(southwest: initialLatLng, northeast: finalLatLng);
    }
    rideMapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 90));

    final Uint8List bytesPickup =
        await placeToMarkerBooking(widget.tripDetails, isPickup: true);

    Marker pickupMarker = Marker(
      markerId: MarkerId('pickup'),
      position: initialLatLng,
      icon: BitmapDescriptor.fromBytes(bytesPickup),
    );

    final Uint8List bytesDestination = await placeToMarkerBooking(
        widget.tripDetails,
        isPickup: false,
        directionDetails: thisDetails);

    Marker destinationMarker = Marker(
      markerId: MarkerId('destination'),
      position: finalLatLng,
      icon: BitmapDescriptor.fromBytes(bytesDestination),
    );

    if (_isControlState) {
      setState(() {
        _markers.add(pickupMarker);
        _markers.add(destinationMarker);
      });
    }
  }

  void startChat(BuildContext context, String riderId, String driverId) {
    List<String> users = [riderId, driverId];
    String chatRoomId = '$riderId-$driverId';
    Map<String, dynamic> chatRoomMap = {
      'users': users,
      'ChatRoomId': chatRoomId,
    };
    DatabaseMethods().createChatRoom(chatRoomId, chatRoomMap);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatPage(
          chatRoomId: chatRoomId,
          idNewTrip: widget.tripDetails.rideID,
          idUser: driverId,
        ),
      ),
    );
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
