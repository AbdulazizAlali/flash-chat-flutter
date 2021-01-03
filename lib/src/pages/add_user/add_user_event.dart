part of 'add_user_bloc.dart';

abstract class AddUserEvent {}

class AddUserSearchBarTextChangedEvent extends AddUserEvent {
  final String searchBarText;

  AddUserSearchBarTextChangedEvent({
    @required this.searchBarText
  });
}

class AddUserFetchEvent extends AddUserEvent {}

class AddUserSelectedEvent extends AddUserEvent {
  final String userId;

  AddUserSelectedEvent({
    @required this.userId
  });
}