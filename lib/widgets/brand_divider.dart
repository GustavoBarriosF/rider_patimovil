import 'package:flutter/material.dart';
import 'package:patimovil_rider/utils/brand_colors.dart';

class BrandDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1.0,
      color: BrandColors.patiSecundaryDark,
      thickness: 1.0,
    );
  }
}
