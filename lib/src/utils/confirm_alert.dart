import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat/src/themes/colors.dart';

class ConfirmAlert {
  final BuildContext context;
  final String title;
  final Function() onConfirm;

  ConfirmAlert({
    @required this.context,
    @required this.title,
    @required this.onConfirm
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          backgroundColor: whiteColor,
          contentPadding: EdgeInsets.all(30),
          content: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              color: blackColor
            )
          ),
          actions: [
            FlatButton(
              child: Text(
                'No',
                style: TextStyle(
                  fontSize: 16,
                  color: blueColor
                )
              ),
              onPressed: () => Navigator.pop(context)
            ),
            FlatButton(
              child: Text(
                'Yes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: blueColor
                )
              ),
              onPressed: () {
                Navigator.pop(context);
                onConfirm();
              }
            )
          ]
        );
      }
    );
  }
}