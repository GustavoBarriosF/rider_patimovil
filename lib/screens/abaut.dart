import 'package:flutter/material.dart';
import 'package:patimovil_rider/screens/politicas.dart';
import 'package:patimovil_rider/utils/brand_colors.dart';
import 'package:patimovil_rider/widgets/patimovil_outline_button.dart';

class Abaut extends StatelessWidget {
  const Abaut({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Acerca de la Aplicacion'),
        backgroundColor: BrandColors.patiSecundary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                child: Text(
                  'PATIMOVIL. es una empresa panameña que proporciona a sus clientes a nivel internacional vehículos de transporte con conductor exclusivo para mascotas , a través de su software de aplicacion movil desarrollado por la empresa GALEX Solution S.A. Con sede en panama, que conecta los pasajeros con los conductores de vehículos registrados en su servicio, los cuales ofrecen un servicio de transporte a mascotas y sus propietarios y/o cuidadores.',
                  style: TextStyle(fontFamily: 'FuturaMaxi-book'),
                  textAlign: TextAlign.justify,
                ),
              ),
              SizedBox(height: 40),
              PatiOutlineButton(
                title: 'Términos y condiciones',
                color: BrandColors.patiSecundary,
                onPressed: () {},
              ),
              SizedBox(height: 20),
              PatiOutlineButton(
                title: 'Políticas de privacidad',
                color: BrandColors.patiSecundary,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PoliticasDePrivacidadPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
