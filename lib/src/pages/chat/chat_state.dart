part of 'chat_bloc.dart';

class ChatState {
  final bool isMessageValid;
  final bool isScrollToBottom;
  final bool isLoading;
  final String chatName;
  final List<MessageModel> messages;
  final Map members;

  ChatState({
    @required this.isMessageValid,
    @required this.isScrollToBottom,
    @required this.isLoading,
    @required this.chatName,
    @required this.messages,
    @required this.members
  });

  factory ChatState.initial({
    @required String chatName
  }) {
    return ChatState(
      isMessageValid: false,
      isScrollToBottom: false,
      isLoading: false,
      chatName: chatName,
      messages: [],
      members: {}
    );
  }

  ChatState update({
    bool isMessageValid,
    bool isScrollToBottom,
    bool isLoading,
    String chatName,
    List<MessageModel> messages,
    Map members
  }) {
    return ChatState(
      isMessageValid: isMessageValid ?? this.isMessageValid,
      isScrollToBottom: isScrollToBottom ?? this.isScrollToBottom,
      isLoading: isLoading ?? this.isLoading,
      chatName: chatName ?? this.chatName,
      messages: messages ?? this.messages,
      members: members ?? this.members
    );
  }
}