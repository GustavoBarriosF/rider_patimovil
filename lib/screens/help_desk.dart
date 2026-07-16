import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:patimovil_rider/utils/brand_colors.dart';
import 'package:patimovil_rider/utils/glovalvariable.dart';
import 'package:patimovil_rider/widgets/patimovil_button.dart';
import 'package:patimovil_rider/widgets/progress_dialog.dart';
import 'package:toast/toast.dart';

class HelpDesk extends StatefulWidget {
  @override
  _HelpDeskState createState() => _HelpDeskState();
}

class _HelpDeskState extends State<HelpDesk> {
  TextEditingController subjetController = TextEditingController();

  TextEditingController messageController = TextEditingController();

  TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Soporte'),
        backgroundColor: BrandColors.patiSecundary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(height: 20),
              Row(
                children: <Widget>[
                  Image.asset(
                    'images/chat.png',
                    width: 100,
                    height: 100,
                  ),
                  SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '¿Necesitas ayuda?',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Container(
                        width: 200,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Empieza enviando un mensaje a nuestro servicio de atencion al cliente',
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),
              TextField(
                controller: subjetController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: 'Asunto',
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
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(
                      width: 2,
                      color: BrandColors.patiPrimary,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
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
              ),
              SizedBox(height: 10),
              TextField(
                controller: messageController,
                maxLines: 6,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: 'Mensaje',
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
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(
                      width: 2,
                      color: BrandColors.patiPrimary,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
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
              ),
              SizedBox(height: 10),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Telefono',
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
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(
                      width: 2,
                      color: BrandColors.patiPrimary,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
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
              ),
              SizedBox(height: 10),
              PatimovilButton(
                label: 'Enviar',
                onPressed: () {
                  sendEmail();
                },
                color: BrandColors.patiSecundary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void sendEmail() async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => ProgressDialog(
        status: 'Enviando...',
      ),
    );
    String username = 'soporte@patimovil.net';
    String password = 'Panama2021.';

    final smtpServer = SmtpServer(
      'mail.patimovil.net',
      port: 465,
      ssl: true,
      username: username,
      password: password,
    );

    final message1 = Message()
      ..from = Address('soporte@patimovil.net')
      ..recipients.add('info@patimovil.net')
      ..bccRecipients.add(Address('bolivia20192019@gmail.com'))
      ..subject = subjetController.text
      ..text =
          'El Usuario ${userSnapshot.displayName} envia un mensaje de Soporte: ${messageController.text} cualquier contacto llamar al numero ${phoneController.text}';

    final message2 = Message()
      ..from = Address('soporte@patimovil.net')
      ..recipients.add('${userSnapshot.email}')
      ..bccRecipients.add(Address('bolivia20192019@gmail.com'))
      ..subject = subjetController.text
      ..text =
          'Hola señor ${userSnapshot.displayName} hemos recibido su correo electronico con la informacion sobre su requerimiento, nos estaremos contactando con usted en el menor tiempo posible Mensage: ${messageController.text}';
    try {
      final sendReport1 = await send(message1, smtpServer);
      print('Message sent: ' + sendReport1.toString());
      final sendReport2 = await send(message2, smtpServer);
      print('Message sent: ' + sendReport2.toString());
    } on MailerException catch (e) {
      print('Message not sent.');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }

    subjetController.text = '';
    messageController.text = '';
    phoneController.text = '';

    Navigator.pop(context);

    Toast.show(
      'Señor ${userSnapshot.displayName} su mensaje ha sido enviado correctamente, gracias.',
      context,
      duration: 8,
      gravity: Toast.CENTER,
    );
  }
}
