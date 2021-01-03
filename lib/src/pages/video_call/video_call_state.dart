part of 'video_call_bloc.dart';

class VideoCallState {
  final int userId;
  final bool muted;

  VideoCallState({
    @required this.userId,
    @required this.muted
  });

  factory VideoCallState.initial() {
    return VideoCallState(
      userId: null,
      muted: false
    );
  }

  VideoCallState update({
    int userId,
    bool muted
  }) {
    return VideoCallState(
      userId: userId ?? this.userId,
      muted: muted ?? this.muted
    );
  }
}