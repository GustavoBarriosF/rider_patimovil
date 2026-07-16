import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DialogsAlert {
  final BuildContext context;
  DialogsAlert(this.context);

  void showAlertDialog({
    String title,
    String description,
    String buttonLeft,
    String buttonRight,
    Function actionButtonLeft,
    Function actionButtonRight,
  }) {
    showDialog(
      context: this.context,
      builder: (_) => Container(
        height: double.infinity,
        width: double.infinity,
        color: Colors.white.withOpacity(0.7),
        child: CupertinoAlertDialog(
          title: Text(title),
          content: Text(description),
          actions: [
            FlatButton(
              onPressed: actionButtonLeft,
              child: Text(buttonLeft),
            ),
            FlatButton(
              onPressed: actionButtonRight,
              child: Text(buttonRight),
            ),
          ],
        ),
      ),
    );
  }
}
