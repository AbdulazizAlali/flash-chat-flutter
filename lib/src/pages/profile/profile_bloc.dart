import 'dart:io';
import 'package:meta/meta.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_firebase_chat/src/services/auth_service.dart';

part 'profile_event.dart';
part 'profile_state.dart';
part 'profile_model.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  AuthService _authService = AuthService();
  ProfileModel _profileData;

  @override
  ProfileState get initialState => ProfileState.initial();

  @override
  Stream<ProfileState> mapEventToState(ProfileEvent event) async* {
    if (event is ProfileTextFieldChangedEvent)
      yield* _mapTextFieldChangedToState(event);
    else if (event is ProfileSaveEvent)
      yield* _mapSaveToState();
    else if (event is ProfileImageFromCameraEvent)
      yield* _mapImageToState(ImageSource.camera);
    else if (event is ProfileImageFromLibraryEvent)
      yield* _mapImageToState(ImageSource.gallery);
    else if (event is ProfileFetchEvent)
      yield* _mapFetchToState(event);
  }

  Stream<ProfileState> _mapTextFieldChangedToState(
    ProfileTextFieldChangedEvent event
  ) async* {
    _profileData.username = event.username;
    _profileData.password = event.password;
    _profileData.confirmPassword = event.confirmPassword;
    yield state.update(
      isValid: _isFormValidated()
    );
  }

  bool _isFormValidated() {
    return _profileData.username.isNotEmpty &&
      EmailValidator.validate(_profileData.email) &&
      (_profileData.password == _profileData.confirmPassword);
  }

  Stream<ProfileState> _mapSaveToState() async* {
    yield state.update(
      isLoading: true
    );
    try {
      await _authService.updateProfile(_profileData);
      yield state.update(
        isLoading: false,
        isSuccess: true
      );
    } catch (e) {
      yield state.update(
        isLoading: false,
        error: e.message
      );
    } finally {
      yield ProfileState.initial(
        profileData: _profileData
      );
    }
  }

  Stream<ProfileState> _mapImageToState(
    ImageSource imageSource
  ) async* {
    _profileData.imageFile = await ImagePicker.pickImage(
      source: imageSource,
      maxWidth: 400
    );
    yield state.update(
      profileData: _profileData
    );
  }

  Stream<ProfileState> _mapFetchToState(
    ProfileFetchEvent event
  ) async* {
    try {
      _profileData = await _authService.getProfile();
      yield state.update(
        isFetched: true,
        profileData: _profileData
      );
      yield ProfileState.initial(
        profileData: _profileData
      );
    } catch (e) {
      print(e);
    }
  }
}