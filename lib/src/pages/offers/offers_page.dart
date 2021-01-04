import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_chat/models/Offer.dart';
import 'package:flutter_firebase_chat/src/pages/offers/widgets/offer_item.dart';

import 'offers_bloc.dart';

class OffersPage extends StatefulWidget {
  @override
  _OffersPageState createState() => _OffersPageState();
}

class _OffersPageState extends State<OffersPage> {
  String offers = "loading";
  OffersBloc _offersBloc;
  @override
  void initState() {
    _offersBloc = BlocProvider.of<OffersBloc>(context);
    _offersBloc.add(OffersInitialFetchEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<OffersBloc, OffersState>(builder: (_, state) {
        List<Offer> offers = state.offers;
        offers = offers.toList();

        return ListView.builder(
          itemCount: offers.length,
          itemBuilder: (context, index) {
            return OfferItem(offers[index]);
          },
        );
      }),
    );
  }
}
