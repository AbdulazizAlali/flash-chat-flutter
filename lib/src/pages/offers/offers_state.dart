part of 'offers_bloc.dart';

class OffersState {
  final List<Offer> offers;

  OffersState({@required this.offers});

  factory OffersState.initial({bool isValid}) {
    return OffersState(offers: []);
  }

  OffersState update({List<Offer> offers}) {
    return OffersState(
      offers: offers ?? this.offers,
    );
  }
}
