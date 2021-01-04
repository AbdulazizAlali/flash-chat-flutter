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
  for (int i = 0; i < documents.length; i++) {
    var newOffer = documents[i];
    offers.add(Offer(
        title: newOffer.data["title"],
        description: newOffer.data["description"],
        type: newOffer.data["type"],
        userId: newOffer.data["userId"],
        price: newOffer.data["price"],
        bids: newOffer.data["bids"]));
  }
  print(offers.toString());

  return offers;
}

// Future<String> getUserImageById(String userId) async {
//   Firestore _firestore = Firestore.instance;
//   FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
//
//   DocumentSnapshot profileDoc =
//       await _firestore.collection('users').document(userId).get();
//   return profileDoc.("imageUrl");
// }
