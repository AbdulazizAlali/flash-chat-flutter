import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_chat/src/services/chat_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meta/meta.dart';

part 'chat_event.dart';
part 'chat_model.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final String userId;

  String chatId;
  Map members;
  String chatName;
  ChatService _chatService = ChatService();
  String _message;
  StreamSubscription _getMessagesSubscription;
  StreamSubscription _getChatSubscription;

  ChatBloc({this.userId, this.chatId, this.members, @required this.chatName});

  @override
  Future<void> close() async {
    await _getMessagesSubscription?.cancel();
    await _getChatSubscription?.cancel();
    return super.close();
  }

  @override
  ChatState get initialState => ChatState.initial(chatName: this.chatName);

  @override
  Stream<ChatState> mapEventToState(ChatEvent event) async* {
    if (event is ChatInitialFetchEvent)
      yield* _mapInitialFetchToState();
    else if (event is ChatFetchMessagesEvent)
      yield* _mapFetchMessagesToState(event);
    else if (event is ChatScrollToBottomEvent)
      yield* _mapScrollToBottomToState(event);
    else if (event is ChatFetchNameEvent)
      yield* _mapFetchNameToState(event);
    else if (event is ChatFetchMembersEvent)
      yield* _mapFetchMembersToState(event);
    else if (event is ChatRefreshMessagesEvent)
      yield* _mapRefreshMessagesToState();
    else if (event is ChatTextFieldChangedEvent)
      yield* _mapTextFieldChangedToState(event);
    else if (event is ChatSendTextEvent)
      yield* _mapSendTextToState();
    else if (event is ChatSendImageFromCameraEvent)
      yield* _mapSendImageToState(ImageSource.camera);
    else if (event is ChatSendImageFromLibraryEvent)
      yield* _mapSendImageToState(ImageSource.gallery);
    else if (event is ChatSendFileEvent) yield* _mapFileToState();
  }

  Stream<ChatState> _mapInitialFetchToState() async* {
    if (chatId != null) {
      _getMessagesSubscription =
          _chatService.getMessages(chatId).listen((messages) async {
        add(ChatFetchMessagesEvent(messages: messages));
        add(ChatScrollToBottomEvent(isScrollToBottom: true));
        try {
          add(ChatFetchMembersEvent(
              members: await _chatService.updateLastVisitTimestamp(
                  chatId, members)));
        } catch (e) {
          print(e);
        }
      });
      _getChatSubscription =
          _chatService.getChatMembersInfo(chatId).listen((membersInfo) {
        add(ChatFetchMembersEvent(members: membersInfo['members']));
        add(ChatFetchNameEvent(name: membersInfo['chatName']));
      });
    }
  }

  Stream<ChatState> _mapFetchMessagesToState(
      ChatFetchMessagesEvent event) async* {
    yield state.update(messages: event.messages);
  }

  Stream<ChatState> _mapScrollToBottomToState(
      ChatScrollToBottomEvent event) async* {
    yield state.update(isScrollToBottom: event.isScrollToBottom);
    if (event.isScrollToBottom) yield state.update(isScrollToBottom: false);
  }

  Stream<ChatState> _mapFetchNameToState(ChatFetchNameEvent event) async* {
    chatName = event.name;
    yield state.update(chatName: chatName);
  }

  Stream<ChatState> _mapFetchMembersToState(
      ChatFetchMembersEvent event) async* {
    members = event.members;
    yield state.update(members: members);
  }

  Stream<ChatState> _mapRefreshMessagesToState() async* {
    if (chatId != null) {
      try {
        List<MessageModel> messages = await _chatService
            .getMessages(chatId, state.messages[0].docSnapshot)
            .first;
        add(ChatFetchMessagesEvent(messages: messages + state.messages));
      } catch (e) {
        print(e);
      }
    }
  }

  Stream<ChatState> _mapTextFieldChangedToState(
      ChatTextFieldChangedEvent event) async* {
    _message = event.message;
    yield state.update(isMessageValid: _message.isNotEmpty);
    add(ChatScrollToBottomEvent(isScrollToBottom: true));
  }

  Stream<ChatState> _mapSendTextToState() async* {
    yield state.update(isLoading: true);
    try {
      if (chatId == null) await _createAndInitChat();
      await _chatService.sendTextMessage(chatId, _message);
      add(ChatTextFieldChangedEvent(message: ''));
    } catch (e) {
      print(e);
    } finally {
      yield state.update(isLoading: false);
    }
  }

  Stream<ChatState> _mapSendImageToState(ImageSource imageSource) async* {
    try {
      File imageFile =
          await ImagePicker.pickImage(source: imageSource, maxWidth: 400);
      yield state.update(isLoading: true);
      if (chatId == null) await _createAndInitChat();
      await _chatService.sendImageMessage(chatId, imageFile);
    } catch (e) {
      print(e);
    } finally {
      yield state.update(isLoading: false);
    }
  }

  Stream<ChatState> _mapFileToState() async* {
    try {
      FilePickerResult result = await FilePicker.platform.pickFiles();

      if (result != null) {
        File file = File(result.files.single.path);
      } else {
        // User canceled the picker
        yield state.update(isLoading: false);
      }

      yield state.update(isLoading: true);
      if (chatId == null) await _createAndInitChat();
      await _chatService.sendFileMessage(
          chatId, File(result.files.single.path));
    } catch (e) {
      print(e);
    } finally {
      yield state.update(isLoading: false);
    }
  }

  Future<void> _createAndInitChat() async {
    Map newChatInfo = await _chatService.createChat([userId]);
    chatId = newChatInfo['chatId'];
    add(ChatFetchMembersEvent(members: newChatInfo['members']));
    add(ChatInitialFetchEvent());
    return;
  }
}
