import 'package:flutter/material.dart';
import 'package:patimovil_rider/firebase/Auth.dart';
import 'package:patimovil_rider/utils/brand_colors.dart';
import 'package:patimovil_rider/widgets/patimovil_button.dart';

class ForgotPasswordPage extends StatefulWidget {
  static final routeName = 'forgotPasswordPage';

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  TextEditingController emailController = TextEditingController();

  void forgotPassword() {
    Auth.instance.resetPassword(emailController.text);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Restaurar contraseña'),
        backgroundColor: BrandColors.patiSecundary,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 150,
                height: 150,
                child: Image.asset('images/logopatimovil.png'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  'Escribe el correo electronico con el que te registraste y te enviaremos a vuelta de correo un link para que recuperes tu cuenta, permitenos ayudarte.',
                  textAlign: TextAlign.justify,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration.collapsed(
                    hintText: 'Correo Electronico',
                    hintStyle: TextStyle(
                      color: BrandColors.patiPrimary,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'FuturaMaxi-book',
                    color: BrandColors.patiPrimary,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: PatimovilButton(
                  label: 'Enviar',
                  onPressed: () {
                    forgotPassword();
                  },
                  color: BrandColors.patiSecundary,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
