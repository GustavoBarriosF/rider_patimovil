import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:patimovil_rider/firebase/Auth.dart';
import 'package:patimovil_rider/screens/dialogs.dart';
import 'package:patimovil_rider/screens/login_page.dart';
import 'package:patimovil_rider/screens/mainpage.dart';
import 'package:patimovil_rider/utils/brand_colors.dart';
import 'package:patimovil_rider/utils/glovalvariable.dart';
import 'package:patimovil_rider/widgets/patimovil_button.dart';
import 'package:patimovil_rider/widgets/progress_dialog.dart';
import 'package:patimovil_rider/utils/extras.dart';
import 'package:toast/toast.dart';

class RegistrationPage extends StatefulWidget {
  static final routeName = 'register';

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  String photoURL;
  File photoImage;
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

  var fullNameController = TextEditingController();

  var emailController = TextEditingController();

  var passwordController = TextEditingController();

  var confirmPasswordController = TextEditingController();

  void registerUser() async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => ProgressDialog(
        status: 'Registrando...',
      ),
    );
    if (passwordController.text == confirmPasswordController.text) {
      try {
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
                email: emailController.text, password: passwordController.text);
        createUserDatabase(userCredential.user.uid);
      } on FirebaseAuthException catch (e) {
        Navigator.pop(context);
        if (e.code == 'weak-password') {
          print('The password provided is too weak.');
        } else if (e.code == 'email-already-in-use') {
          print('The account already exists for that email.');
        }
      } catch (e) {
        print(e.toString());
      }
    } else {
      if (passwordController.text != confirmPasswordController.text) {
        showSnackBar('Las contraseñas no coinciden');
        Navigator.pop(context);
        return;
      }
    }
  }

  Future<void> uploadFile(
      {@required File photoImage,
      @required String userID,
      @required String userName}) async {
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
    userSnapshot.updateProfile(displayName: userName);
    DatabaseReference newUserRef =
        FirebaseDatabase.instance.reference().child('users/$userID');
    Map userMap = {
      'fullname': fullNameController.text,
      'email': emailController.text,
      'photoUrl': photoURL != null ? photoURL : null,
    };
    newUserRef.set(userMap);
    Navigator.pop(context);
    Navigator.pushNamedAndRemoveUntil(
        context, MainPage.routeName, (route) => false);
  }

  void createUserDatabase(String userId) {
    Auth.instance.userData.then((value) {
      userSnapshot = value;
      String nameUser = fullNameController.text;
      uploadFile(
          photoImage: photoImage, userID: userSnapshot.uid, userName: nameUser);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    height: 25,
                    margin: EdgeInsets.only(top: 10),
                    alignment: Alignment.topLeft,
                    child: new RawMaterialButton(
                      shape: new CircleBorder(),
                      elevation: 0.0,
                      child: Icon(
                        Icons.arrow_back,
                        color: BrandColors.patiSecundary,
                        size: 25,
                      ),
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                            context, LoginPage.routeName, (route) => false);
                      },
                    ),
                  ),
                  if (photoImage != null)
                    Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blueAccent),
                        borderRadius: BorderRadius.circular(50),
                        image: DecorationImage(
                          image: FileImage(photoImage),
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  else
                    Image.asset(
                      'images/Avatar_rosa_blanco.png',
                      height: 100,
                      width: 100,
                    ),
                  SizedBox(height: 10),
                  FlatButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    color: Colors.white,
                    textColor: BrandColors.patiSecundary,
                    onPressed: () {
                      captureType();
                    },
                    child: Text(
                      'Captura de Foto',
                      style: TextStyle(
                        fontFamily: 'FuturaMaxi-book',
                        fontSize: 12,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Crear Nueva Cuenta',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 23,
                      fontFamily: 'FuturaMaxi-bold',
                      color: BrandColors.patiSecundary,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: <Widget>[
                        TextField(
                          controller: fullNameController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            labelText: 'Nombre Completo',
                            labelStyle: TextStyle(
                              fontSize: 14.0,
                              fontFamily: 'FuturaMaxi-book',
                              fontWeight: FontWeight.w900,
                              color: BrandColors.patiSecundary,
                            ),
                            hintStyle: TextStyle(
                              color: BrandColors.patiSecundary,
                              fontSize: 10.0,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(
                                width: 2,
                                color: BrandColors.patiPrimary,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(
                                width: 1,
                                color: BrandColors.patiPrimary,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(width: 1.0),
                            ),
                          ),
                          style: TextStyle(
                            fontSize: 14,
                            color: BrandColors.patiSecundary,
                          ),
                        ), //Nombre Completo
                        SizedBox(height: 10),
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Correo Electronico',
                            labelStyle: TextStyle(
                              fontSize: 14.0,
                              fontFamily: 'FuturaMaxi-book',
                              fontWeight: FontWeight.w900,
                              color: BrandColors.patiSecundary,
                            ),
                            hintStyle: TextStyle(
                              color: BrandColors.patiSecundary,
                              fontSize: 10.0,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(
                                width: 2,
                                color: BrandColors.patiPrimary,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(
                                width: 1,
                                color: BrandColors.patiPrimary,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(width: 1.0),
                            ),
                          ),
                          style: TextStyle(
                            fontSize: 14,
                            color: BrandColors.patiSecundary,
                          ),
                        ), //Correo Electronico
                        SizedBox(height: 10),
                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            labelStyle: TextStyle(
                              fontSize: 14.0,
                              fontFamily: 'FuturaMaxi-book',
                              fontWeight: FontWeight.w900,
                              color: BrandColors.patiSecundary,
                            ),
                            hintStyle: TextStyle(
                              color: BrandColors.patiSecundary,
                              fontSize: 10.0,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(
                                width: 2,
                                color: BrandColors.patiPrimary,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(
                                width: 1,
                                color: BrandColors.patiPrimary,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(width: 1.0),
                            ),
                          ),
                          style: TextStyle(
                            fontSize: 14,
                            color: BrandColors.patiSecundary,
                          ),
                        ), //Contraseña
                        SizedBox(height: 10),
                        TextField(
                          controller: confirmPasswordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Confirmar Contraseña',
                            labelStyle: TextStyle(
                              fontSize: 14.0,
                              fontFamily: 'FuturaMaxi-book',
                              fontWeight: FontWeight.w900,
                              color: BrandColors.patiSecundary,
                            ),
                            hintStyle: TextStyle(
                              color: BrandColors.patiSecundary,
                              fontSize: 10.0,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(
                                width: 2,
                                color: BrandColors.patiPrimary,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(
                                width: 1,
                                color: BrandColors.patiPrimary,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(width: 1.0),
                            ),
                          ),
                          style: TextStyle(
                            fontSize: 14,
                            color: BrandColors.patiSecundary,
                          ),
                        ), //Contraseña
                        SizedBox(height: 40),
                        PatimovilButton(
                          onPressed: () async {
                            ConnectivityResult connectivityResult =
                                await Connectivity().checkConnectivity();

                            if (connectivityResult !=
                                    ConnectivityResult.mobile &&
                                connectivityResult != ConnectivityResult.wifi) {
                              showSnackBar('No hay conecxion a internet');
                              return;
                            }

                            if (fullNameController.text.length < 3) {
                              showSnackBar('Porfavor provea un nombre valido');
                              return;
                            }
                            if (!emailController.text.contains('@')) {
                              showSnackBar(
                                  'Porfavor provea un correo electronico valido');
                              return;
                            }

                            if (passwordController.text.length <= 5) {
                              showSnackBar(
                                  'La contraseña debe tener mas de 6 caracteres');
                              return;
                            }
                            registerUser();
                          },
                          label: 'Registrar',
                          color: BrandColors.patiSecundary,
                          fontFamily: 'FuturaMaxi-bold',
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
    );
  }

  void captureType() {
    DialogsAlert dialogsAlert = DialogsAlert(context);
    dialogsAlert.showAlertDialog(
      title: "Seleccione",
      description: "Seleccione un metodo de captura para su imagen.",
      buttonLeft: "Camara",
      actionButtonLeft: () {
        _openCamera();
      },
      buttonRight: "Galeria",
      actionButtonRight: () {
        _openGallery();
      },
    );
  }

  void _openCamera() async {
    File picture = await ImagePicker.pickImage(source: ImageSource.camera);
    Toast.show("Espere un momento...", context,
        duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
    picture = await compressPhotoProfile(picture);
    setState(() {
      photoImage = picture;
    });
    Navigator.of(context).pop();
  }

  void _openGallery() async {
    var picture = await ImagePicker.pickImage(source: ImageSource.gallery);
    Toast.show("Espere un momento...", context,
        duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
    picture = await compressPhotoProfile(picture);
    setState(() {
      photoImage = picture;
    });
    Navigator.of(context).pop();
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
