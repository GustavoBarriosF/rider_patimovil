import 'package:firebase_database/firebase_database.dart';

class UserDataSnapshot{
  String id, fullName, email, phone;

  UserDataSnapshot({
    this.id,
    this.fullName,
    this.email,
    this.phone,
  });

  UserDataSnapshot.fromSnapshot(DataSnapshot snapshot){
    id = snapshot.key;
    phone = snapshot.value['phone'];
    email = snapshot.value['email'];
    fullName = snapshot.value['fullname'];
  }

}