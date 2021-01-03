part of 'chats_bloc.dart';

class ChatsState {
  final bool isSearchBarHidden;
  final bool isSearchBarEmpty;
  final bool isLoading;
  final ChatsUsersModel chatsAndUsers;

  ChatsState({
    @required this.isSearchBarHidden,
    @required this.isSearchBarEmpty,
    @required this.isLoading,
    @required this.chatsAndUsers
  });

  factory ChatsState.initial({
    ChatsUsersModel chatsAndUsers
  }) {
    return ChatsState(
      isSearchBarHidden: true,
      isSearchBarEmpty: true,
      isLoading: false,
      chatsAndUsers: chatsAndUsers ?? ChatsUsersModel.initial()
    );
  }

  ChatsState update({
    bool isSearchBarHidden,
    bool isSearchBarEmpty,
    bool isLoading,
    ChatsUsersModel chatsAndUsers
  }) {
    return ChatsState(
      isSearchBarHidden: isSearchBarHidden ?? this.isSearchBarHidden,
      isSearchBarEmpty: isSearchBarEmpty ?? this.isSearchBarEmpty,
      isLoading: isLoading ?? this.isLoading,
      chatsAndUsers: chatsAndUsers ?? this.chatsAndUsers
    );
  }
}