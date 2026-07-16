import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:patimovil_rider/models/trip_details.dart';
import 'package:patimovil_rider/screens/qualification_driver_page.dart';
import 'package:patimovil_rider/utils/brand_colors.dart';
import 'package:patimovil_rider/utils/glovalvariable.dart';

class TripsHistory extends StatefulWidget {
  static final routeName = 'tripsHistory';
  @override
  _TripsHistoryState createState() => _TripsHistoryState();
}

class _TripsHistoryState extends State<TripsHistory> {
  Future<List<MapEntry>> _dataFinal =
      Future<List<MapEntry>>.delayed(Duration(seconds: 3), () async {
    DateTime dateTime = userSnapshot.metadata.creationTime;
    DataSnapshot snapshot = await FirebaseDatabase.instance
        .reference()
        .child('tripsForRider/${userSnapshot.uid}')
        .orderByChild('execution_at')
        .startAt(dateTime.millisecondsSinceEpoch)
        .once();
    Map<dynamic, dynamic> json = snapshot.value;
    List<MapEntry> data = json.entries.toList();
    print('🎃 👺 🤖 ${snapshot.value} 🎃 👺 🤖');
    return data;
  });

  void qualificationDriver(String rideId, String driverId) {
    TripDetails tripDetails = TripDetails();
    DatabaseReference rideRef = patimovilData.child('rideRequest/$rideId');
    rideRef.once().then((DataSnapshot snapshot) {
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
        String carDetails = snapshot.value['car_details'].toString();
        String carPlate = snapshot.value['car_plate'].toString();
        double fares = double.parse(snapshot.value['fares'].toString());

        tripDetails.rideID = rideId;
        tripDetails.pickupAddress = pickupAddress;
        tripDetails.destinationAddress = destinationAddress;
        tripDetails.pickup = LatLng(pickupLat, pickupLng);
        tripDetails.destination = LatLng(destinationLat, destinationLng);
        tripDetails.paymentMethod = paymentMethod;
        tripDetails.riderName = riderName;
        tripDetails.riderId = riderId;
        tripDetails.driverId = driverId;
        tripDetails.driverName = driverName;
        tripDetails.carDetails = carDetails;
        tripDetails.carPlate = carPlate;
        tripDetails.fares = fares;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QualificationDriverPage(
              tripDetails: tripDetails,
              driverId: driverId,
            ),
          ),
        );
      }
    });
  }

  Widget _buildBody() {
    return FutureBuilder<List<MapEntry>>(
      future: _dataFinal,
      builder: (contetx, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.data == null) {
            return Center(child: Text('No encontramos datos'));
          } else if (snapshot.hasError) {
            return Center(child: Text('Something went wrong'));
          }
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                DateTime fecha = DateTime.fromMillisecondsSinceEpoch(
                    snapshot.data[index].value['execution_at']);
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: BrandColors.patiSecundary),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        children: <Widget>[
                          Container(
                            width: double.infinity,
                            child: Text(
                              DateFormat.yMd().add_Hm().format(fecha),
                            ),
                          ),
                          Row(
                            children: <Widget>[
                              Container(
                                height: 80,
                                width: 80,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white),
                                  borderRadius: BorderRadius.circular(50),
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      snapshot
                                          .data[index].value['driver_photoURL'],
                                    ),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    snapshot.data[index].value['driver_name'],
                                  ),
                                  Text(
                                    snapshot.data[index].value['car_details'],
                                  ),
                                  Container(
                                    height: 30,
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                          width: 1,
                                          color: BrandColors.patiPrimary,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(30)),
                                    child: FlatButton(
                                      child: Row(
                                        children: [
                                          Text(
                                            snapshot.data[index]
                                                .value['qualification'],
                                          ),
                                          Icon(
                                            Icons.star,
                                            color:
                                                BrandColors.patiSecundaryDark,
                                          ),
                                        ],
                                      ),
                                      onPressed: () {
                                        if (snapshot.data[index]
                                                .value['qualification'] ==
                                            'null') {
                                          qualificationDriver(
                                            snapshot.data[index].key,
                                            snapshot
                                                .data[index].value['driver_id'],
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Image.asset(
                                'images/gps_rosa.png',
                                width: 20,
                                height: 20,
                              ),
                              Text(
                                  snapshot.data[index].value['pickup_address']),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: <Widget>[
                              Image.asset(
                                'images/point_pasajero.png',
                                width: 20,
                                height: 20,
                              ),
                              Text(snapshot
                                  .data[index].value['destination_address']),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Text(
                                    'País: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: BrandColors.patiSecundary,
                                    ),
                                  ),
                                  Text(snapshot
                                      .data[index].value['name_country']),
                                ],
                              ),
                              SizedBox(width: 10),
                              Row(
                                children: <Widget>[
                                  Text(
                                    'Valor del Servicio: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: BrandColors.patiSecundary,
                                    ),
                                  ),
                                  Text(
                                      '$currencyCode ${snapshot.data[index].value['fares']}'),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Viajes'),
        backgroundColor: BrandColors.patiSecundary,
      ),
      body: Center(
        child: _buildBody(),
      ),
    );
  }
}
