import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as im;
import 'package:flutter/services.dart';
import 'package:patimovil_rider/models/address.dart';
import 'package:patimovil_rider/models/direction_details.dart';
import 'package:patimovil_rider/models/trip_details.dart';
import 'package:patimovil_rider/widgets/my_custom_marker.dart';

Future<Uint8List> loadAsset(String path,
    {int width = 50, int height = 50}) async {
  ByteData data = await rootBundle.load(path);
  final Uint8List bytes = data.buffer.asUint8List();
  final ui.Codec codec = await ui.instantiateImageCodec(
    bytes,
    targetWidth: width,
    targetHeight: height,
  );
  final ui.FrameInfo frame = await codec.getNextFrame();
  data = await frame.image.toByteData(format: ui.ImageByteFormat.png);
  return data.buffer.asUint8List();
}

Future<Uint8List> placeToMarkerBooking(TripDetails tripDetails,
    {@required bool isPickup, DirectionDetails directionDetails}) async {
  ui.PictureRecorder recorder = ui.PictureRecorder();
  ui.Canvas canvas = ui.Canvas(recorder);
  final ui.Size size = ui.Size(300, 90);
  MyCustomMarkerBooking myCustomMarker = MyCustomMarkerBooking(
      tripDetails: tripDetails,
      isPickup: isPickup,
      directionDetails: directionDetails);
  myCustomMarker.paint(canvas, size);
  ui.Picture picture = recorder.endRecording();
  final ui.Image image =
      await picture.toImage(size.width.toInt(), size.height.toInt());
  ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  return byteData.buffer.asUint8List();
}

Future<Uint8List> placeToMarker(Address address,
    {@required bool isPickup, DirectionDetails directionDetails}) async {
  ui.PictureRecorder recorder = ui.PictureRecorder();
  ui.Canvas canvas = ui.Canvas(recorder);
  final ui.Size size = ui.Size(300, 90);
  MyCustomMarker myCustomMarker = MyCustomMarker(
      address: address, isPickup: isPickup, directionDetails: directionDetails);
  myCustomMarker.paint(canvas, size);
  ui.Picture picture = recorder.endRecording();
  final ui.Image image =
      await picture.toImage(size.width.toInt(), size.height.toInt());
  ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  return byteData.buffer.asUint8List();
}

Future<Uint8List> toMarkerInit(String address, bool isToAddress) async {
  ui.PictureRecorder recorder = ui.PictureRecorder();
  ui.Canvas canvas = ui.Canvas(recorder);
  final ui.Size size = ui.Size(300, 90);
  MyCustomMarker myCustomMarker = MyCustomMarker(
      toAddress: address, isToAddress: isToAddress, isPickup: true);
  myCustomMarker.paint(canvas, size);
  ui.Picture picture = recorder.endRecording();
  final ui.Image image =
      await picture.toImage(size.width.toInt(), size.height.toInt());
  ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  return byteData.buffer.asUint8List();
}

Future<File> compressPhotoProfile(File inputImage,
    {int resizePercentage = 50, int quality = 90}) async {
  List<int> bytes = await inputImage.readAsBytes();

  im.Image image = im.decodeImage(bytes);

  im.Image resizedImage = im.copyResizeCropSquare(image, 900);

  String originalFileName = path.basename(inputImage.path);
  String filePath = inputImage.parent.path;
  String newFile = path.join(
      filePath, originalFileName.split('.').first + "_compressed.jpg");

  File outputImage = new File(newFile);
  outputImage.writeAsBytesSync(im.encodeJpg(resizedImage, quality: quality),
      mode: FileMode.write, flush: true);

  return outputImage;
}
