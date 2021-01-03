part of 'profile_bloc.dart';

class ProfileState {
  final bool isFetched;
  final bool isValid;
  final bool isLoading;
  final bool isSuccess;
  final String error;
  final ProfileModel profileData;

  ProfileState({
    @required this.isFetched,
    @required this.isValid,
    @required this.isLoading,
    @required this.isSuccess,
    @required this.error,
    @required this.profileData
  });

  factory ProfileState.initial({
    ProfileModel profileData
  }) {
    return ProfileState(
      isFetched: false,
      isValid: true,
      isLoading: false,
      isSuccess: false,
      error: '',
      profileData: profileData ?? ProfileModel(
        username: null,
        email: null,
        password: null,
        confirmPassword: null,
        imageUrl: null
      )
    );
  }

  ProfileState update({
    bool isFetched,
    bool isValid,
    bool isLoading,
    bool isSuccess,
    String error,
    ProfileModel profileData,
  }) {
    return ProfileState(
      isFetched: isFetched ?? this.isFetched,
      isValid: isValid ?? this.isValid,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error ?? this.error,
      profileData: profileData ?? this.profileData
    );
  }
}