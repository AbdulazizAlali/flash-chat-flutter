part of 'reset_password_bloc.dart';

class ResetPasswordState {
  final bool isValid;
  final bool isLoading;
  final bool isSuccess;
  final String error;

  ResetPasswordState({
    @required this.isValid,
    @required this.isLoading,
    @required this.isSuccess,
    @required this.error
  });

  factory ResetPasswordState.initial({
    bool isValid
  }) {
    return ResetPasswordState(
      isValid: isValid ?? false,
      isLoading: false,
      isSuccess: false,
      error: ''
    );
  }

  ResetPasswordState update({
    bool isValid,
    bool isLoading,
    bool isSuccess,
    String error
  }) {
    return ResetPasswordState(
      isValid: isValid ?? this.isValid,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error ?? this.error
    );
  }
}