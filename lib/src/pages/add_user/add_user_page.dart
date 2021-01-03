import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_chat/src/themes/colors.dart';
import 'package:flutter_firebase_chat/src/widgets/appbar_with_backbutton.dart';
import 'package:flutter_firebase_chat/src/widgets/searchbar_textfield.dart';
import 'package:flutter_firebase_chat/src/widgets/customizable_listtile.dart';
import 'package:flutter_firebase_chat/src/utils/loading.dart';
import 'package:flutter_firebase_chat/src/pages/add_user/add_user_bloc.dart';
import 'package:flutter_firebase_chat/src/pages/chats/chats.dart';

class AddUserPage extends StatefulWidget {
  @override
  AddUserPageState createState() => AddUserPageState();
}

class AddUserPageState extends State<AddUserPage> {
  TextEditingController _searchBarController = TextEditingController();
  Loading _loading;
  AddUserBloc _addUserBloc;

  void _onSearchBarChanged() {
    _addUserBloc.add(
      AddUserSearchBarTextChangedEvent(
        searchBarText: _searchBarController.text
      )
    );
  }

  void _clearSearchBarPressed() {
    _searchBarController.text = '';
    _onSearchBarChanged();
    _addUserBloc.add(AddUserFetchEvent());
  }

  void _userPressed(UserModel user) {
    _addUserBloc.add(
      AddUserSelectedEvent(
        userId: user.id
      )
    );
  }

  void _blocListener(context, state) {
    if (state.isLoading)
      _loading = Loading(context);
    else if (!state.isLoading && _loading != null) {
      _loading.close();
      _loading = null;
    }
    if (state.isUserSelected)
      Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    _addUserBloc = BlocProvider.of<AddUserBloc>(context);
    _addUserBloc.add(AddUserFetchEvent());
  }

  @override
  void dispose() {
    _searchBarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(true),
      child: Scaffold(
        appBar: AppBarWithBackButton(),
        body: BlocListener<AddUserBloc, AddUserState>(
          listener: _blocListener,
          child: BlocBuilder<AddUserBloc, AddUserState>(
            builder: (_, state) {
              List<UserModel> users = state.users;
              return SafeArea(
                child: Container(
                  padding: EdgeInsets.fromLTRB(30, 22, 30, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(bottom: 26),
                        child: Text(
                          'Add User',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: blackColor
                          )
                        )
                      ),
                      SearchBarTextField(
                        hintText: 'Search for users',
                        controller: _searchBarController,
                        showClear: !state.isSearchBarEmpty,
                        onClearPressed: _clearSearchBarPressed,
                        onChanged: _onSearchBarChanged,
                        onChangedWithDelay: () => _addUserBloc.add(
                          AddUserFetchEvent()
                        )
                      ),
                      _buildUsersList(users)
                    ]
                  )
                )
              );
            }
          )
        )
      )
    );
  }

  Widget _buildUsersList(List<UserModel> users) {
    return Expanded(
      child: ListView.builder(
        itemCount: users.length,
        itemBuilder: (_, index) =>
          Container(
            margin: EdgeInsets.only(bottom: 26),
            child: CustomizableListTile(
              leading: CircleAvatar(
                radius: 25,
                backgroundColor: blueColor,
                backgroundImage: NetworkImage(users[index].imageUrl)
              ),
              title: users[index].name,
              onTap: () => _userPressed(users[index])
            )
          )
      )
    );
  }
}