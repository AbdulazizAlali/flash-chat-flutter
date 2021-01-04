import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_chat/src/services/auth_service.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final _authService = AuthService();
  final _firebaseDatabase = FirebaseDatabase.instance.reference();


  @override
  AuthState get initialState => AuthUninitializedState();

  @override
  Stream<AuthState> mapEventToState(
    AuthEvent event,
  ) async* {
    if (event is AuthStartedEvent)
      yield* _mapStartedToState(event);
    else if (event is AuthLoggedInEvent)
      yield* _mapLoggedInToState();
    else if (event is AuthLoggedOutEvent) yield* _mapLoggedOutToState();
  }

  Stream<AuthState> _mapStartedToState(AuthStartedEvent event) async* {
    if (await _authService.isLoggedIn()) {
      String me = await _authService.getProfile().then((value) => value.username);
      bool first = true;
      _firebaseDatabase.child(me).child("calls").onValue.listen((event) {
        if(first){
          first = false;
        }else{
         String channelId = event.snapshot.value["userId"];
         
        }
      });
      yield AuthAuthenticatedState();
    } else
      yield AuthUnauthenticatedState();
  }

  Stream<AuthState> _mapLoggedInToState() async* {
    yield AuthAuthenticatedState();
  }

  Stream<AuthState> _mapLoggedOutToState() async* {
    yield AuthUnauthenticatedState();
    _authService.logout();
  }
}
