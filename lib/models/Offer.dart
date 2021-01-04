import 'package:flutter/cupertino.dart';

import 'Bid.dart';

class Offer {
  String title;
  String description;
  int price;
  String userId;
  String type;
  List<Bid> bids;

  Offer(
      {@required this.title,
      @required this.description,
      @required this.price,
      @required this.userId,
      @required this.type,
      @required this.bids});
}
