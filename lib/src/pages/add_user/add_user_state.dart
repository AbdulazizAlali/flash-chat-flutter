part of 'add_user_bloc.dart';

class AddUserState {
  final bool isSearchBarEmpty;
  final bool isUserSelected;
  final bool isLoading;
  final List<UserModel> users;

  AddUserState({
    @required this.isSearchBarEmpty,
    @required this.isUserSelected,
    @required this.isLoading,
    @required this.users
  });

  factory AddUserState.initial({
    List<UserModel> users
  }) {
    return AddUserState(
      isSearchBarEmpty: true,
      isUserSelected: false,
      isLoading: false,
      users: users ?? []
    );
  }

  AddUserState update({
    bool isSearchBarEmpty,
    bool isUserSelected,
    bool isLoading,
    List<UserModel> users
  }) {
    return AddUserState(
      isSearchBarEmpty: isSearchBarEmpty ?? this.isSearchBarEmpty,
      isUserSelected: isUserSelected ?? this.isUserSelected,
      isLoading: isLoading ?? this.isLoading,
      users: users ?? this.users
    );
  }
}