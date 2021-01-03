import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat/src/themes/colors.dart';

class Loading {
  final BuildContext context;

  Loading(this.context) {
    showDialog(
        context: context,
        child: Center(
            child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(blueColor))));
  }

  void close() {
    FocusScope.of(context).requestFocus(FocusNode());
    Navigator.pop(context);
  }
}
