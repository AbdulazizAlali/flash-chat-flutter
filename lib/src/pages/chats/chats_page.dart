import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_firebase_chat/src/themes/colors.dart';
import 'package:flutter_firebase_chat/src/widgets/raw_icon_button.dart';
import 'package:flutter_firebase_chat/src/widgets/searchbar_textfield.dart';
import 'package:flutter_firebase_chat/src/widgets/customizable_listtile.dart';
import 'package:flutter_firebase_chat/src/utils/confirm_alert.dart';
import 'package:flutter_firebase_chat/src/utils/loading.dart';
import 'package:flutter_firebase_chat/src/pages/chats/chats_bloc.dart';
import 'package:flutter_firebase_chat/src/pages/chat/chat.dart';

class ChatsPage extends StatefulWidget {
  @override
  ChatsPageState createState() => ChatsPageState();
}

class ChatsPageState extends State<ChatsPage> with AutomaticKeepAliveClientMixin<ChatsPage> {
  TextEditingController _searchBarController = TextEditingController();
  Loading _loading;
  ChatsBloc _chatsBloc;

  void _openSearchBarPressed() {
    _chatsBloc.add(
      ChatsShowSearchBarEvent()
    );
  }

  void _onSearchBarChanged() {
    _chatsBloc.add(
      ChatsSearchBarTextChangedEvent(
        searchBarText: _searchBarController.text
      )
    );
  }

  void _clearSearchBarPressed() {
    _searchBarController.text = '';
    _onSearchBarChanged();
    _chatsBloc.add(ChatsItemsChangedEvent());
  }

  void _chatOrUserPressed({
    String userId,
    String chatId,
    Map members,
    @required String chatName
  }) {
    Navigator.push(context,
      MaterialPageRoute(builder: (_) =>
        BlocProvider<ChatBloc>(
          create: (_) => ChatBloc(
            userId: userId,
            chatId: chatId,
            members: members,
            chatName: chatName
          ),
          child: ChatPage()
        )
      )
    );
    _clearSearchBarPressed();
  }

  void _chatDeletePressed(ChatModel chat) {
    ConfirmAlert(
      context: context,
      title: 'Are you sure you want to delete this chat?',
      onConfirm: () {
        _chatsBloc.add(ChatsRemoveEvent(
          chatId: chat.id,
          members: chat.members
        ));
      }
    );
  }

  void _blocListener(context, state) {
    if (state.isLoading)
      _loading = Loading(context);
    else if (!state.isLoading && _loading != null) {
      _loading.close();
      _loading = null;
    }
  }
  
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _chatsBloc = BlocProvider.of<ChatsBloc>(context);
    _chatsBloc.add(ChatsInitialFetchEvent());
  }

  @override
  void dispose() {
    _searchBarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: BlocListener<ChatsBloc, ChatsState>(
        listener: _blocListener,
        child: BlocBuilder<ChatsBloc, ChatsState>(
          builder: (_, state) {
            List<ChatModel> chats = state.chatsAndUsers.chats;
            List<UserModel> users = state.chatsAndUsers.users;
            return SafeArea(
              child: Container(
                padding: EdgeInsets.fromLTRB(30, 30, 30, 0),
                child: Column(
                  children: [
                    Container(
                      margin: state.isSearchBarHidden ?
                        EdgeInsets.only(bottom: 34) :
                        EdgeInsets.only(bottom: 26),
                      child: Row(children: [
                        Expanded(
                          child: Text(
                            'Chats',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: blackColor
                            )
                          )
                        ),
                        RawIconButton(
                          height: 38,
                          padding: EdgeInsets.only(left: 10),
                          icon: Icon(
                            Icons.search,
                            color: blackColor,
                            size: 25
                          ),
                          onPressed: _openSearchBarPressed
                        )
                      ])
                    ),
                    !state.isSearchBarHidden ? SearchBarTextField(
                      hintText: 'Search for chats and users',
                      controller: _searchBarController,
                      showClear: !state.isSearchBarEmpty,
                      onClearPressed: _clearSearchBarPressed,
                      onChanged: _onSearchBarChanged,
                      onChangedWithDelay: () => _chatsBloc.add(
                        ChatsItemsChangedEvent()
                      )
                    ) : Container(),
                    _buildChatsAndUsersList(
                      chats, users
                    )
                  ]
                )
              )
            );
          }
        )
      )
    );
  }

  Widget _buildChatsAndUsersList(
    List chats,
    List users
  ) {
    List chatsWithHeader = chats.map((chatItem) =>
      _buildChatTile(chatItem)
    ).toList();
    List usersWithHeader = users.map((userItem) =>
      _buildUserTile(userItem)
    ).toList();
    if ((chatsWithHeader.length > 0) && (usersWithHeader.length > 0))
      chatsWithHeader.insert(0, _buildChatsAndUsersHeader('Chats'));
    if (usersWithHeader.length > 0)
      usersWithHeader.insert(0, _buildChatsAndUsersHeader('Users'));
    return Expanded(
      child: ListView(
        children: chatsWithHeader + usersWithHeader
      )
    );
  }

  Widget _buildChatsAndUsersHeader(String headerText) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: Text(
        headerText,
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: greyColor
        )
      )
    );
  }

  Widget _buildChatTile(ChatModel item) {
    return Container(
      margin: EdgeInsets.only(bottom: 26),
      child: Slidable(
        actionPane: SlidableDrawerActionPane(),
        actionExtentRatio: 0.25,
          child: CustomizableListTile(
          leading: (item.imageUrls.length > 1) ? Container(
            width: 50,
            height: 50,
            child: Stack(
              children: <Widget>[
                Positioned(
                  right: 0,
                  top: 0,
                  child: CircleAvatar(
                    radius: 17,
                    backgroundColor: blueColor,
                    backgroundImage: NetworkImage(item.imageUrls[1])
                  )
                ),
                Positioned(
                  left: 0,
                  bottom: 0,
                  child: CircleAvatar(
                    radius: 17,
                    backgroundColor: blueColor,
                    backgroundImage: NetworkImage(item.imageUrls[0])
                  )
                )
              ]
            )
          ) :
          item.imageUrls[0].isNotEmpty ?
            CircleAvatar(
              radius: 25,
              backgroundColor: blueColor,
              backgroundImage: NetworkImage(item.imageUrls[0])
            ) :
            Container(),
          title: item.name,
          subTitle: Row(
            children: [
              Flexible(
                child: Text(
                  item.text,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 14,
                    color: greyColor
                  )
                )
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 5),
                width: 2,
                height: 2,
                decoration: BoxDecoration(
                  color: greyColor,
                  shape: BoxShape.circle,
                ),
              ),
              Flexible(
                child: Text(
                  item.date,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: lightGreyColor
                  )
                )
              )
            ]
          ),
          trailing: item.hasUnreadMessages ? Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: blueColor,
              shape: BoxShape.circle,
            ),
          ) : null,
          onTap: () => _chatOrUserPressed(
            chatId: item.id,
            members: item.members,
            chatName: item.name
          )
        ),
        secondaryActions: [
          IconSlideAction(
            iconWidget: Icon(
              Icons.delete_outline,
              color: whiteColor,
              size: 25
            ),
            color: Colors.red,
            onTap: () => _chatDeletePressed(item)
          ),
        ],
      )
    );
  }

  Widget _buildUserTile(UserModel item) {
    return Container(
      margin: EdgeInsets.only(bottom: 26),
      child: CustomizableListTile(
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: blueColor,
          backgroundImage: NetworkImage(item.imageUrl)
        ),
        title: item.name,
        onTap: () => _chatOrUserPressed(
          userId: item.id,
          chatName: item.name
        )
      )
    );
  }
}