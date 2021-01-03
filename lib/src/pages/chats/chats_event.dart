part of 'chats_bloc.dart';

abstract class ChatsEvent {}

class ChatsSearchBarTextChangedEvent extends ChatsEvent {
  final String searchBarText;

  ChatsSearchBarTextChangedEvent({
    @required this.searchBarText
  });
}

class ChatsItemsChangedEvent extends ChatsEvent {}

class ChatsShowSearchBarEvent extends ChatsEvent {}

class ChatsInitialFetchEvent extends ChatsEvent {}

class ChatsFetchEvent extends ChatsEvent {}

class ChatsRemoveEvent extends ChatsEvent {
  final String chatId;
  final Map members;

  ChatsRemoveEvent({
    @required this.chatId,
    @required this.members
  });
}