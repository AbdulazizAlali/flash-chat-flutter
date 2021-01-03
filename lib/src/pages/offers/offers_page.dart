import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat/src/services/offers_service.dart';

class OffersPage extends StatefulWidget {
  @override
  _OffersPageState createState() => _OffersPageState();
}

class _OffersPageState extends State<OffersPage> {
  String offers = "loading";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getOffers().then((value) {
      setState(() {
        offers = value.toString();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blueGrey,
      child: Center(child: Text(offers)),
    );
  }
}
