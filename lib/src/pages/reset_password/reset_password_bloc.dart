import 'package:meta/meta.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter_firebase_chat/src/services/auth_service.dart';

part 'reset_password_event.dart';
part 'reset_password_state.dart';

class ResetPasswordBloc extends Bloc<ResetPasswordEvent, ResetPasswordState> {
  AuthService _authService = AuthService();
  String _email;

  @override
  ResetPasswordState get initialState => ResetPasswordState.initial();

  @override
  Stream<ResetPasswordState> mapEventToState(ResetPasswordEvent event) async* {
    if (event is ResetPasswordTextFieldChangedEvent)
      yield* _mapTextFieldChangedToState(event);
    else if (event is ResetPasswordPressedEvent)
      yield* _mapResetPasswordPressedToState();
  }

  Stream<ResetPasswordState> _mapTextFieldChangedToState(
    ResetPasswordTextFieldChangedEvent event
  ) async* {
    _email = event.email;
    yield state.update(
      isValid: EmailValidator.validate(_email)
    );
  }

  Stream<ResetPasswordState> _mapResetPasswordPressedToState() async* {
    yield state.update(
      isLoading: true
    );
    try {
      await _authService.resetPassword(_email);
      yield state.update(
        isLoading: false,
        isSuccess: true
      );
    } catch (e) {
      print(e);
      yield state.update(
        isLoading: false,
        error: e.message
      );
    } finally {
      yield ResetPasswordState.initial(
        isValid: EmailValidator.validate(_email)
      );
    }
  }
}