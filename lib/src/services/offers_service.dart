import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_firebase_chat/models/Offer.dart';

Future<List<Offer>> getOffers() {
  Firestore _firestore = Firestore.instance;

  return _firestore
      .collection("offers")
      .getDocuments()
      .then((value) => getOfferFromDocument(value.documents));
}

List<Offer> getOfferFromDocument(List<DocumentSnapshot> documents) {
  List<Offer> offers = [];
  print(documents.length);
  documents.map((newOffer) {
    offers.add(Offer(
        title: newOffer.data["title"],
        description: newOffer.data["title"],
        type: newOffer.data["type"],
        price: newOffer.data["price"],
        bids: newOffer.data["bids"]));
  });
  return offers;
}
