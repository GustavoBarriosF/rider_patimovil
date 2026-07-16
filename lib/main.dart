import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:patimovil_rider/firebase/Auth.dart';
import 'package:patimovil_rider/provider/appdata_provider.dart';
import 'package:patimovil_rider/screens/forgot_password_page.dart';
import 'package:patimovil_rider/screens/recover_process_page.dart';
import 'package:patimovil_rider/screens/scheduled_trips.dart';
import 'package:patimovil_rider/screens/login_page.dart';
import 'package:patimovil_rider/screens/mainpage.dart';
import 'dart:io';
import 'package:patimovil_rider/screens/registration_page.dart';
import 'package:patimovil_rider/screens/trips_history.dart';
import 'package:patimovil_rider/utils/glovalvariable.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: 'db2',
    options: Platform.isIOS || Platform.isMacOS
        ? FirebaseOptions(
            appId: '1:25248889320:ios:75239cc997de13abb78c5d',
            apiKey: 'AIzaSyCgYtOrBbeG48dIbTrjCQGvX3udLIlJI2c',
            projectId: 'patimovil-ccb6a',
            messagingSenderId: '25248889320',
            databaseURL: 'https://patimovil-ccb6a.firebaseio.com',
          )
        : FirebaseOptions(
            appId: '1:25248889320:android:62517acdec918037b78c5d',
            apiKey: 'AIzaSyBH-GXYb1Xb7F3QtAva0-x1yWrsmVE0i8o',
            messagingSenderId: '25248889320',
            projectId: 'patimovil-ccb6a',
            databaseURL: 'https://patimovil-ccb6a.firebaseio.com',
          ),
  );
  Auth.instance.userData.then((value) {
    userSnapshot = value;
  });
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<Map<dynamic, dynamic>> _dataFinal =
      Future<Map<dynamic, dynamic>>.delayed(Duration(seconds: 1), () async {
    DataSnapshot snapshot = await FirebaseDatabase.instance
        .reference()
        .child('users/${userSnapshot.uid}')
        .once();
    Map<dynamic, dynamic> json = snapshot.value;
    return json;
  });

  Widget _buildBody() {
    return FutureBuilder<Map<dynamic, dynamic>>(
      future: _dataFinal,
      builder: (contetx, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.data == null) {
            return LoginPage();
          } else if (snapshot.hasError) {
            return Center(child: Text('Something went wrong'));
          }
          if (snapshot.hasData) {
            if (snapshot.data['inService'] == null) {
              return MainPage();
            } else {
              return RecoverProcessPage(
                idRide: snapshot.data['inService'],
              );
            }
          }
        }
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'images/LogoBlancoPatimovil.png',
                width: 150,
              ),
              SizedBox(height: 30),
              CircularProgressIndicator(),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return ChangeNotifierProvider(
      create: (context) => AppDataProvider(),
      child: MaterialApp(
        title: 'Patimovil Rider',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Brand-Regular',
          primarySwatch: Colors.blue,
        ),
        home: _buildBody(),
        routes: {
          RegistrationPage.routeName: (context) => RegistrationPage(),
          LoginPage.routeName: (context) => LoginPage(),
          ForgotPasswordPage.routeName: (context) => ForgotPasswordPage(),
          MainPage.routeName: (context) => MainPage(),
          ScheduledTrips.routeName: (context) => ScheduledTrips(),
          TripsHistory.routeName: (context) => TripsHistory(),
        },
      ),
    );
  }
}
