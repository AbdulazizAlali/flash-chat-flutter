import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_chat/src/services/auth_service.dart';
import 'package:meta/meta.dart';

part 'offers_event.dart';
part 'offers_state.dart';

class OffersBloc extends Bloc<NewOfferEvent, NewOfferState> {
  AuthService _authService = AuthService();
  String _email;
  String _password;

  @override
  NewOfferState get initialState => NewOfferState.initial();

  @override
  Stream<NewOfferState> mapEventToState(NewOfferEvent event) async* {
    if (event is OfferTextFieldChangedEvent)
      yield* _mapTextFieldChangedToState(event);
  }

  Stream<NewOfferState> _mapTextFieldChangedToState(
      OfferTextFieldChangedEvent event) async* {
    _email = event.email;
    _password = event.password;
    yield state.update(isValid: _isFormValidated());
  }

  bool _isFormValidated() {
    return _email != null && _password.isNotEmpty;
  }
}
