import 'package:meta/meta.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_chat/src/services/chat_service.dart';
import 'package:flutter_firebase_chat/src/pages/chats/chats.dart';

part 'add_user_event.dart';
part 'add_user_state.dart';

class AddUserBloc extends Bloc<AddUserEvent, AddUserState> {
  final String chatId;
  final Map members;

  ChatService _chatService = ChatService();
  String _searchBarText;

  AddUserBloc({
    this.chatId,
    this.members
  });

  @override
  AddUserState get initialState => AddUserState.initial();

  @override
  Stream<AddUserState> mapEventToState(AddUserEvent event) async* {
    if (event is AddUserSearchBarTextChangedEvent)
      yield* _mapSearchBarTextChangedToState(event);
    else if (event is AddUserFetchEvent)
      yield* _mapFetchToState();
    else if (event is AddUserSelectedEvent)
      yield* _mapUserSelectedToState(event);
  }

  Stream<AddUserState> _mapSearchBarTextChangedToState(
    AddUserSearchBarTextChangedEvent event
  ) async* {
    _searchBarText = event.searchBarText;
    yield state.update(
      isSearchBarEmpty: _searchBarText.isEmpty
    );
  }

  Stream<AddUserState> _mapFetchToState() async* {
    try {
      List<UserModel> users = await _chatService.getUsersByQueryExceptMembers(
        _searchBarText ?? '',
        members
      );
      yield state.update(
        users: users
      );
    } catch (e) {
      print(e);
    }
  }

  Stream<AddUserState> _mapUserSelectedToState(
    AddUserSelectedEvent event
  ) async* {
    yield state.update(
      isLoading: true
    );
    try {
      await _chatService.addChatMember(
        chatId, event.userId, members
      );
      yield state.update(
        isUserSelected: true,
        isLoading: false
      );
    } catch (e) {
      print(e);
      yield state.update(
        isLoading: false
      );
    }
  }
}