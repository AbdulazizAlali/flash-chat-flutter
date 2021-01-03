import 'dart:async';
import 'package:meta/meta.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_chat/src/services/video_call_service.dart';

part 'video_call_event.dart';
part 'video_call_state.dart';

class VideoCallBloc extends Bloc<VideoCallEvent, VideoCallState> {
  final String chatId;

  VideoCallService _videoCallService = VideoCallService();
  StreamSubscription _onUserJoinedSubscription;
  StreamSubscription _onUserOfflineSubscription;
  bool _muted = false;
  int _userId;

  VideoCallBloc({
    @required this.chatId
  });

  @override
  Future<void> close() async {
    await _videoCallService.dispose();
    await _onUserJoinedSubscription?.cancel();
    await _onUserOfflineSubscription?.cancel();
    return super.close();
  }

  @override
  VideoCallState get initialState => VideoCallState.initial();

  @override
  Stream<VideoCallState> mapEventToState(VideoCallEvent event) async* {
    if (event is VideoCallInitEvent)
      yield* _mapInitToState();
    else if (event is VideoCallUserJoinedEvent)
      yield* _mapUserJoinedToState(event);
    else if (event is VideoCallUserOfflineEvent)
      yield* _mapUserOfflineToState(event);
    else if (event is VideoCallMuteAudioEvent)
      yield* _mapMuteAudioToState();
    else if (event is VideoCallSwitchCameraEvent)
      yield* _mapSwitchCameraToState();
  }

  Stream<VideoCallState> _mapInitToState() async* {
    try {
      await _videoCallService.init(chatId);
      _onUserJoinedSubscription = _videoCallService
        .onUserJoined
        .listen((userId) {
          add(VideoCallUserJoinedEvent(
            userId: userId
          ));
        });
      _onUserOfflineSubscription = _videoCallService
        .onUserOffline
        .listen((userId) {
          add(VideoCallUserOfflineEvent(
            userId: userId
          ));
        });
    } catch (e) {
      print(e);
    }
  }

  Stream<VideoCallState> _mapUserJoinedToState(
    VideoCallUserJoinedEvent event
  ) async* {
    if (_userId == null) {
      _userId = event.userId;
      yield state.update(
        userId: _userId
      );
    }
  }

  Stream<VideoCallState> _mapUserOfflineToState(
    VideoCallUserOfflineEvent event
  ) async* {
    if (_userId == event.userId) {
      _userId = null;
      yield VideoCallState.initial();
    }
  }

  Stream<VideoCallState> _mapMuteAudioToState() async* {
    try {
      _muted = !_muted;
      await _videoCallService.muteAudio(_muted);
      yield state.update(
        muted: _muted
      );
    } catch (e) {
      print(e);
    }
  }

  Stream<VideoCallState> _mapSwitchCameraToState() async* {
    try {
      await _videoCallService.switchCamera();
    } catch (e) {
      print(e);
    }
  }
}