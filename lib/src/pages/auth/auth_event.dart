part of 'auth_bloc.dart';

abstract class AuthEvent {}

class AuthStartedEvent extends AuthEvent {
  BuildContext context;
  AuthStartedEvent({@required this.context});
}

class AuthLoggedInEvent extends AuthEvent {}

class AuthLoggedOutEvent extends AuthEvent {}
