import 'package:flutter/material.dart';
import 'package:patimovil_rider/screens/search_page.dart';
import 'package:patimovil_rider/utils/brand_colors.dart';
import 'package:patimovil_rider/widgets/brand_divider.dart';

class SearchSheet extends StatelessWidget {
  final double searchSheetHeight;
  final Function showDetailSheet;
  const SearchSheet({
    Key key,
    @required this.searchSheetHeight,
    @required this.showDetailSheet,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: searchSheetHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 15.0,
            spreadRadius: 0.5,
            offset: Offset(
              0.7,
              0.7,
            ),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 18,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 5,
            ),
            Text(
              'Encantado de verte!',
              style: TextStyle(
                fontSize: 10,
                fontFamily: 'FuturaMaxi-book',
              ),
            ),
            SizedBox(height: 5),
            Text(
              'A donde vas?',
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'FuturaMaxi-bold',
                color: BrandColors.patiSecundary,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: () async {
                var response = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchPage(),
                  ),
                );
                if (response == 'getDirection') {
                  showDetailSheet();
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: BrandColors.patiSecundary,
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
                  padding: EdgeInsets.all(12.0),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.search,
                        color: BrandColors.patiSecundaryDark,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        'Buscar Destino',
                        style: TextStyle(
                          fontFamily: 'FuturaMaxi-bold',
                          color: BrandColors.patiPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
