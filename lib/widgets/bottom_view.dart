import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:patimovil_rider/helpers/database_methods.dart';
import 'package:patimovil_rider/models/trip_details.dart';
import 'package:patimovil_rider/screens/chat_page.dart';
import 'package:patimovil_rider/screens/mainpage.dart';
import 'package:patimovil_rider/utils/brand_colors.dart';
import 'package:patimovil_rider/utils/glovalvariable.dart';
import 'package:patimovil_rider/utils/notification_messaging.dart';

class BottomView extends StatelessWidget {
  final String mIdDriverFound;
  final TripDetails tripDetails;
  const BottomView({Key key, this.mIdDriverFound, this.tripDetails})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      child: Column(
        children: <Widget>[
          Container(
            width: 60,
            height: 4,
            margin: EdgeInsets.only(bottom: 15),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: CupertinoButton(
                color: BrandColors.patiSecundary,
                child: Text(
                  'Cancelar Servicio',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'FuturaMaxi-book'),
                ),
                onPressed: () {
                  NotificationMessaging.sendNotificationCancel(mIdDriverFound);
                  patimovilData
                      .child('users/${userSnapshot.uid}/inService')
                      .remove();
                  Navigator.pushNamedAndRemoveUntil(
                      context, MainPage.routeName, (route) => false);
                }),
          ),
          SizedBox(height: 26),
          Column(
            children: <Widget>[
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      tripDetails.driverName,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                      maxLines: 1,
                    ),
                    IconButton(
                      icon: Icon(Icons.message),
                      onPressed: () {
                        startChat(
                          context,
                          tripDetails.riderId,
                          mIdDriverFound,
                        );
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 5),
                child: Text(
                  'Placa: ${tripDetails.carPlate}',
                ),
              ),
              SizedBox(height: 5),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 5),
                child: Text(
                  tripDetails.carDetails,
                ),
              ),
              SizedBox(height: 10),
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 250,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      image: DecorationImage(
                        image: NetworkImage(tripDetails.carPhotoURL),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 5,
                    right: 5,
                    child: Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(50),
                        image: DecorationImage(
                          image: NetworkImage(tripDetails.driverPhotoURL),
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void startChat(BuildContext context, String riderId, String driverId) {
    List<String> users = [riderId, driverId];
    String chatRoomId = '$riderId-$driverId';
    Map<String, dynamic> chatRoomMap = {
      'users': users,
      'ChatRoomId': chatRoomId,
    };
    DatabaseMethods().createChatRoom(chatRoomId, chatRoomMap);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatPage(
          chatRoomId: chatRoomId,
          idNewTrip: tripDetails.rideID,
          idUser: driverId,
        ),
      ),
    );
  }
}
