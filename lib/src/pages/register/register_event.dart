part of 'register_bloc.dart';

abstract class RegisterEvent {}

class RegisterTextFieldChangedEvent extends RegisterEvent {
  final String username;
  final String email;
  final String password;
  final String confirmPassword;

  RegisterTextFieldChangedEvent({
    @required this.username,
    @required this.email,
    @required this.password,
    @required this.confirmPassword
  });
}

class RegisterPressedEvent extends RegisterEvent {}

class RegisterImageFromCameraEvent extends RegisterEvent {}

class RegisterImageFromLibraryEvent extends RegisterEvent {}