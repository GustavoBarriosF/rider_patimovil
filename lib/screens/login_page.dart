import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:patimovil_rider/firebase/Auth.dart';
import 'package:patimovil_rider/screens/forgot_password_page.dart';
import 'package:patimovil_rider/screens/mainpage.dart';
import 'package:patimovil_rider/screens/registration_page.dart';
import 'package:patimovil_rider/utils/brand_colors.dart';
import 'package:patimovil_rider/utils/glovalvariable.dart';
import 'package:patimovil_rider/widgets/patimovil_button.dart';
import 'package:patimovil_rider/widgets/progress_dialog.dart';

class LoginPage extends StatefulWidget {
  static final routeName = 'login';

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  void showSnackBar(String title) {
    final snackbar = SnackBar(
      content: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 15),
      ),
    );
    scaffoldKey.currentState.showSnackBar(snackbar);
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  TextEditingController emailController = TextEditingController();

  TextEditingController passwordController = TextEditingController();

  void login() async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => ProgressDialog(
        status: 'Iniciando sesión',
      ),
    );
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      if (userCredential != null) {
        Auth.instance.userData.then((value) {
          userSnapshot = value;
        });
        DatabaseReference userRef = FirebaseDatabase.instance
            .reference()
            .child('users/${userCredential.user.uid}');
        userRef.once().then((DataSnapshot dataSnapshot) => {
              if (dataSnapshot.value != null)
                {
                  Navigator.pop(context),
                  Navigator.pushNamedAndRemoveUntil(
                      context, MainPage.routeName, (route) => false)
                }
            });
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
        showSnackBar('Ningún usuario encontrado para ese correo electrónico.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
        showSnackBar(
            'Se proporcionó una contraseña incorrecta para ese usuario.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.white,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('images/plantilla_incio_rider.png'),
                fit: BoxFit.cover),
          ),
          child: SafeArea(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Container(
                          child: Column(
                            children: <Widget>[
                              Container(
                                width: 200,
                                height: 200,
                                child: Image.asset('images/logo_blanco.png'),
                              ),
                              SizedBox(height: 20),
                              Text(
                                'Pasajeros',
                                style: TextStyle(
                                  fontFamily: 'FuturaMaxi-bold',
                                  color: Colors.white,
                                  fontSize: 28,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      alignment: Alignment.centerLeft,
                                      height: 40,
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 10),
                                      decoration: BoxDecoration(
                                        color: BrandColors.patiSecundaryDark,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10),
                                        ),
                                      ),
                                      child: TextField(
                                        controller: emailController,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        decoration: InputDecoration.collapsed(
                                          hintText: 'Correo Electronico',
                                          hintStyle: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14.0,
                                          ),
                                        ),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'FuturaMaxi-book',
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Container(
                                      alignment: Alignment.centerLeft,
                                      height: 40,
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 10),
                                      decoration: BoxDecoration(
                                        color: BrandColors.patiSecundaryDark,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10),
                                        ),
                                      ),
                                      child: TextField(
                                        controller: passwordController,
                                        obscureText: true,
                                        decoration: InputDecoration.collapsed(
                                          hintText: 'Contraseña',
                                          hintStyle: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14.0,
                                          ),
                                        ),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'FuturaMaxi-book',
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: double.infinity,
                                      alignment: Alignment.centerRight,
                                      child: CupertinoButton(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 10),
                                        onPressed: () {
                                          Navigator.pushNamed(context,
                                              ForgotPasswordPage.routeName);
                                        },
                                        child: Text(
                                          '¿Olvidaste la Contraseña?',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontFamily: 'FuturaMaxi-bold',
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    PatimovilButton(
                                      onPressed: () async {
                                        ConnectivityResult connectivityResult =
                                            await Connectivity()
                                                .checkConnectivity();

                                        if (connectivityResult !=
                                                ConnectivityResult.mobile &&
                                            connectivityResult !=
                                                ConnectivityResult.wifi) {
                                          showSnackBar(
                                              'No hay conecxion a internet');
                                          return;
                                        }
                                        if (!emailController.text
                                            .contains('@')) {
                                          showSnackBar(
                                              'Porfavor ingrese una direccion de correo valida');
                                          return;
                                        }
                                        if (passwordController.text.length <
                                            5) {
                                          showSnackBar(
                                              'La contraseña debe tener mas de 5 caracteres');
                                          return;
                                        }
                                        login();
                                      },
                                      textColor: BrandColors.colorPrimary,
                                      fontFamily: 'FuturaMaxi-bold',
                                      heightButton: 30,
                                      label: 'Iniciar',
                                      color: Colors.white,
                                    ),
                                    Container(
                                      alignment: Alignment.center,
                                      height: 100,
                                      width: double.infinity,
                                      child: CupertinoButton(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 5),
                                        onPressed: () {
                                          Navigator.pushNamedAndRemoveUntil(
                                              context,
                                              RegistrationPage.routeName,
                                              (route) => false);
                                        },
                                        child: Text(
                                          'Regístrate!!!',
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
