import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:patimovil_rider/screens/dialogs.dart';
import 'package:patimovil_rider/utils/brand_colors.dart';
import 'package:patimovil_rider/utils/glovalvariable.dart';
import 'package:intl/intl.dart';
import 'package:patimovil_rider/widgets/patimovil_button.dart';

class ScheduledTrips extends StatefulWidget {
  static final routeName = 'scheduledTrips';
  ScheduledTrips({Key key}) : super(key: key);

  @override
  _ScheduledTripsState createState() => _ScheduledTripsState();
}

class _ScheduledTripsState extends State<ScheduledTrips> {
  Future<List<MapEntry>> _dataFinal =
      Future<List<MapEntry>>.delayed(Duration(seconds: 3), () async {
    DataSnapshot snapshot = await FirebaseDatabase.instance
        .reference()
        .child('ScheduledTrips/${userSnapshot.uid}')
        .once();
    Map<dynamic, dynamic> json = snapshot.value;
    List<MapEntry> data = json.entries.toList();
    return data;
  });

  Widget _buildBodyScheduledTrips() {
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
                          Row(
                            children: <Widget>[
                              Text(
                                'Origen: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: BrandColors.patiSecundary,
                                ),
                              ),
                              Text(
                                  snapshot.data[index].value['pickup_address']),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Text(
                                'Destino: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: BrandColors.patiSecundary,
                                ),
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
                                    'Fecha: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: BrandColors.patiSecundary,
                                    ),
                                  ),
                                  Text(DateFormat.yMd().add_Hm().format(fecha)),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Text(
                                    'Distancia: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: BrandColors.patiSecundary,
                                    ),
                                  ),
                                  Text(snapshot.data[index].value['distance']),
                                ],
                              ),
                              SizedBox(width: 10),
                              Row(
                                children: <Widget>[
                                  Text(
                                    'Tiempo: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: BrandColors.patiSecundary,
                                    ),
                                  ),
                                  Text(snapshot.data[index].value['time']),
                                ],
                              ),
                            ],
                          ),
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
                          PatimovilButton(
                            color: BrandColors.patiSecundary,
                            label: 'Cancelar',
                            onPressed: () {
                              DialogsAlert dialogsAlert = DialogsAlert(context);
                              dialogsAlert.showAlertDialog(
                                title: "Alerta",
                                description:
                                    "Esta apunto de cancelar el servicio ¿Esta seguro de la Accion?.",
                                buttonLeft: "SI",
                                actionButtonLeft: () {
                                  cancelService(
                                    key: snapshot.data[index].key,
                                    date: fecha,
                                  );
                                  patimovilData
                                      .child(
                                          'users/${userSnapshot.uid}/inService')
                                      .remove();
                                  Navigator.pop(context);
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            super.widget),
                                  );
                                },
                                buttonRight: "NO",
                                actionButtonRight: () {
                                  Navigator.pop(context);
                                },
                              );
                            },
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

  void cancelService({@required String key, @required DateTime date}) {
    DatabaseReference db = FirebaseDatabase.instance.reference();
    db.child('rideRequest/$key').remove();
    db
        .child(
            'TransportationSchedule/${date.year}/${date.month}/${date.day}/${date.hour}/${date.minute}/${date.second}')
        .remove();
    db.child('ScheduledTrips/${userSnapshot.uid}/$key').remove();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Servicios Programados'),
        backgroundColor: BrandColors.patiSecundary,
      ),
      body: Center(
        child: _buildBodyScheduledTrips(),
      ),
    );
  }
}
