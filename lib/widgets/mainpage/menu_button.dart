import 'dart:io';

import 'package:flutter/material.dart';

class MenuButton extends StatelessWidget {
  final bool drawerCanOpen;
  final Function onTap;
  MenuButton({Key key, @required this.drawerCanOpen, @required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 5.0,
                spreadRadius: 0.5,
                offset: Offset(
                  0.7,
                  0.7,
                ),
              ),
            ]),
        child: CircleAvatar(
          backgroundColor: Colors.white,
          radius: 20,
          child: Icon(
            (drawerCanOpen) ? Icons.menu : Icons.arrow_back,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}
