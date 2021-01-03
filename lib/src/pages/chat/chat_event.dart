part of 'chat_bloc.dart';

abstract class ChatEvent {}

class ChatInitialFetchEvent extends ChatEvent {}

class ChatFetchMessagesEvent extends ChatEvent {
  final List<MessageModel> messages;

  ChatFetchMessagesEvent({@required this.messages});
}

class ChatFetchNameEvent extends ChatEvent {
  final String name;

  ChatFetchNameEvent({@required this.name});
}

class ChatFetchMembersEvent extends ChatEvent {
  final Map members;

  ChatFetchMembersEvent({@required this.members});
}

class ChatRefreshMessagesEvent extends ChatEvent {}

class ChatTextFieldChangedEvent extends ChatEvent {
  final String message;

  ChatTextFieldChangedEvent({@required this.message});
}

class ChatSendTextEvent extends ChatEvent {}

class ChatSendImageFromCameraEvent extends ChatEvent {}

class ChatSendFileEvent extends ChatEvent {}

class ChatSendImageFromLibraryEvent extends ChatEvent {}

class ChatScrollToBottomEvent extends ChatEvent {
  final bool isScrollToBottom;

  ChatScrollToBottomEvent({@required this.isScrollToBottom});
}
