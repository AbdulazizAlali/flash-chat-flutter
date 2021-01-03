import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_chat/src/themes/colors.dart';
import 'package:flutter_firebase_chat/src/pages/auth/auth_bloc.dart';
import 'package:flutter_firebase_chat/src/pages/login/login.dart';
import 'package:flutter_firebase_chat/src/pages/tabs/tabs.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthBloc()..add(AuthStartedEvent()),
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (_, state) {
          Widget homeWidget;
          if (state is AuthUnauthenticatedState)
            homeWidget = BlocProvider<LoginBloc>(
              create: (_) => LoginBloc(),
              child: LoginPage()
            );
          else if (state is AuthAuthenticatedState)
            homeWidget = TabsPage();
          else homeWidget = Scaffold();
          return GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus.unfocus(),
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                fontFamily: 'Lato-Regular',
                scaffoldBackgroundColor: whiteColor
              ),
              home: homeWidget
            )
          );
        }
      )
    );
  }
}