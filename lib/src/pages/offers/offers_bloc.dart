import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_chat/models/Offer.dart';
import 'package:flutter_firebase_chat/src/services/auth_service.dart';
import 'package:flutter_firebase_chat/src/services/offers_service.dart';
import 'package:meta/meta.dart';

part 'offers_event.dart';
part 'offers_state.dart';

class OffersBloc extends Bloc<OffersEvent, OffersState> {
  AuthService _authService = AuthService();
  String _email;
  String _password;

  @override
  OffersState get initialState => OffersState.initial();

  @override
  Stream<OffersState> mapEventToState(OffersEvent event) async* {
    if (event is AddOfferPressedEvent) yield* _mapAddOfferPressedToState();
    if (event is OffersInitialFetchEvent) yield* mapInitialFetchEvent();
  }

  @override
  Stream<OffersState> mapInitialFetchEvent() async* {
    List<Offer> offers = await getOffers();
    yield state.update(offers: offers);
  }

  Stream<OffersState> _mapAddOfferPressedToState() async* {}
}
