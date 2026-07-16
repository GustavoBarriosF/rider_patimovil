import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:patimovil_rider/screens/login_page.dart';
import 'package:patimovil_rider/utils/glovalvariable.dart';

class Auth {
  Auth._internal();

  static Auth get instance => Auth._internal();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<User> get userData async {
    return (_firebaseAuth.currentUser);
  }

  Future<void> logOut(BuildContext context) async {
    await _firebaseAuth.signOut();
    Navigator.pushNamedAndRemoveUntil(
        context, LoginPage.routeName, (route) => false);
    userSnapshot = null;
  }

  void resetPassword(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }
}
