import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_firebase_chat/src/services/auth_service.dart';

class NewOfferPage extends StatefulWidget {
  static String id = "newSave";
  String type;

  @override
  _NewOfferState createState() => _NewOfferState();
}

class _NewOfferState extends State<NewOfferPage> {
  final _formKey = GlobalKey<FormState>();

  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (_, __) => <Widget>[],
          body: ListView(
            children: <Widget>[
              FlatButton(
                  onPressed: () async {
                    Firestore _firestore = Firestore.instance;
                    AuthService _authService = AuthService();

                    return _firestore.collection('offers').add({
                      'title': "message",
                      'description': 'text',
                      'date': DateTime.now(),
                      'type': "عربي فصيح",
                      'price': 150,
                      'userId': await _authService.getCurrentUserId()
                    });
                  },
                  child: Text("add new Offer"))
            ],
          ),
        ),
      ),
    );
  }
}
