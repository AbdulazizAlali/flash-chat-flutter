part of 'chats_bloc.dart';

class ChatsUsersModel {
  final List<ChatModel> chats;
  final List<UserModel> users;

  ChatsUsersModel({
    @required this.chats,
    @required this.users
  });

  factory ChatsUsersModel.initial() {
    return ChatsUsersModel(
      chats: [],
      users: []
    );
  }
}

class ChatModel {
  final String id;
  final List<String> imageUrls;
  final String name;
  final String text;
  final String date;
  final bool hasUnreadMessages;
  final Map members;

  ChatModel({
    @required this.id,
    @required this.imageUrls,
    @required this.name,
    @required this.text,
    @required this.date,
    @required this.hasUnreadMessages,
    @required this.members
  });
}

class UserModel {
  final String id;
  final String imageUrl;
  final String name;

  UserModel({
    @required this.id,
    @required this.imageUrl,
    @required this.name
  });
}