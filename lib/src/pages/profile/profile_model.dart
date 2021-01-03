part of 'profile_bloc.dart';

class ProfileModel {
  String username;
  String email;
  String password;
  String confirmPassword;
  String imageUrl;
  File imageFile;

  ProfileModel({
    @required this.username,
    @required this.email,
    @required this.password,
    @required this.confirmPassword,
    @required this.imageUrl
  });

  ProfileModel.fromJson(Map<String, dynamic> parsedJson) {
    username = parsedJson['username'];
    email = parsedJson['email'];
    password = '';
    confirmPassword = '';
    imageUrl = parsedJson['imageUrl'];
    imageFile = null;
  }
}