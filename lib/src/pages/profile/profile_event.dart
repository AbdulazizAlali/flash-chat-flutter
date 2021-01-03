part of 'profile_bloc.dart';

abstract class ProfileEvent {}

class ProfileTextFieldChangedEvent extends ProfileEvent {
  final String username;
  final String password;
  final String confirmPassword;

  ProfileTextFieldChangedEvent({
    @required this.username,
    @required this.password,
    @required this.confirmPassword
  });
}

class ProfileSaveEvent extends ProfileEvent {}

class ProfileImageFromCameraEvent extends ProfileEvent {}

class ProfileImageFromLibraryEvent extends ProfileEvent {}

class ProfileFetchEvent extends ProfileEvent {}