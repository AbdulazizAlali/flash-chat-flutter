part of 'offers_bloc.dart';

abstract class OffersEvent {}

class AddOfferPressedEvent extends OffersEvent {}

class OffersInitialFetchEvent extends OffersEvent {}
