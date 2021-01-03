part of 'offers_bloc.dart';

class NewOfferState {
  final bool isValid;
  final bool isLoading;
  final bool isSuccess;
  final String error;

  NewOfferState(
      {@required this.isValid,
      @required this.isLoading,
      @required this.isSuccess,
      @required this.error});

  factory NewOfferState.initial({bool isValid}) {
    return NewOfferState(
        isValid: isValid ?? false,
        isLoading: false,
        isSuccess: false,
        error: '');
  }

  NewOfferState update(
      {bool isValid, bool isLoading, bool isSuccess, String error}) {
    return NewOfferState(
        isValid: isValid ?? this.isValid,
        isLoading: isLoading ?? this.isLoading,
        isSuccess: isSuccess ?? this.isSuccess,
        error: error ?? this.error);
  }
}
