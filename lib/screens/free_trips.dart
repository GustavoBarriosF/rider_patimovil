import 'package:flutter/material.dart';
import 'package:patimovil_rider/utils/brand_colors.dart';

class FreeTrips extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Viajes Gratis'),
        backgroundColor: BrandColors.patiSecundary,
      ),
      body: Center(
        child: Text('No hay informacion actual'),
      ),
    );
  }
}
