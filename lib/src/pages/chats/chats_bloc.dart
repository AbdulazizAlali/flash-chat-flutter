import 'dart:async';
import 'package:meta/meta.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_chat/src/services/chat_service.dart';

part 'chats_model.dart';
part 'chats_event.dart';
part 'chats_state.dart';

class ChatsBloc extends Bloc<ChatsEvent, ChatsState> {
  ChatService _chatService = ChatService();
  String _searchBarText = '';
  ChatsUsersModel _chatsAndUsers = ChatsUsersModel.initial();
  StreamSubscription _getChatsSubscription;

  @override
  Future<void> close() async {
    await _getChatsSubscription?.cancel();
    await _chatService.dispose();
    return super.close();
  }

  @override
  ChatsState get initialState => ChatsState.initial();

  @override
  Stream<ChatsState> mapEventToState(ChatsEvent event) async* {
    if (event is ChatsSearchBarTextChangedEvent)
      yield* _mapSearchBarTextChangedToState(event);
    else if (event is ChatsItemsChangedEvent)
      yield* _mapItemsChangedToState(event);
    else if (event is ChatsShowSearchBarEvent)
      yield* _mapShowSearchBarToState();
    else if (event is ChatsInitialFetchEvent)
      yield* _mapInitialFetchToState();
    else if (event is ChatsFetchEvent)
      yield* _mapFetchToState();
    else if (event is ChatsRemoveEvent)
      yield* _mapRemoveToState(event);
  }

  Stream<ChatsState> _mapSearchBarTextChangedToState(
    ChatsSearchBarTextChangedEvent event
  ) async* {
    _searchBarText = event.searchBarText;
    yield state.update(
      isSearchBarEmpty: _searchBarText.isEmpty
    );
  }

  Stream<ChatsState> _mapItemsChangedToState(
    ChatsItemsChangedEvent event
  ) async* {
    try {
      if (_searchBarText.isNotEmpty)
        _chatsAndUsers = await _chatService.getChatsAndUsersByQuery(_searchBarText);
      else _chatsAndUsers = ChatsUsersModel(
        chats: await _chatService.getChats(),
        users: []
      );
      add(ChatsFetchEvent());
    } catch (e) {
      print(e);
    }
  }

  Stream<ChatsState> _mapShowSearchBarToState() async* {
    yield state.update(
      isSearchBarHidden: false
    );
  }

  Stream<ChatsState> _mapInitialFetchToState() async* {
    _getChatsSubscription = _chatService
      .watchChats()
      .listen((newChats) {
        if (_searchBarText.isEmpty) {
          _chatsAndUsers = ChatsUsersModel(
            chats: newChats,
            users: []
          );
          add(ChatsFetchEvent());
        }
      });
  }

  Stream<ChatsState> _mapFetchToState() async* {
    yield state.update(
      chatsAndUsers: _chatsAndUsers
    );
  }

  Stream<ChatsState> _mapRemoveToState(
    ChatsRemoveEvent event
  ) async* {
    yield state.update(
      isLoading: true
    );
    try {
      await _chatService.removeChat(
        event.chatId,
        event.members
      );
    } catch (e) {
      print(e);
    } finally {
      yield state.update(
        isLoading: false
      );
    }
  }
}