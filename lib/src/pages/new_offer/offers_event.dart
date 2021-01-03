part of 'offers_bloc.dart';

abstract class NewOfferEvent {}

class OfferTextFieldChangedEvent extends NewOfferEvent {
  final String email;
  final String password;

  OfferTextFieldChangedEvent({@required this.email, @required this.password});
}
