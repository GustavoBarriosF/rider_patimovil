import 'package:flutter/material.dart';
import 'package:patimovil_rider/helpers/request_helper.dart';
import 'package:patimovil_rider/models/prediction.dart';
import 'package:patimovil_rider/provider/appdata_provider.dart';
import 'package:patimovil_rider/utils/brand_colors.dart';
import 'package:patimovil_rider/utils/glovalvariable.dart';
import 'package:patimovil_rider/widgets/brand_divider.dart';
import 'package:patimovil_rider/widgets/prediction_tile.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController pickupController = TextEditingController();
  TextEditingController destinationController = TextEditingController();
  FocusNode focusDestination = FocusNode();
  FocusNode focusPickup = FocusNode();
  bool focused = false;
  bool _boolControl = true;

  void setFocus() {
    if (!focused) {
      FocusScope.of(context).requestFocus(focusDestination);
      focused = true;
    }
  }

  List<Prediction> destinationPredictionList = [];
  List<Prediction> pickupPredictionList = [];

  void searchPlace(String placeName) async {
    if (placeName.length > 2) {
      String url =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&key=$mapKey&language=es-419&components=country:$shortNameCountry';
      var response = await RequestHelper.getRequest(url);
      if (response == 'failed') {
        return;
      }
      if (response['status'] == 'OK') {
        var predictionJson = response['predictions'];
        var thisList = (predictionJson as List)
            .map((data) => Prediction.fromJson(data))
            .toList();
        if (_boolControl) {
          setState(() {
            destinationPredictionList = thisList;
          });
        }
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    setFocus();
    if (searchControl) {
      print('Si esta ingresando sin problemas🌽');
      String address =
          Provider.of<AppDataProvider>(context).pickupAddress.placeName ?? '';
      if (address != null) {
        pickupController.text = address;
      }
      if (onFocused) {
        focused = false;
        onFocused = false;
      }
    }
    return Scaffold(
      body: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Column(
          children: <Widget>[
            Container(
              height: 240,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5.0,
                    spreadRadius: 0.5,
                    offset: Offset(
                      0.7,
                      0.7,
                    ),
                  ),
                ],
              ),
              child: Padding(
                padding:
                    EdgeInsets.only(left: 24, top: 48, right: 24, bottom: 20),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 5,
                    ),
                    Stack(
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Image.asset(
                            'images/back_rosa.png',
                            width: 35,
                            height: 35,
                          ),
                        ),
                        Center(
                          child: Text(
                            'Marcar el destino',
                            style: TextStyle(
                              fontSize: 20,
                              fontFamily: 'FuturaMaxi-bold',
                              color: BrandColors.patiSecundary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 18,
                    ),
                    Row(
                      children: <Widget>[
                        Image.asset(
                          'images/gps_rosa.png',
                          height: 25,
                          width: 25,
                        ),
                        SizedBox(
                          width: 18,
                        ),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: BrandColors.patiAccent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(2.0),
                              child: TextField(
                                focusNode: focusPickup,
                                controller: pickupController,
                                style: TextStyle(
                                  fontFamily: 'FuturaMaxi-book',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                                onChanged: (value) {
                                  searchPlace(value);
                                  searchControl = false;
                                  pruebaControl = true;
                                },
                                decoration: InputDecoration(
                                  hintText: 'Lugar de recogida',
                                  hintStyle: TextStyle(
                                    fontFamily: 'FuturaMaxi-book',
                                    fontWeight: FontWeight.w700,
                                  ),
                                  fillColor: BrandColors.patiAccent,
                                  filled: true,
                                  border: InputBorder.none,
                                  isDense: true,
                                  suffixIcon: IconButton(
                                    icon: Icon(Icons.clear),
                                    onPressed: () {
                                      pickupController.clear();
                                      searchControl = false;
                                      pruebaControl = true;
                                    },
                                  ),
                                  contentPadding: EdgeInsets.only(
                                      left: 10, top: 8, bottom: 8),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: <Widget>[
                        Image.asset(
                          'images/back_fuccia.png',
                          height: 25,
                          width: 25,
                        ),
                        SizedBox(
                          width: 18,
                        ),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: BrandColors.patiAccent,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(2.0),
                              child: TextField(
                                onChanged: (value) {
                                  searchPlace(value);
                                  pruebaControl = false;
                                },
                                focusNode: focusDestination,
                                controller: destinationController,
                                style: TextStyle(
                                  fontFamily: 'FuturaMaxi-book',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'A donde vas?',
                                  hintStyle: TextStyle(
                                    fontFamily: 'FuturaMaxi-book',
                                    fontWeight: FontWeight.w700,
                                  ),
                                  fillColor: BrandColors.patiAccent,
                                  filled: true,
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.only(
                                      left: 10, top: 8, bottom: 8),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            (destinationPredictionList.length > 0)
                ? Padding(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListView.separated(
                      padding: EdgeInsets.all(0),
                      itemBuilder: (context, index) {
                        return PredictionTile(
                          prediction: destinationPredictionList[index],
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) =>
                          BrandDivider(),
                      itemCount: destinationPredictionList.length,
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
