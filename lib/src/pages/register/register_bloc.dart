import 'dart:io';
import 'package:meta/meta.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:email_validator/email_validator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_firebase_chat/src/services/auth_service.dart';

part 'register_event.dart';
part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  AuthService _authService = AuthService();
  String _username = '';
  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  File _imageFile;

  @override
  RegisterState get initialState => RegisterState.initial();

  @override
  Stream<RegisterState> mapEventToState(RegisterEvent event) async* {
    if (event is RegisterTextFieldChangedEvent)
      yield* _mapTextFieldChangedToState(event);
    else if (event is RegisterPressedEvent)
      yield* _mapPressedToState();
    else if (event is RegisterImageFromCameraEvent)
      yield* _mapImageToState(ImageSource.camera);
    else if (event is RegisterImageFromLibraryEvent)
      yield* _mapImageToState(ImageSource.gallery);
  }

  Stream<RegisterState> _mapTextFieldChangedToState(
    RegisterTextFieldChangedEvent event
  ) async* {
    _username = event.username;
    _email = event.email;
    _password = event.password;
    _confirmPassword = event.confirmPassword;
    yield state.update(
      isValid: _isFormValidated()
    );
  }

  bool _isFormValidated() {
    return (_imageFile != null) &&
      _username.isNotEmpty &&
      EmailValidator.validate(_email) &&
      _password.isNotEmpty &&
      _confirmPassword.isNotEmpty &&
      (_password == _confirmPassword);
  }

  Stream<RegisterState> _mapPressedToState() async* {
    yield state.update(
      isLoading: true
    );
    try {
      await _authService.register(
        _username,
        _email,
        _password,
        _imageFile
      );
      yield state.update(
        isLoading: false,
        isSuccess: true
      );
    } catch (e) {
      yield state.update(
        isLoading: false,
        error: e.message
      );
      yield RegisterState.initial(
        isValid: _isFormValidated(),
        imageFile: _imageFile
      );
    }
  }

  Stream<RegisterState> _mapImageToState(
    ImageSource imageSource
  ) async* {
    _imageFile = await ImagePicker.pickImage(
      source: imageSource,
      maxWidth: 400
    );
    yield state.update(
      isValid: _isFormValidated(),
      imageFile: _imageFile
    );
  }
}