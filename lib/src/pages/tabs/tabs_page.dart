import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_chat/src/themes/colors.dart';
import 'package:flutter_firebase_chat/src/pages/chats/chats.dart';
import 'package:flutter_firebase_chat/src/pages/profile/profile.dart';

class TabsPage extends StatefulWidget {
  @override
  TabsPageState createState() => TabsPageState();
}

class TabsPageState extends State<TabsPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: TabBarView(
          children: [
            BlocProvider<ChatsBloc>(
              create: (_) => ChatsBloc(),
              child: ChatsPage()
            ),
            BlocProvider<ProfileBloc>(
              create: (_) => ProfileBloc(),
              child: ProfilePage()
            )
          ]
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            color: whiteColor,
            height: 45,
            child: TabBar(
              unselectedLabelColor: lightGreyColor,
              labelColor: blueColor,
              indicatorColor: Colors.transparent,
              tabs: [
                Tab(
                  icon: Icon(
                    Icons.question_answer,
                    size: 25
                  )
                ),
                Tab(
                  icon: Icon(
                    Icons.person,
                    size: 25
                  )
                )
              ]
            )
          )
        )
      )
    );
  }
}