import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:patimovil_rider/models/address.dart';
import 'package:patimovil_rider/models/direction_details.dart';
import 'package:patimovil_rider/models/trip_details.dart';
import 'package:patimovil_rider/utils/brand_colors.dart';

class MyCustomMarker extends CustomPainter {
  final Address address;
  final DirectionDetails directionDetails;
  final String toAddress;
  final bool isToAddress;
  final bool isPickup;

  MyCustomMarker({
    this.toAddress,
    this.directionDetails,
    this.address,
    this.isToAddress = false,
    @required this.isPickup,
  });

  void _buildMiniRect(Canvas canvas, Paint paint, double size) {
    paint.color = BrandColors.patiSecundary;
    final Rect rect = Rect.fromLTWH(0, 0, size, size);
    canvas.drawRect(rect, paint);
  }

  void _buildParagraph({
    @required Canvas canvas,
    @required String text,
    @required double width,
    @required Offset offset,
    Color color = BrandColors.patiPrimary,
    double fontSize = 18,
    String fontFamily,
  }) {
    final ui.ParagraphBuilder builder = ui.ParagraphBuilder(
      ui.ParagraphStyle(
        maxLines: 2,
      ),
    );
    builder.pushStyle(
      ui.TextStyle(
        color: color,
        fontSize: fontSize,
        fontFamily: fontFamily,
      ),
    );
    builder.addText(text);
    final ui.Paragraph paragraph = builder.build();
    paragraph.layout(ui.ParagraphConstraints(width: width));
    canvas.drawParagraph(
      paragraph,
      Offset(offset.dx, offset.dy - paragraph.height / 2),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint();
    paint.color = Colors.white;
    final height = size.height - 15;
    final RRect rrect = RRect.fromLTRBR(
      0,
      0,
      size.width,
      height,
      Radius.circular(0),
    );
    canvas.drawRRect(rrect, paint);

    final rect = Rect.fromLTWH(size.width / 2 - 2.5, height, 5, 15);
    canvas.drawRect(rect, paint);

    _buildMiniRect(canvas, paint, height);
    _buildParagraph(
      canvas: canvas,
      text: (!this.isToAddress) ? this.address.placeName : this.toAddress,
      width: size.width - height - 20,
      offset: Offset(height + 10, height / 2),
      fontFamily: 'FuturaMaxi-book',
    );
    _buildParagraph(
      canvas: canvas,
      text: (isPickup)
          ? String.fromCharCode(Icons.gps_fixed.codePoint)
          : directionDetails.durationText,
      width: 40,
      offset: Offset(height / 2 - 20, height / 2),
      color: Colors.white,
      fontSize: (isPickup) ? 40 : 20,
      fontFamily: (isPickup) ? Icons.gps_fixed.fontFamily : null,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class MyCustomMarkerBooking extends CustomPainter {
  final TripDetails tripDetails;
  final DirectionDetails directionDetails;
  final bool isPickup;

  MyCustomMarkerBooking({
    this.tripDetails,
    this.directionDetails,
    @required this.isPickup,
  });

  void _buildMiniRect(Canvas canvas, Paint paint, double size) {
    paint.color = BrandColors.patiSecundary;
    final Rect rect = Rect.fromLTWH(0, 0, size, size);
    canvas.drawRect(rect, paint);
  }

  void _buildParagraph({
    @required Canvas canvas,
    @required String text,
    @required double width,
    @required Offset offset,
    Color color = BrandColors.patiPrimary,
    double fontSize = 18,
    String fontFamily,
    TextAlign textAlign = TextAlign.left,
  }) {
    final ui.ParagraphBuilder builder = ui.ParagraphBuilder(
      ui.ParagraphStyle(
        maxLines: 2,
        textAlign: textAlign,
      ),
    );
    builder.pushStyle(
      ui.TextStyle(
        color: color,
        fontSize: fontSize,
        fontFamily: fontFamily,
      ),
    );
    builder.addText(text);
    final ui.Paragraph paragraph = builder.build();
    paragraph.layout(ui.ParagraphConstraints(width: width));
    canvas.drawParagraph(
      paragraph,
      Offset(offset.dx, offset.dy - paragraph.height / 2),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint();
    paint.color = Colors.white;
    final height = size.height - 15;
    final RRect rrect = RRect.fromLTRBR(
      0,
      0,
      size.width,
      height,
      Radius.circular(0),
    );
    canvas.drawRRect(rrect, paint);

    final rect = Rect.fromLTWH(size.width / 2 - 2.5, height, 5, 15);
    canvas.drawRect(rect, paint);

    _buildMiniRect(canvas, paint, height);
    _buildParagraph(
      canvas: canvas,
      text: (this.isPickup)
          ? this.tripDetails.pickupAddress
          : this.tripDetails.destinationAddress,
      width: size.width - height - 20,
      offset: Offset(height + 10, height / 2),
      fontFamily: 'FuturaMaxi-book',
    );
    _buildParagraph(
      canvas: canvas,
      text: (isPickup)
          ? String.fromCharCode(Icons.directions_car.codePoint)
          : directionDetails.durationText,
      width: 40,
      offset: Offset(height / 2 - 20, height / 2),
      color: Colors.white,
      fontSize: (isPickup) ? 40 : 20,
      textAlign: TextAlign.center,
      fontFamily: (isPickup) ? Icons.gps_fixed.fontFamily : null,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
