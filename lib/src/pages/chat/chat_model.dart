part of 'chat_bloc.dart';

class MessageModel {
  final String content;
  final String contentType;
  final Timestamp date;
  final String userId;
  final dynamic docSnapshot;

  MessageModel(
      {@required this.content,
      @required this.contentType,
      @required this.date,
      this.userId,
      @required this.docSnapshot});
}
