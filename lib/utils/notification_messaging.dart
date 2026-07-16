import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'glovalvariable.dart';

class NotificationMessaging {
  static void sendNotificationCancel(String mIdDriverFound) async {
    patimovilData
        .child('drivers/$mIdDriverFound')
        .once()
        .then((DataSnapshot snapshot) async {
      if (snapshot.value != null) {
        String mDriverToken = snapshot.value['token'];
        await patimovilMessaging.requestNotificationPermissions(
          const IosNotificationSettings(
              sound: true, badge: true, alert: true, provisional: false),
        );
        await http.post(
          'https://fcm.googleapis.com/fcm/send',
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization': 'key=$serverKey',
          },
          body: jsonEncode(
            <String, dynamic>{
              'notification': <String, dynamic>{
                'body': 'Informacion sobre el servicio',
                'title': 'Nuevo Servicio'
              },
              'priority': 'high',
              'data': <String, dynamic>{
                'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                'id': '1',
                'status': 'done',
                'id_message': 'UserCancel'
              },
              'to': mDriverToken,
            },
          ),
        );
      }
    });
  }

  static void sendNotification(
    String idNewTrip,
    String mIdDriverFound,
    String title,
    String body,
  ) {
    patimovilData
        .child('drivers/$mIdDriverFound')
        .once()
        .then((DataSnapshot snapshot) async {
      String mDriverToken = snapshot.value['token'];
      await patimovilMessaging.requestNotificationPermissions(
        const IosNotificationSettings(
            sound: true, badge: true, alert: true, provisional: false),
      );
      await http.post(
        'https://fcm.googleapis.com/fcm/send',
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverKey',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'body': body,
              'title': title,
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done',
              'ride_id': idNewTrip,
              'id_message': 'UserService'
            },
            'to': mDriverToken,
          },
        ),
      );
    });
  }

  static void sendNotificationChat(String mIdDriverFound, String idNewTrip,
      {String statusMessaging}) async {
    patimovilData
        .child('drivers/$mIdDriverFound')
        .once()
        .then((DataSnapshot snapshot) async {
      if (snapshot.value != null) {
        String mUserToken = snapshot.value['token'];
        String mNameDriver = snapshot.value['fullname'];
        await patimovilMessaging.requestNotificationPermissions(
          const IosNotificationSettings(
              sound: true, badge: true, alert: true, provisional: false),
        );
        await http.post(
          'https://fcm.googleapis.com/fcm/send',
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization': 'key=$serverKey',
          },
          body: jsonEncode(
            <String, dynamic>{
              'notification': <String, dynamic>{
                'body':
                    'Usted ha recibido un mensaje de $mNameDriver la persona designada para el transporte de su mascota.',
                'title': 'Tienes un nuevo mensaje'
              },
              'priority': 'high',
              'data': <String, dynamic>{
                'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                'id': '1',
                'status': 'done',
                'ride_id': idNewTrip,
                'id_message': statusMessaging
              },
              'to': mUserToken,
            },
          ),
        );
      }
    });
  }
}
