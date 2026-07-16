import 'package:flutter/material.dart';
import 'package:patimovil_rider/helpers/request_helper.dart';
import 'package:patimovil_rider/models/address.dart';
import 'package:patimovil_rider/models/prediction.dart';
import 'package:patimovil_rider/provider/appdata_provider.dart';
import 'package:patimovil_rider/utils/brand_colors.dart';
import 'package:patimovil_rider/utils/glovalvariable.dart';
import 'package:patimovil_rider/widgets/progress_dialog.dart';
import 'package:provider/provider.dart';

class PredictionTile extends StatelessWidget {
  final Prediction prediction;
  const PredictionTile({Key key, this.prediction}) : super(key: key);

  void getPlaceDetails(String placeId, BuildContext context) async {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => ProgressDialog(
              status: 'Espere...',
            ));
    String url =
        'https://maps.googleapis.com/maps/api/place/details/json?key=$mapKey&place_id=$placeId';
    var response = await RequestHelper.getRequest(url);
    Navigator.pop(context);
    if (response == 'failed') {
      return;
    }
    if (response['status'] == 'OK') {
      Address thisPlace = Address();
      thisPlace.placeName = response['result']['name'];
      thisPlace.placeId = placeId;
      thisPlace.latitude = response['result']['geometry']['location']['lat'];
      thisPlace.longitude = response['result']['geometry']['location']['lng'];
      if (pruebaControl) {
        print('Ingresa sin problemas con Origen 🐮');
        Provider.of<AppDataProvider>(context, listen: false)
            .updatePickupAddress(thisPlace);
        searchControl = true;
        onFocused = true;
      } else {
        print('Ingresa sin problemas con Destino 🌈');
        Provider.of<AppDataProvider>(context, listen: false)
            .updateDestinationAddress(thisPlace);
        Navigator.pop(context, 'getDirection');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: () {
        getPlaceDetails(prediction.placeId, context);
      },
      padding: EdgeInsets.all(0),
      child: Container(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 8,
            ),
            Row(
              children: <Widget>[
                Image.asset(
                  'images/point_pasajero_rosa.png',
                  height: 30,
                  width: 30,
                ),
                SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        prediction.mainText,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'FuturaMaxi-book',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(
                        height: 2,
                      ),
                      Text(
                        prediction.secondaryText,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: BrandColors.colorDimText,
                          fontFamily: 'FuturaMaxi-book',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 8,
            ),
          ],
        ),
      ),
    );
  }
}
