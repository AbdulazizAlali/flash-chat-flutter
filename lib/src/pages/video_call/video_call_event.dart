part of 'video_call_bloc.dart';

abstract class VideoCallEvent {}

class VideoCallInitEvent extends VideoCallEvent {}

class VideoCallUserJoinedEvent extends VideoCallEvent {
  final int userId;

  VideoCallUserJoinedEvent({
    @required this.userId
  });
}

class VideoCallUserOfflineEvent extends VideoCallEvent {
  final int userId;

  VideoCallUserOfflineEvent({
    @required this.userId
  });
}

class VideoCallMuteAudioEvent extends VideoCallEvent {}

class VideoCallSwitchCameraEvent extends VideoCallEvent {}