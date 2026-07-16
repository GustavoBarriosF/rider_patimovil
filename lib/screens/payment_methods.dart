import 'package:flutter/material.dart';
import 'package:patimovil_rider/utils/brand_colors.dart';
import 'package:patimovil_rider/widgets/brand_divider.dart';

class PaymentMethods extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pago'),
        backgroundColor: BrandColors.patiSecundary,
      ),
      body: Container(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 10),
              Text(
                'Metodos de Pago',
                style: TextStyle(
                  fontFamily: 'FuturaMaxi-bold',
                ),
              ),
              SizedBox(height: 10),
              BrandDivider(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[
                    Image.asset(
                      'images/billetes.png',
                      width: 40,
                      height: 40,
                    ),
                    SizedBox(width: 20),
                    Text(
                      'Efectivo',
                      style: TextStyle(fontFamily: 'FuturaMaxi-book'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
