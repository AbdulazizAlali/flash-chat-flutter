import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter_firebase_chat/src/services/auth_service.dart';

class VideoCallService {
  StreamController<int> _onUserJoinedController = new StreamController();
  StreamController<int> _onUserOfflineController = StreamController();

  Stream get onUserJoined => _onUserJoinedController.stream;
  Stream get onUserOffline => _onUserOfflineController.stream;

  AuthService _authService = AuthService();

  Future<bool> init(String channelId) async {
    // await AgoraRtcEngine.enableVideo();

    _addAgoraEventHandlers();
    await AgoraRtcEngine.enableWebSdkInteroperability(true);
    await AgoraRtcEngine.setParameters(
        '''{\"che.video.lowBitRateStreamParameter\":{\"width\":320,\"height\":180,\"frameRate\":15,\"bitRate\":140}}''');
    String me = await _authService.getProfile().then((value) => value.username);
    return AgoraRtcEngine.joinChannelByUserAccount({
      'userAccount': await _authService.getCurrentUserId(),
      'channelId': me,
    });
  }

  void _addAgoraEventHandlers() {
    AgoraRtcEngine.onError = (dynamic code) {
      print('AgoraRtcEngine Error: $code');
    };
    AgoraRtcEngine.onUserJoined = (int uid, int elapsed) {
      _onUserJoinedController.add(uid);
    };
    AgoraRtcEngine.onUserOffline = (int uid, int reason) {
      _onUserOfflineController.add(uid);
    };
  }

  Future<void> muteAudio(bool muted) async {
    return AgoraRtcEngine.muteLocalAudioStream(muted);
  }

  Future<void> switchCamera() {
    return AgoraRtcEngine.switchCamera();
  }

  Future<void> dispose() async {
    await _onUserJoinedController.close();
    await _onUserOfflineController.close();
    await AgoraRtcEngine.leaveChannel();
    return AgoraRtcEngine.destroy();
  }
}
